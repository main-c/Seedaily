import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../domain/bible_reader_models.dart';
import '../../providers/bible_reader_provider.dart';

class BibleLibraryScreen extends StatefulWidget {
  const BibleLibraryScreen({super.key});

  @override
  State<BibleLibraryScreen> createState() => _BibleLibraryScreenState();
}

class _BibleLibraryScreenState extends State<BibleLibraryScreen> {
  // Cache des tailles en octets : versionId -> size
  final Map<String, int> _fileSizes = {};

  @override
  void initState() {
    super.initState();
    _fetchFileSizes();
  }

  Future<void> _fetchFileSizes() async {
    for (final version in BibleVersion.available) {
      try {
        final ref = FirebaseStorage.instance.ref(version.storagePath);
        final meta = await ref.getMetadata();
        if (mounted && meta.size != null) {
          setState(() => _fileSizes[version.id] = meta.size!);
        }
      } catch (_) {
        // Taille indisponible — on affiche rien
      }
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final frVersions =
        BibleVersion.available.where((v) => !v.isEnglish).toList();
    final enVersions =
        BibleVersion.available.where((v) => v.isEnglish).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque biblique'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Consumer<BibleReaderProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Téléchargez une version pour lire directement dans l\'app. Toutes les versions sont en domaine public.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ),

              // ── Français ────────────────────────────────────────────────
              _SectionLabel(label: 'Français'),
              const SizedBox(height: 8),
              ...frVersions.map((v) => _VersionCard(
                    version: v,
                    provider: provider,
                    fileSize: _formatSize(_fileSizes[v.id]),
                  )),

              const SizedBox(height: 20),

              // ── English ─────────────────────────────────────────────────
              _SectionLabel(label: 'English'),
              const SizedBox(height: 8),
              ...enVersions.map((v) => _VersionCard(
                    version: v,
                    provider: provider,
                    fileSize: _formatSize(_fileSizes[v.id]),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final BibleVersion version;
  final BibleReaderProvider provider;
  final String fileSize;

  const _VersionCard({
    required this.version,
    required this.provider,
    required this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDownloaded = provider.isDownloaded(version.id);
    final isDownloading = provider.isDownloading(version.id);
    final progress = provider.downloadProgress[version.id] ?? 0.0;
    final isSelected = provider.selectedVersionId == version.id && isDownloaded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? AppTheme.seedGold
              : cs.outline.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDownloaded
                    ? AppTheme.seedGold.withValues(alpha: 0.12)
                    : cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  version.shortName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDownloaded
                        ? AppTheme.seedGold
                        : cs.onSurface.withValues(alpha: 0.35),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    version.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${version.year}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      version.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                  ),
                  if (fileSize.isNotEmpty && !isDownloaded)
                    Text(
                      fileSize,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.35),
                          ),
                    ),
                ],
              ),
            ),
            trailing: _buildTrailing(context, isDownloaded, isDownloading, isSelected),
          ),
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: cs.outline.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.seedGold),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()} %',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, bool isDownloaded,
      bool isDownloading, bool isSelected) {
    if (isDownloading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppTheme.seedGold)),
      );
    }

    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            const Icon(Icons.check_circle, color: AppTheme.seedGold, size: 20)
          else
            TextButton(
              onPressed: () => provider.selectVersion(version.id),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.seedGold,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Utiliser'),
            ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4)),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      );
    }

    return IconButton(
      icon: const Icon(Icons.download_outlined, color: AppTheme.seedGold),
      onPressed: () => _startDownload(context),
    );
  }

  void _startDownload(BuildContext context) async {
    try {
      await provider.downloadVersion(version.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de téléchargement : $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette version ?'),
        content: Text(
            'La version "${version.name}" sera supprimée de l\'appareil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteVersion(version.id);
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
