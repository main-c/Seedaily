import 'package:flutter/foundation.dart';
import '../domain/bible_reader_models.dart';
import '../services/bible_reader_service.dart';
import '../services/storage_service.dart';

class BibleReaderProvider with ChangeNotifier {
  final StorageService _storage;

  BibleReaderProvider({required StorageService storage}) : _storage = storage;

  // ── État des versions téléchargées ─────────────────────────────────────────

  Set<String> _downloadedIds = {};
  Set<String> get downloadedIds => _downloadedIds;

  bool isDownloaded(String versionId) => _downloadedIds.contains(versionId);

  // ── Téléchargement en cours ────────────────────────────────────────────────

  final Map<String, double> _downloadProgress = {};
  Map<String, double> get downloadProgress => Map.unmodifiable(_downloadProgress);

  bool isDownloading(String versionId) => _downloadProgress.containsKey(versionId);

  // ── Version sélectionnée ───────────────────────────────────────────────────

  String _selectedVersionId = 'lsg';
  String get selectedVersionId => _selectedVersionId;

  BibleVersion? get selectedVersion => BibleVersion.fromId(_selectedVersionId);

  // ── Taille de police ───────────────────────────────────────────────────────

  double _fontSize = 18.0;
  double get fontSize => _fontSize;

  void setFontSize(double size) {
    _fontSize = size.clamp(13.0, 26.0);
    _storage.saveBibleFontSize(_fontSize);
    notifyListeners();
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> load() async {
    final ids = await BibleReaderService.instance.downloadedVersionIds();
    _downloadedIds = ids.toSet();

    final savedVersion = await _storage.getBibleVersion();
    if (savedVersion != null && BibleVersion.fromId(savedVersion) != null) {
      _selectedVersionId = savedVersion;
    } else if (_downloadedIds.isNotEmpty) {
      _selectedVersionId = _downloadedIds.first;
    }

    _fontSize = await _storage.getBibleFontSize() ?? 18.0;
    notifyListeners();
  }

  // ── Sélection de version ───────────────────────────────────────────────────

  void selectVersion(String versionId) {
    if (!isDownloaded(versionId)) return;
    _selectedVersionId = versionId;
    _storage.saveBibleVersion(versionId);
    notifyListeners();
  }

  // ── Téléchargement ─────────────────────────────────────────────────────────

  Future<void> downloadVersion(String versionId) async {
    if (isDownloading(versionId) || isDownloaded(versionId)) return;

    _downloadProgress[versionId] = 0.0;
    notifyListeners();

    try {
      await for (final progress
          in BibleReaderService.instance.downloadVersion(versionId)) {
        _downloadProgress[versionId] = progress;
        notifyListeners();
      }
      _downloadedIds.add(versionId);
      // Auto-sélectionner si c'est la première version téléchargée
      if (_downloadedIds.length == 1) {
        _selectedVersionId = versionId;
        _storage.saveBibleVersion(versionId);
      }
    } catch (e) {
      debugPrint('[BibleReaderProvider] Erreur téléchargement $versionId: $e');
      rethrow;
    } finally {
      _downloadProgress.remove(versionId);
      notifyListeners();
    }
  }

  Future<void> deleteVersion(String versionId) async {
    await BibleReaderService.instance.deleteVersion(versionId);
    _downloadedIds.remove(versionId);
    if (_selectedVersionId == versionId && _downloadedIds.isNotEmpty) {
      _selectedVersionId = _downloadedIds.first;
    }
    notifyListeners();
  }
}
