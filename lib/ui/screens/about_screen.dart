import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Seedaily est une application de génération de plans de lecture biblique personnalisés. '
      'Créez votre propre parcours de lecture adapté à votre rythme et vos objectifs spirituels.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Logo et nom de l'app
          _buildAppHeader(context),
          const SizedBox(height: 32),

          // Description
          _buildSection(
            context,
            title: 'Description',
            child: Text(
              appDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // Fonctionnalités
          _buildSection(
            context,
            title: 'Fonctionnalités',
            child: Column(
              children: [
                _buildFeatureItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  text: 'Plans de lecture personnalisables',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.notifications_outlined,
                  text: 'Rappels quotidiens',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.track_changes_outlined,
                  text: 'Suivi de progression',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.picture_as_pdf_outlined,
                  text: 'Export PDF et partage',
                ),
                _buildFeatureItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  text: 'Multiples formats de lecture',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Liens utiles
          _buildSection(
            context,
            title: 'Liens',
            child: Column(
              children: [
                // _buildLinkItem(
                //   context,
                //   icon: Icons.privacy_tip_outlined,
                //   title: 'Politique de confidentialité',
                //   onTap: () => _showUrlAction(context, 'https://seedaily.app/privacy'),
                // ),
                // _buildLinkItem(
                //   context,
                //   icon: Icons.description_outlined,
                //   title: 'Conditions d\'utilisation',
                //   onTap: () => _showUrlAction(context, 'https://seedaily.app/terms'),
                // ),
                _buildLinkItem(
                  context,
                  icon: Icons.star_outline,
                  title: 'Noter l\'application',
                  onTap: () => _showUrlAction(context, 'https://play.google.com/store/apps/details?id=com.seedaily.app'),
                ),
                _buildLinkItem(
                  context,
                  icon: Icons.bug_report_outlined,
                  title: 'Signaler un bug',
                  onTap: () => _showUrlAction(context, 'mailto:yannik.kadjie@gmail.app'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Crédits
          _buildSection(
            context,
            title: 'Crédits',
            child: Text(
              'Développé par Yannik KADJIE.\n'
              'Image  : Unsplash.\n',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: 32),

          // Copyright
          Center(
            child: Text(
              '© ${DateTime.now().year} Seedaily. Tous droits réservés.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Column(
      children: [
        // Logo/Icône
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.seedGold,
                Color(0xFFD4A84B),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.seedGold.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Nom de l'app
        Text(
          'Seedaily',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.deepNavy,
              ),
        ),
        const SizedBox(height: 8),

        // Version
        GestureDetector(
          onLongPress: () {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Build: 1.0.0+1 • Flutter 3.x'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.seedGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Version $appVersion',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.seedGold,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.seedGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.seedGold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.deepNavy,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: AppTheme.deepNavy.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.deepNavy,
                      ),
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 18,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUrlAction(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lien copié : $url'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
