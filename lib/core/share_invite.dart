import 'package:share_plus/share_plus.dart';

import 'theme.dart';

/// Partage le lien d'invitation d'un groupe (texte unique pour toute l'app).
Future<void> shareGroupInvite(String planTitle, String inviteCode) =>
    Share.share(
      'Je lis "$planTitle" sur Seedaily et j\'aimerais qu\'on le lise ensemble 🙏\n\n'
      '${AppTheme.joinUrl(inviteCode)}',
      subject: 'Lire la Bible ensemble',
    );
