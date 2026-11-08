import '../providers/groups_provider.dart';
import 'app_localizations.dart';

/// Traduit le code d'erreur de [GroupsProvider] ; [fallback] si aucun code.
String groupsErrorText(
    AppLocalizations l10n, GroupsError? error, String fallback) {
  return switch (error) {
    GroupsError.load => l10n.groupsErrorLoad,
    GroupsError.create => l10n.groupsErrorCreate,
    GroupsError.invalidCode => l10n.groupsErrorInvalidCode,
    GroupsError.join => l10n.groupsErrorJoin,
    GroupsError.leave => l10n.groupsErrorLeave,
    GroupsError.delete => l10n.groupsErrorDelete,
    null => fallback,
  };
}
