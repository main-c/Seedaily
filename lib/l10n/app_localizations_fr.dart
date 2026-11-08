// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonOk => 'OK';

  @override
  String get commonMe => 'Moi';

  @override
  String get commonMember => 'Membre';

  @override
  String get commonUser => 'Utilisateur';

  @override
  String get updateRequiredTitle => 'Mise à jour requise';

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String get updateRequiredBody =>
      'Cette version n\'est plus supportée. Merci de mettre à jour l\'application pour continuer.';

  @override
  String get updateAvailableBody =>
      'Une nouvelle version de Seedaily est disponible avec des améliorations.';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateNow => 'Mettre à jour';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionAppearance => 'APPARENCE';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsOn => 'Activé';

  @override
  String get settingsOff => 'Désactivé';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageAuto => 'Automatique';

  @override
  String get settingsLanguageAutoHint => 'Suit la langue de l\'appareil';

  @override
  String get settingsSectionReminders => 'RAPPELS';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsReminderTime => 'Heure de rappel';

  @override
  String get settingsSectionBible => 'BIBLE';

  @override
  String get settingsBibleLibrary => 'Bibliothèque biblique';

  @override
  String get settingsBibleLibrarySubtitle =>
      'Télécharger les versions de la Bible';

  @override
  String get settingsSectionInfo => 'INFORMATIONS';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsReplayIntro => 'Revoir l\'introduction';

  @override
  String get settingsReplayIntroSubtitle => 'Rejouer le tutoriel de démarrage';

  @override
  String get settingsSectionAccount => 'COMPTE';

  @override
  String get settingsSigningIn => 'Connexion en cours…';

  @override
  String get settingsPleaseWait => 'Veuillez patienter';

  @override
  String get settingsSignIn => 'Se connecter';

  @override
  String get settingsSignInSubtitle => 'Pour lire en groupe avec des amis';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get settingsSignOutConfirmBody =>
      'Vous serez déconnecté de vos groupes de lecture.';

  @override
  String get authErrorFailed =>
      'Connexion échouée. Vérifiez votre connexion ou réessayez.';

  @override
  String get authErrorNetwork => 'Pas de connexion internet.';

  @override
  String get authErrorGeneric => 'Connexion impossible. Réessayez.';
}
