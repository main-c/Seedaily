import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateStatus {
  upToDate,
  softUpdate, // mise à jour disponible, dismissible
  forceUpdate, // version trop ancienne, accès bloqué
}

class UpdateGateService {
  static Future<UpdateStatus> check() async {
    try {
      final config = FirebaseRemoteConfig.instance;

      await config.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await config.setDefaults({
        'min_version': '0.0.0',
        'soft_version': '0.0.0',
      });

      await config.fetchAndActivate();

      final minVersion = config.getString('min_version');
      final softVersion = config.getString('soft_version');
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (_isLower(current, minVersion)) return UpdateStatus.forceUpdate;
      if (_isLower(current, softVersion)) return UpdateStatus.softUpdate;
      return UpdateStatus.upToDate;
    } catch (_) {
      // Remote Config injoignable → on laisse passer, pas bloquant.
      return UpdateStatus.upToDate;
    }
  }

  // Compare deux versions sémantiques "major.minor.patch".
  static bool _isLower(String current, String target) {
    final c = _parse(current);
    final t = _parse(target);
    for (int i = 0; i < 3; i++) {
      if (c[i] < t[i]) return true;
      if (c[i] > t[i]) return false;
    }
    return false;
  }

  static List<int> _parse(String v) {
    final parts = v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    while (parts.length < 3) parts.add(0);
    return parts;
  }
}
