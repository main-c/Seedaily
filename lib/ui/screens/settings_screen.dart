import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          _buildSettingCard(
            icon: Icons.brightness_4_outlined,
            title: 'Thème',
            subtitle: 'Système',
            onTap: () {},
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
                 
                  activeThumbColor: AppTheme.surface,
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
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return _buildSettingCard(
                icon: Icons.notification_add_outlined,
                title: 'Tester une notification',
                subtitle: 'Aperçu du rappel quotidien',
                titleColor: AppTheme.seedGold,
                onTap: () => settings.showTestNotification(),
              );
            },
          ),
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

          // INFORMATIONS
          _buildSectionTitle('INFORMATIONS'),
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'À propos',
            subtitle: 'v2.4.0',
            onTap: () {
              context.push('/about');
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
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
    return Material(
      color: AppTheme.surface,
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
                color: AppTheme.deepNavy.withOpacity(0.7),
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
                        color: titleColor ?? AppTheme.deepNavy,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor ?? AppTheme.textMuted,
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
                  color: AppTheme.borderSubtle,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
