import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme.dart';
import 'main_shell_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // APPARENCE
          _buildSectionTitle('APPARENCE'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final brightness = MediaQuery.of(context).platformBrightness;
              final isDark = settings.themeMode == ThemeMode.dark ||
                  (settings.themeMode == ThemeMode.system &&
                      brightness == Brightness.dark);
              return _buildSettingCard(
                icon: isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'Mode sombre',
                subtitle: isDark ? 'Activé' : 'Désactivé',
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    settings.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeThumbColor: Theme.of(context).colorScheme.surface,
                ),
                onTap: () {},
              );
            },
          ),
          const SizedBox(height: 24),

          // RAPPELS
          _buildSectionTitle('RAPPELS'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return _buildSettingCard(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    settings.setNotificationsEnabled(value);
                  },
                  activeThumbColor: Theme.of(context).colorScheme.surface,
                ),
                onTap: () {},
              );
            },
          ),
          const SizedBox(height: 12),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              final time = settings.notificationTime;
              final timeStr =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

              return _buildSettingCard(
                icon: Icons.access_time_outlined,
                title: 'Heure de rappel',
                subtitle: timeStr,
                subtitleColor: AppTheme.seedGold,
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(time),
                  );

                  if (selectedTime != null) {
                    final now = DateTime.now();
                    final dateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    settings.setNotificationTime(dateTime);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          // Consumer<SettingsProvider>(
          //   builder: (context, settings, child) {
          //     return _buildSettingCard(
          //       icon: Icons.notification_add_outlined,
          //       title: 'Tester une notification',
          //       subtitle: 'Aperçu du rappel quotidien',
          //       titleColor: AppTheme.seedGold,
          //       onTap: () => settings.showTestNotification(),
          //     );
          //   },
          // ),
          const SizedBox(height: 24),
          // PRÉFÉRENCES
          // _buildSectionTitle('PRÉFÉRENCES'),
          // _buildSettingCard(
          //   icon: Icons.menu_book_outlined,
          //   title: 'Version de la Bible',
          //   subtitle: 'Louis Segond',
          //   onTap: () {},
          // ),
          // const SizedBox(height: 12),
          // _buildSettingCard(
          //   icon: Icons.language_outlined,
          //   title: 'Langue',
          //   subtitle: 'Français',
          //   onTap: () {},
          // ),
          // const SizedBox(height: 24),

          // BIBLE
          _buildSectionTitle('BIBLE'),
          _buildSettingCard(
            icon: Icons.menu_book_outlined,
            title: 'Bibliothèque biblique',
            subtitle: 'Télécharger les versions de la Bible',
            onTap: () => context.push('/bible-library'),
          ),
          const SizedBox(height: 24),

          // INFORMATIONS
          _buildSectionTitle('INFORMATIONS'),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'À propos',
            subtitle: 'v${AppTheme.appVersion}',
            onTap: () {
              context.push('/about');
            },
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            icon: Icons.slideshow_outlined,
            title: 'Revoir l\'introduction',
            subtitle: 'Rejouer le tutoriel de démarrage',
            onTap: () {
              mainShellKey.currentState?.startTour(context, force: true);
            },
          ),
          const SizedBox(height: 12),
          // _buildSettingCard(
          //   icon: Icons.download_outline,
          //   title: 'Exporter les données',
          //   titleColor: AppTheme.seedGold,
          //   onTap: () {},
          // ),
          const SizedBox(height: 24),

          // COMPTE
          _buildSectionTitle('COMPTE'),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (!auth.isSignedIn) {
                return _buildSettingCard(
                  icon: Icons.login_outlined,
                  title: 'Se connecter',
                  subtitle: 'Pour lire en groupe avec des amis',
                  onTap: () async { await auth.signInWithGoogle(); },
                );
              }
              return Column(
                children: [
                  _buildSettingCard(
                    icon: Icons.person_outline,
                    title: auth.displayName,
                    subtitle: auth.user?.email ?? '',
                    trailing: auth.avatarUrl != null
                        ? CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(auth.avatarUrl!),
                          )
                        : const SizedBox.shrink(),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingCard(
                    icon: Icons.logout,
                    title: 'Se déconnecter',
                    titleColor: Colors.red.shade600,
                    onTap: () => _confirmSignOut(context, auth),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
            'Vous serez déconnecté de vos groupes de lecture.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Se déconnecter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style:  TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icône
              Icon(
                icon,
                size: 24,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),

              // Titre et sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? cs.onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor ?? cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ), 

              // Trailing (chevron ou switch)
              if (trailing != null)
                trailing
              else
                Icon(
                  Icons.chevron_right,
                  color: cs.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
