import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme.dart';
import '../../l10n/l10n.dart';
import 'main_shell_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // APPARENCE
          _buildSectionTitle(l10n.settingsSectionAppearance),
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
                title: l10n.settingsDarkMode,
                subtitle: isDark ? l10n.settingsOn : l10n.settingsOff,
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
          const SizedBox(height: 12),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return _buildSettingCard(
                icon: Icons.language_outlined,
                title: l10n.settingsLanguage,
                subtitle: _languageLabel(l10n, settings.language),
                onTap: () => _pickLanguage(context, settings),
              );
            },
          ),
          const SizedBox(height: 24),

          // RAPPELS
          _buildSectionTitle(l10n.settingsSectionReminders),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return _buildSettingCard(
                icon: Icons.notifications_outlined,
                title: l10n.settingsNotifications,
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
                title: l10n.settingsReminderTime,
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
          _buildSectionTitle(l10n.settingsSectionBible),
          _buildSettingCard(
            icon: Icons.menu_book_outlined,
            title: l10n.settingsBibleLibrary,
            subtitle: l10n.settingsBibleLibrarySubtitle,
            onTap: () => context.push('/bible-library'),
          ),
          const SizedBox(height: 24),

          // INFORMATIONS
          _buildSectionTitle(l10n.settingsSectionInfo),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: l10n.settingsAbout,
            subtitle: 'v${AppTheme.appVersion}',
            onTap: () {
              context.push('/about');
            },
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            icon: Icons.slideshow_outlined,
            title: l10n.settingsReplayIntro,
            subtitle: l10n.settingsReplayIntroSubtitle,
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
          _buildSectionTitle(l10n.settingsSectionAccount),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final Widget content;

              if (auth.isLoading) {
                content = KeyedSubtree(
                  key: const ValueKey('loading'),
                  child: _buildSettingCard(
                    icon: Icons.login_outlined,
                    title: l10n.settingsSigningIn,
                    subtitle: l10n.settingsPleaseWait,
                    trailing: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    onTap: () {},
                  ),
                );
              } else if (!auth.isSignedIn) {
                content = KeyedSubtree(
                  key: const ValueKey('signedOut'),
                  child: _buildSettingCard(
                    icon: Icons.login_outlined,
                    title: l10n.settingsSignIn,
                    subtitle: auth.error != null
                        ? _authErrorText(l10n, auth.error!)
                        : l10n.settingsSignInSubtitle,
                    subtitleColor: auth.error != null ? Colors.red.shade600 : null,
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final ok = await auth.signInWithGoogle();
                      if (!ok && auth.error != null && mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(_authErrorText(l10n, auth.error!))),
                        );
                      }
                    },
                  ),
                );
              } else {
                content = Column(
                  key: const ValueKey('signedIn'),
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
                      title: l10n.settingsSignOut,
                      titleColor: Colors.red.shade600,
                      onTap: () => _confirmSignOut(context, auth),
                    ),
                  ],
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: content,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _authErrorText(AppLocalizations l10n, AuthError error) =>
      switch (error) {
        AuthError.failed => l10n.authErrorFailed,
        AuthError.network => l10n.authErrorNetwork,
        AuthError.generic => l10n.authErrorGeneric,
      };

  // Noms de langue volontairement non traduits (chacun dans sa langue).
  String _languageLabel(AppLocalizations l10n, String language) =>
      switch (language) {
        'fr' => 'Français',
        'en' => 'English',
        _ => l10n.settingsLanguageAuto,
      };

  void _pickLanguage(BuildContext context, SettingsProvider settings) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsLanguage),
        children: [
          for (final language in const [kLanguageAuto, 'fr', 'en'])
            ListTile(
              title: Text(_languageLabel(l10n, language)),
              subtitle: language == kLanguageAuto
                  ? Text(l10n.settingsLanguageAutoHint)
                  : null,
              trailing: settings.language == language
                  ? const Icon(Icons.check, color: AppTheme.seedGold)
                  : null,
              onTap: () {
                Navigator.pop(dialogContext);
                settings.setLanguage(language);
              },
            ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.settingsSignOutConfirmTitle),
        content: Text(l10n.settingsSignOutConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
            },
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: Text(l10n.settingsSignOut,
                style: const TextStyle(color: Colors.white)),
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
