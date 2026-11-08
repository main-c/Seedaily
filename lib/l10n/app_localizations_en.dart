// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonOk => 'OK';

  @override
  String get commonMe => 'Me';

  @override
  String get commonMember => 'Member';

  @override
  String get commonUser => 'User';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateRequiredBody =>
      'This version is no longer supported. Please update the app to continue.';

  @override
  String get updateAvailableBody =>
      'A new version of Seedaily is available with improvements.';

  @override
  String get updateLater => 'Later';

  @override
  String get updateNow => 'Update';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'APPEARANCE';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsOn => 'On';

  @override
  String get settingsOff => 'Off';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageAuto => 'Automatic';

  @override
  String get settingsLanguageAutoHint => 'Follows the device language';

  @override
  String get settingsSectionReminders => 'REMINDERS';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsSectionBible => 'BIBLE';

  @override
  String get settingsBibleLibrary => 'Bible library';

  @override
  String get settingsBibleLibrarySubtitle => 'Download Bible versions';

  @override
  String get settingsSectionInfo => 'INFORMATION';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsReplayIntro => 'Replay the introduction';

  @override
  String get settingsReplayIntroSubtitle =>
      'Replay the getting-started tutorial';

  @override
  String get settingsSectionAccount => 'ACCOUNT';

  @override
  String get settingsSigningIn => 'Signing in…';

  @override
  String get settingsPleaseWait => 'Please wait';

  @override
  String get settingsSignIn => 'Sign in';

  @override
  String get settingsSignInSubtitle => 'To read in a group with friends';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out?';

  @override
  String get settingsSignOutConfirmBody =>
      'You will be signed out of your reading groups.';

  @override
  String get authErrorFailed =>
      'Sign-in failed. Check your connection or try again.';

  @override
  String get authErrorNetwork => 'No internet connection.';

  @override
  String get authErrorGeneric => 'Unable to sign in. Try again.';
}
