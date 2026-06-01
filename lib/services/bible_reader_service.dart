import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../domain/bible_reader_models.dart';

class BibleReaderService {
  static final BibleReaderService instance = BibleReaderService._();
  BibleReaderService._();

  // Cache LRU en mémoire : "versionId/bookName/chapter" -> données
  final Map<String, BibleChapterData> _cache = {};
  static const int _maxCacheSize = 30; // max 30 chapitres en mémoire

  // ── Chemins locaux ─────────────────────────────────────────────────────────

  Future<Directory> get _biblesDir async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/bibles');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<Directory> _versionDir(String versionId) async {
    final base = await _biblesDir;
    final dir = Directory('${base.path}/$versionId');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  // ── État des versions ──────────────────────────────────────────────────────

  Future<bool> isVersionDownloaded(String versionId) async {
    final dir = await _versionDir(versionId);
    final marker = File('${dir.path}/.complete');
    return marker.existsSync();
  }

  Future<List<String>> downloadedVersionIds() async {
    final result = <String>[];
    for (final v in BibleVersion.available) {
      if (await isVersionDownloaded(v.id)) result.add(v.id);
    }
    return result;
  }

  // ── Téléchargement ─────────────────────────────────────────────────────────

  /// Télécharge et extrait une version depuis Firebase Storage.
  /// Émet des valeurs entre 0.0 et 1.0 (progression), puis 1.0 à la fin.
  Stream<double> downloadVersion(String versionId) async* {
    final version = BibleVersion.fromId(versionId);
    if (version == null) throw Exception('Version inconnue : $versionId');

    final dir = await _versionDir(versionId);
    final zipFile = File('${dir.path}/tmp.zip');

    try {
      // 1. Obtenir l'URL de téléchargement depuis Firebase Storage
      yield 0.0;
      final ref = FirebaseStorage.instance.ref(version.storagePath);
      final url = await ref.getDownloadURL();

      // 2. Télécharger avec suivi de progression
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      final totalBytes = response.contentLength ?? 0;

      final sink = zipFile.openWrite();
      var receivedBytes = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          // Progression : 0.0 → 0.7 pour le téléchargement
          yield (receivedBytes / totalBytes) * 0.7;
        }
      }
      await sink.close();
      client.close();

      // 3. Extraire le zip
      yield 0.75;
      await compute(_extractZip, (zipFile.path, dir.path));
      zipFile.deleteSync();

      // 4. Marquer comme complet
      File('${dir.path}/.complete').writeAsStringSync('ok');
      yield 1.0;
    } catch (e) {
      if (zipFile.existsSync()) zipFile.deleteSync();
      rethrow;
    }
  }

  /// Extraction du zip dans un isolate séparé pour ne pas bloquer l'UI
  static void _extractZip((String zipPath, String destPath) args) {
    final (zipPath, destPath) = args;
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      if (file.isFile) {
        final outFile = File('$destPath/${file.name}');
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      }
    }
  }

  /// Supprime une version téléchargée
  Future<void> deleteVersion(String versionId) async {
    final dir = await _versionDir(versionId);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    _evictVersionFromCache(versionId);
  }

  // ── Lecture ────────────────────────────────────────────────────────────────

  /// Charge un chapitre depuis le stockage local (avec cache mémoire).
  Future<BibleChapterData?> getChapter(
    String versionId,
    String bookName,
    int chapter,
  ) async {
    final key = '$versionId/$bookName/$chapter';
    if (_cache.containsKey(key)) return _cache[key];

    if (!await isVersionDownloaded(versionId)) return null;

    final dir = await _versionDir(versionId);
    final fileName = _bookToFileName(bookName);
    final file = File('${dir.path}/$fileName');
    if (!file.existsSync()) return null;

    try {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final chapters = json['chapters'] as List<dynamic>;
      final chapterIdx = chapter - 1;
      if (chapterIdx < 0 || chapterIdx >= chapters.length) return null;

      final verseList = chapters[chapterIdx] as List<dynamic>;
      final data = BibleChapterData.fromJson(bookName, chapter, verseList);

      _addToCache(key, data);
      return data;
    } catch (e) {
      debugPrint('[BibleReaderService] Erreur lecture $versionId/$bookName/$chapter: $e');
      return null;
    }
  }

  // ── Cache ──────────────────────────────────────────────────────────────────

  void _addToCache(String key, BibleChapterData data) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = data;
  }

  void _evictVersionFromCache(String versionId) {
    _cache.removeWhere((k, _) => k.startsWith('$versionId/'));
  }

  // ── Utilitaires ────────────────────────────────────────────────────────────

  /// Normalise un nom de livre français en nom de fichier JSON.
  /// Ex: "1 Rois" -> "1_rois.json", "Ézéchiel" -> "ezechiel.json"
  static String _bookToFileName(String bookName) {
    var name = bookName.toLowerCase();
    // Supprimer les accents
    const accents = 'àáâäèéêëìíîïòóôöùúûüýÿçñæœ';
    const plain   = 'aaaaeeeeiiiioooouuuuyyçnaeoe'; // même longueur
    for (var i = 0; i < accents.length; i++) {
      name = name.replaceAll(accents[i], plain[i]);
    }
    // Remplacer espaces et caractères spéciaux par underscore
    name = name.replaceAll(RegExp(r'[^a-z0-9]'), '_');
    name = name.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    return '$name.json';
  }
}
