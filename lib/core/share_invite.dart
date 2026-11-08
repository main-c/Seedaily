import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import 'theme.dart';

/// Partage le lien d'invitation d'un groupe (texte unique pour toute l'app).
Future<void> shareGroupInvite(String planTitle, String inviteCode) =>
    Share.share(
      appL10n.planShareMessage(planTitle, AppTheme.joinUrl(inviteCode)),
      subject: appL10n.planShareSubject,
    );
