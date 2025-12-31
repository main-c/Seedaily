import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'Notifications',
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return SwitchListTile(
                    title: const Text('Activer les notifications'),
                    subtitle: const Text('Rappels quotidiens de lecture'),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settings.setNotificationsEnabled(value);
                    },
                    activeColor: AppTheme.seedGold,
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  if (!settings.notificationsEnabled) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: const Text('Heure du rappel'),
                    subtitle: Text(
                      '${settings.notificationTime.hour.toString().padLeft(2, '0')}:${settings.notificationTime.minute.toString().padLeft(2, '0')}',
                    ),
                    leading: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          settings.notificationTime,
                        ),
                      );

                      if (time != null) {
                        final now = DateTime.now();
                        final dateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          time.hour,
                          time.minute,
                        );
                        settings.setNotificationTime(dateTime);
                      }
                    },
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'À propos',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                leading: const Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('Seedaily'),
                subtitle: const Text(
                  'Application de génération de plans de lecture biblique',
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.seedGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: AppTheme.seedGold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
