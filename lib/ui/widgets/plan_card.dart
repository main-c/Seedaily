import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../../core/theme.dart';

/// Liste d'URLs d'images par défaut pour les plans de lecture
/// Ces images sont hébergées sur Unsplash (gratuites pour usage commercial)
class PlanImages {
  static const List<String> defaultImages = [
    'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&q=80', // Montagnes dorées
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80', // Montagnes enneigées
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80', // Montagnes nuageuses
    'https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800&q=80', // Lac et forêt
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80', // Nature soleil
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800&q=80', // Forêt
    'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?w=800&q=80', // Pins
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80', // Collines brumeuses
  ];

  /// Image spécifique pour la Bible ouverte avec lumière
  static const String bibleImage =
      'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=800&q=80';

  /// Retourne une image basée sur le hash de l'ID du plan
  static String getImageForPlan(String planId) {
    final hash = planId.hashCode.abs();
    return defaultImages[hash % defaultImages.length];
  }
}

class PlanCard extends StatelessWidget {
  final GeneratedPlan plan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = plan.progress;
    final streak = plan.currentStreak;
    final isCompleted = progress >= 100;
    final currentDay = plan.completedDays + 1;
    final totalDays = plan.totalDays;
    final endDate = plan.days.isNotEmpty ? plan.days.last.date : DateTime.now();

    // Déterminer le statut du plan
    String statusText;
    Color statusColor;
    if (isCompleted) {
      statusText = 'Terminé';
      statusColor = AppTheme.success;
    } else if (streak == 0 && plan.completedDays > 0) {
      statusText = 'Reprendre';
      statusColor = AppTheme.textMuted;
    } else {
      statusText = '$streak j. de suite';
      statusColor = AppTheme.seedGold;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec badge streak
            Stack(
              children: [
                // Image de fond
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    PlanImages.getImageForPlan(plan.id),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.seedGold.withValues(alpha: 0.3),
                              AppTheme.deepNavy.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.seedGold,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.seedGold.withValues(alpha: 0.3),
                              AppTheme.deepNavy.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 64,
                            color: AppTheme.seedGold.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Badge streak en haut à droite
                if (streak > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.seedGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$streak jours',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Menu options en haut à gauche
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showOptionsMenu(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenu du plan
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et badge statut
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            // Badge statut
                            Row(
                              children: [
                                Icon(
                                  streak > 0
                                      ? Icons.local_fire_department
                                      : Icons.pause_circle_outline,
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Pourcentage
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.seedGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: AppTheme.seedGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Label "Progression"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: AppTheme.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppTheme.success : AppTheme.seedGold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Jour et date de fin + bouton Continuer
                  Row(
                    children: [
                      // Infos jour et date fin
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Jour $currentDay/$totalDays',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fin : ${_formatShortDate(endDate)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Bouton Continuer
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.seedGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isCompleted ? 'Revoir' : 'Continuer',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    final months = [
      '',
      'Jan.',
      'Fév.',
      'Mar.',
      'Avr.',
      'Mai',
      'Jun.',
      'Jul.',
      'Aoû.',
      'Sep.',
      'Oct.',
      'Nov.',
      'Déc.'
    ];
    return '${date.day} ${months[date.month]}';
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.error,
                ),
                title: const Text(
                  'Supprimer le plan',
                  style: TextStyle(color: AppTheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Annuler'),
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le plan'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${plan.title}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
