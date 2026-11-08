import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonOk.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonMe.
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get commonMe;

  /// No description provided for @commonMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get commonMember;

  /// No description provided for @commonUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get commonUser;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour requise'**
  String get updateRequiredTitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour disponible'**
  String get updateAvailableTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette version n\'est plus supportée. Merci de mettre à jour l\'application pour continuer.'**
  String get updateRequiredBody;

  /// No description provided for @updateAvailableBody.
  ///
  /// In fr, this message translates to:
  /// **'Une nouvelle version de Seedaily est disponible avec des améliorations.'**
  String get updateAvailableBody;

  /// No description provided for @updateLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get updateLater;

  /// No description provided for @updateNow.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get updateNow;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In fr, this message translates to:
  /// **'APPARENCE'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get settingsDarkMode;

  /// No description provided for @settingsOn.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get settingsOff;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get settingsLanguageAuto;

  /// No description provided for @settingsLanguageAutoHint.
  ///
  /// In fr, this message translates to:
  /// **'Suit la langue de l\'appareil'**
  String get settingsLanguageAutoHint;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In fr, this message translates to:
  /// **'RAPPELS'**
  String get settingsSectionReminders;

  /// No description provided for @settingsNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsReminderTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure de rappel'**
  String get settingsReminderTime;

  /// No description provided for @settingsSectionBible.
  ///
  /// In fr, this message translates to:
  /// **'BIBLE'**
  String get settingsSectionBible;

  /// No description provided for @settingsBibleLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque biblique'**
  String get settingsBibleLibrary;

  /// No description provided for @settingsBibleLibrarySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger les versions de la Bible'**
  String get settingsBibleLibrarySubtitle;

  /// No description provided for @settingsSectionInfo.
  ///
  /// In fr, this message translates to:
  /// **'INFORMATIONS'**
  String get settingsSectionInfo;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsReplayIntro.
  ///
  /// In fr, this message translates to:
  /// **'Revoir l\'introduction'**
  String get settingsReplayIntro;

  /// No description provided for @settingsReplayIntroSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejouer le tutoriel de démarrage'**
  String get settingsReplayIntroSubtitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In fr, this message translates to:
  /// **'COMPTE'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSigningIn.
  ///
  /// In fr, this message translates to:
  /// **'Connexion en cours…'**
  String get settingsSigningIn;

  /// No description provided for @settingsPleaseWait.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter'**
  String get settingsPleaseWait;

  /// No description provided for @settingsSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get settingsSignIn;

  /// No description provided for @settingsSignInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour lire en groupe avec des amis'**
  String get settingsSignInSubtitle;

  /// No description provided for @settingsSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get settingsSignOutConfirmTitle;

  /// No description provided for @settingsSignOutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez déconnecté de vos groupes de lecture.'**
  String get settingsSignOutConfirmBody;

  /// No description provided for @authErrorFailed.
  ///
  /// In fr, this message translates to:
  /// **'Connexion échouée. Vérifiez votre connexion ou réessayez.'**
  String get authErrorFailed;

  /// No description provided for @authErrorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Réessayez.'**
  String get authErrorGeneric;

  /// No description provided for @widgetNoPlan.
  ///
  /// In fr, this message translates to:
  /// **'Créez un plan de lecture pour commencer'**
  String get widgetNoPlan;

  /// No description provided for @widgetReadToday.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du jour terminée. A demain !'**
  String get widgetReadToday;

  /// No description provided for @widgetStreakAmazing.
  ///
  /// In fr, this message translates to:
  /// **'Incroyable : {n} jours de suite !'**
  String widgetStreakAmazing(int n);

  /// No description provided for @widgetStreakGood.
  ///
  /// In fr, this message translates to:
  /// **'{n} jours de suite. Continuez !'**
  String widgetStreakGood(int n);

  /// No description provided for @widgetStreakDay.
  ///
  /// In fr, this message translates to:
  /// **'Jour {n}. Restez dans le rythme !'**
  String widgetStreakDay(int n);

  /// No description provided for @widgetReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêt pour ta lecture du jour ?'**
  String get widgetReady;

  /// No description provided for @widgetStreakLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{jour} other{jours}}'**
  String widgetStreakLabel(int count);

  /// No description provided for @widgetBadgeRead.
  ///
  /// In fr, this message translates to:
  /// **'Lu'**
  String get widgetBadgeRead;

  /// No description provided for @widgetSectionToday.
  ///
  /// In fr, this message translates to:
  /// **'Pour aujourd\'hui'**
  String get widgetSectionToday;

  /// No description provided for @widgetSectionNext.
  ///
  /// In fr, this message translates to:
  /// **'Prochain passage'**
  String get widgetSectionNext;

  /// No description provided for @widgetEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ouvre Seedaily pour commencer'**
  String get widgetEmpty;

  /// No description provided for @widgetDayLabels.
  ///
  /// In fr, this message translates to:
  /// **'LMMJVSD'**
  String get widgetDayLabels;

  /// No description provided for @notifActionViewPlans.
  ///
  /// In fr, this message translates to:
  /// **'Voir mes plans'**
  String get notifActionViewPlans;

  /// No description provided for @notifActionCreatePlan.
  ///
  /// In fr, this message translates to:
  /// **'Créer un plan'**
  String get notifActionCreatePlan;

  /// No description provided for @notifChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Lecture quotidienne'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Rappels quotidiens pour votre lecture biblique'**
  String get notifChannelDescription;

  /// No description provided for @notifOpenApp.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir Seedaily'**
  String get notifOpenApp;

  /// No description provided for @notifDailyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du Jour'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyTitleStreak.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du Jour · 🔥{n} jours'**
  String notifDailyTitleStreak(int n);

  /// No description provided for @notifEveningBehind.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Tu as {n} jours de retard. Un petit effort ce soir?'**
  String notifEveningBehind(int n);

  /// No description provided for @notifEveningNotRead.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Tu n\'as pas encore lu aujourd\'hui. Prends quelques minutes!'**
  String get notifEveningNotRead;

  /// No description provided for @notifGeneric1.
  ///
  /// In fr, this message translates to:
  /// **'10 minutes aujourd\'hui peuvent nourrir toute ta journée 🌱'**
  String get notifGeneric1;

  /// No description provided for @notifGeneric2.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau chapitre t\'attend aujourd\'hui 📖'**
  String get notifGeneric2;

  /// No description provided for @notifGeneric3.
  ///
  /// In fr, this message translates to:
  /// **'Prêt pour ta lecture du jour ? 🙏'**
  String get notifGeneric3;

  /// No description provided for @notifGeneric4.
  ///
  /// In fr, this message translates to:
  /// **'La Parole te nourrit chaque jour ✨'**
  String get notifGeneric4;

  /// No description provided for @notifGeneric5.
  ///
  /// In fr, this message translates to:
  /// **'Continue ton parcours, tu progresses bien 💪'**
  String get notifGeneric5;

  /// No description provided for @notifGeneric6.
  ///
  /// In fr, this message translates to:
  /// **'Un moment avec Dieu aujourd\'hui ? 🕊️'**
  String get notifGeneric6;

  /// No description provided for @notifGeneric7.
  ///
  /// In fr, this message translates to:
  /// **'Ta lecture quotidienne est prête 📖'**
  String get notifGeneric7;

  /// No description provided for @notifGeneric8.
  ///
  /// In fr, this message translates to:
  /// **'Garde le cap, tu es sur la bonne voie 🌟'**
  String get notifGeneric8;

  /// No description provided for @notifUrgent1.
  ///
  /// In fr, this message translates to:
  /// **'Tu as {n} jours de retard. Commence par un seul chapitre ! ⚡'**
  String notifUrgent1(int n);

  /// No description provided for @notifUrgent2.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ {n} jours non lus t\'attendent. Un petit pas aujourd\'hui ?'**
  String notifUrgent2(int n);

  /// No description provided for @notifUrgent3.
  ///
  /// In fr, this message translates to:
  /// **'Le retard s\'accumule ({n} jours). Un effort aujourd\'hui ? 💪'**
  String notifUrgent3(int n);

  /// No description provided for @notifUrgent4.
  ///
  /// In fr, this message translates to:
  /// **'Tu es à {n} jours du rythme. La Parole t\'attend ! ⚠️'**
  String notifUrgent4(int n);

  /// No description provided for @notifCatchup1.
  ///
  /// In fr, this message translates to:
  /// **'Encore un effort et tu rattrapes ton plan ! 🎯'**
  String get notifCatchup1;

  /// No description provided for @notifCatchup2.
  ///
  /// In fr, this message translates to:
  /// **'Un chapitre aujourd\'hui et tu es presque à jour 📖'**
  String get notifCatchup2;

  /// No description provided for @notifCatchup3.
  ///
  /// In fr, this message translates to:
  /// **'La régularité vient avec la pratique. Tu peux le faire ! 💪'**
  String get notifCatchup3;

  /// No description provided for @notifCatchup4.
  ///
  /// In fr, this message translates to:
  /// **'Presque rattrapé — continue sur ta lancée ! 🔥'**
  String get notifCatchup4;

  /// No description provided for @notifOnTrack1.
  ///
  /// In fr, this message translates to:
  /// **'Tu es dans le rythme. La Parole t\'attend ! ✨'**
  String get notifOnTrack1;

  /// No description provided for @notifOnTrack2.
  ///
  /// In fr, this message translates to:
  /// **'Parfait, tu es à jour. Continue comme ça ! 🌟'**
  String get notifOnTrack2;

  /// No description provided for @notifOnTrack3.
  ///
  /// In fr, this message translates to:
  /// **'Un nouveau chapitre t\'attend aujourd\'hui 📖'**
  String get notifOnTrack3;

  /// No description provided for @notifOnTrack4.
  ///
  /// In fr, this message translates to:
  /// **'Tu es fidèle à ton plan. Bravo ! 🙌'**
  String get notifOnTrack4;

  /// No description provided for @notifPraise1.
  ///
  /// In fr, this message translates to:
  /// **'Impressionnant ! Tu es en avance de {n} jour(s) 🏆'**
  String notifPraise1(int n);

  /// No description provided for @notifPraise2.
  ///
  /// In fr, this message translates to:
  /// **'Tu es {n} jour(s) en avance sur ton plan. Continue ! 🌟'**
  String notifPraise2(int n);

  /// No description provided for @notifPraise3.
  ///
  /// In fr, this message translates to:
  /// **'En avance de {n} jour(s) ! Tu es une inspiration ✨'**
  String notifPraise3(int n);

  /// No description provided for @notifPraise4.
  ///
  /// In fr, this message translates to:
  /// **'Quel rythme ! {n} jour(s) d\'avance. Garde le cap ! 🔥'**
  String notifPraise4(int n);

  /// No description provided for @templateCanonicalPlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan Canonique'**
  String get templateCanonicalPlanTitle;

  /// No description provided for @templateCanonicalPlanDescription.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de toute la Bible dans l’ordre traditionnel de Genèse a Apocalypse.'**
  String get templateCanonicalPlanDescription;

  /// No description provided for @templateCanonicalPlanDetails.
  ///
  /// In fr, this message translates to:
  /// **'Ce plan suit l’ordre classique des livres bibliques tel que présenté dans la plupart des Bibles chrétiennes.\nVous pouvez modifier la durée (6 mois, 1 an, 2 ans…), sélectionner certains livres seulement, ou choisir vos jours de lecture.\nIdéal comme base flexible pour construire votre propre parcours complet.'**
  String get templateCanonicalPlanDetails;

  /// No description provided for @templateChronologicalPlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan Chronologique'**
  String get templateChronologicalPlanTitle;

  /// No description provided for @templateChronologicalPlanDescription.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de la Bible selon l’ordre historique des événements et de rédaction.'**
  String get templateChronologicalPlanDescription;

  /// No description provided for @templateChronologicalPlanDetails.
  ///
  /// In fr, this message translates to:
  /// **'Ce plan replace les livres et passages dans leur contexte historique présumé afin de mieux comprendre la progression de l’histoire biblique.\nParfait pour suivre le fil narratif de la révélation biblique.\nVous pouvez ajuster la durée, retirer ou ajouter des livres selon votre objectif d’étude.'**
  String get templateChronologicalPlanDetails;

  /// No description provided for @templateNewTestamentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Testament'**
  String get templateNewTestamentTitle;

  /// No description provided for @templateNewTestamentDescription.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez la vie de Jésus, la naissance de l’Église et l’enseignement apostolique.'**
  String get templateNewTestamentDescription;

  /// No description provided for @templateNewTestamentDetails.
  ///
  /// In fr, this message translates to:
  /// **'Les 27 livres du Nouveau Testament dans un parcours adaptable à votre rythme.\nVous pouvez lire en format intensif (30 jours) ou progressif (3 à 6 mois).'**
  String get templateNewTestamentDetails;

  /// No description provided for @templateOldTestamentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ancien Testament'**
  String get templateOldTestamentTitle;

  /// No description provided for @templateOldTestamentDescription.
  ///
  /// In fr, this message translates to:
  /// **'Explorez la Loi, l’histoire d’Israël, les livres poétiques et les prophètes.'**
  String get templateOldTestamentDescription;

  /// No description provided for @templateOldTestamentDetails.
  ///
  /// In fr, this message translates to:
  /// **'Les 39 livres de l’Ancien Testament, ajustables selon votre durée.\n              Vous pouvez sélectionner uniquement certaines sections.'**
  String get templateOldTestamentDetails;

  /// No description provided for @templateGospelsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les Évangiles'**
  String get templateGospelsTitle;

  /// No description provided for @templateGospelsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Matthieu, Marc, Luc et Jean dans un parcours centré sur la vie de Jésus.'**
  String get templateGospelsDescription;

  /// No description provided for @templateGospelsDetails.
  ///
  /// In fr, this message translates to:
  /// **'Idéal pour découvrir ou redécouvrir la personne et l’œuvre du Christ.\nVous pouvez compléter avec le livre des Actes ou adapter la durée (2 semaines à 3 mois).\nParfait pour un groupe de croissance ou un nouveau croyant.'**
  String get templateGospelsDetails;

  /// No description provided for @templatePsalmsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les Psaumes'**
  String get templatePsalmsTitle;

  /// No description provided for @templatePsalmsDescription.
  ///
  /// In fr, this message translates to:
  /// **'150 psaumes pour nourrir la prière et la méditation.'**
  String get templatePsalmsDescription;

  /// No description provided for @templatePsalmsDetails.
  ///
  /// In fr, this message translates to:
  /// **'Un parcours spirituel centré sur l’adoration, la repentance et la confiance en Dieu.\nChoisissez votre rythme : 1 psaume par jour ou plusieurs par lecture.\nPeut être combiné avec Proverbes pour un équilibre entre prière et sagesse.'**
  String get templatePsalmsDetails;

  /// No description provided for @templateProverbsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les Proverbes'**
  String get templateProverbsTitle;

  /// No description provided for @templateProverbsDescription.
  ///
  /// In fr, this message translates to:
  /// **'31 chapitres de sagesse pratique pour la vie quotidienne.'**
  String get templateProverbsDescription;

  /// No description provided for @templateProverbsDetails.
  ///
  /// In fr, this message translates to:
  /// **'Un plan idéal pour une lecture mensuelle (1 chapitre par jour).\nPeut être associé à Ecclésiaste ou Cantique des cantiques pour approfondir la littérature sapientielle.\nSimple, court et applicable immédiatement.'**
  String get templateProverbsDetails;

  /// No description provided for @templateMcheyneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan M\'Cheyne'**
  String get templateMcheyneTitle;

  /// No description provided for @templateMcheyneDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une lecture parallèle de l’Ancien et du Nouveau Testament.'**
  String get templateMcheyneDescription;

  /// No description provided for @templateMcheyneDetails.
  ///
  /// In fr, this message translates to:
  /// **'Créé par Robert Murray M’Cheyne, ce plan propose une lecture parallèle de l’Ancien et du Nouveau Testament.\nLes passages sont prédéfinis et suivent la structure originale.\nVous choisissez simplement la date de début.'**
  String get templateMcheyneDetails;

  /// No description provided for @templateBibleYearLigueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bible en 1 an (Ligue)'**
  String get templateBibleYearLigueTitle;

  /// No description provided for @templateBibleYearLigueDescription.
  ///
  /// In fr, this message translates to:
  /// **'Lecture quotidienne équilibrée de l\'ancien testament, les Psaumes, Les Proverbes et du nouveau testament'**
  String get templateBibleYearLigueDescription;

  /// No description provided for @templateBibleYearLigueDetails.
  ///
  /// In fr, this message translates to:
  /// **'Chaque jour propose un passage de l’Ancien Testament, un Psaume, un Proverbe et un passage du Nouveau Testament.\nPlan structuré et prédéfini, idéal pour une lecture communautaire en Église.'**
  String get templateBibleYearLigueDetails;

  /// No description provided for @templateRevolutionaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan révolutionnaire'**
  String get templateRevolutionaryTitle;

  /// No description provided for @templateRevolutionaryDescription.
  ///
  /// In fr, this message translates to:
  /// **'25 lectures par mois avec jours de repos intégrés..'**
  String get templateRevolutionaryDescription;

  /// No description provided for @templateRevolutionaryDetails.
  ///
  /// In fr, this message translates to:
  /// **'Plan structuré pour favoriser la régularité sans surcharge.\nLes jours de pause permettent de rattraper ou méditer.\nStructure fixe : il suffit de choisir votre date de départ.'**
  String get templateRevolutionaryDetails;

  /// No description provided for @templateHornerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan Horner'**
  String get templateHornerTitle;

  /// No description provided for @templateHornerDescription.
  ///
  /// In fr, this message translates to:
  /// **'Méthode intensive : 10 chapitres par jour en lectures parallèles.'**
  String get templateHornerDescription;

  /// No description provided for @templateHornerDetails.
  ///
  /// In fr, this message translates to:
  /// **'Conçu par le Professeur Grant Horner, ce plan divise la Bible en 10 listes distinctes lues simultanément.\nTrès exigeant, il favorise l’immersion et la répétition des textes.\nStructure entièrement prédéfinie.'**
  String get templateHornerDetails;

  /// No description provided for @pdfTagline.
  ///
  /// In fr, this message translates to:
  /// **'Générez vos plans de lecture biblique'**
  String get pdfTagline;

  /// No description provided for @pdfReadingDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour de lecture} other{{count} jours de lecture}}'**
  String pdfReadingDays(int count);

  /// No description provided for @pdfGeneratedWith.
  ///
  /// In fr, this message translates to:
  /// **'Généré avec {app}'**
  String pdfGeneratedWith(String app);

  /// No description provided for @pdfMonthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan de Lecture - {month}'**
  String pdfMonthTitle(String month);

  /// No description provided for @pdfWeekDays.
  ///
  /// In fr, this message translates to:
  /// **'LUN,MAR,MER,JEU,VEN,SAM,DIM'**
  String get pdfWeekDays;

  /// No description provided for @pdfGenreGospelsActs.
  ///
  /// In fr, this message translates to:
  /// **'Évangiles & Actes'**
  String get pdfGenreGospelsActs;

  /// No description provided for @pdfGenreEpistles.
  ///
  /// In fr, this message translates to:
  /// **'Épîtres'**
  String get pdfGenreEpistles;

  /// No description provided for @pdfGenreRevelation.
  ///
  /// In fr, this message translates to:
  /// **'Apocalypse'**
  String get pdfGenreRevelation;

  /// No description provided for @pdfGenreLaw.
  ///
  /// In fr, this message translates to:
  /// **'Loi / Torah'**
  String get pdfGenreLaw;

  /// No description provided for @pdfGenreHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historiques'**
  String get pdfGenreHistory;

  /// No description provided for @pdfGenreWisdom.
  ///
  /// In fr, this message translates to:
  /// **'Sapientiaux'**
  String get pdfGenreWisdom;

  /// No description provided for @pdfGenreProphets.
  ///
  /// In fr, this message translates to:
  /// **'Prophètes'**
  String get pdfGenreProphets;

  /// No description provided for @bibleVersionLsgDescription.
  ///
  /// In fr, this message translates to:
  /// **'Traduction classique, la plus répandue en France'**
  String get bibleVersionLsgDescription;

  /// No description provided for @bibleVersionMartinDescription.
  ///
  /// In fr, this message translates to:
  /// **'Traduction de David Martin, fidèle au texte reçu'**
  String get bibleVersionMartinDescription;

  /// No description provided for @bibleVersionOstervaldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Révision d\'Ostervald, style classique'**
  String get bibleVersionOstervaldDescription;

  /// No description provided for @bibleVersionEpeeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Traduction moderne fidèle à l\'original'**
  String get bibleVersionEpeeDescription;

  /// No description provided for @bibleVersionKjvDescription.
  ///
  /// In fr, this message translates to:
  /// **'Traduction anglaise classique, domaine public'**
  String get bibleVersionKjvDescription;

  /// No description provided for @bibleVersionAsvDescription.
  ///
  /// In fr, this message translates to:
  /// **'Révision américaine de la KJV, domaine public'**
  String get bibleVersionAsvDescription;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @percent.
  ///
  /// In fr, this message translates to:
  /// **'{n} %'**
  String percent(int n);

  /// No description provided for @dayOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'Jour {day} sur {total}'**
  String dayOfTotal(int day, int total);

  /// No description provided for @groupsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get groupsTitle;

  /// No description provided for @groupsSignInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture en groupe'**
  String get groupsSignInTitle;

  /// No description provided for @groupsSignInBody.
  ///
  /// In fr, this message translates to:
  /// **'Lisez avec vos proches et votre communauté. Connectez-vous pour créer ou rejoindre un groupe.'**
  String get groupsSignInBody;

  /// No description provided for @groupsSigningIn.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get groupsSigningIn;

  /// No description provided for @groupsContinueWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get groupsContinueWithGoogle;

  /// No description provided for @groupsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe pour l\'instant'**
  String get groupsEmptyTitle;

  /// No description provided for @groupsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un plan dans Découvrir, puis sélectionnez \"Avec des amis\" pour lire avec votre communauté.'**
  String get groupsEmptyMessage;

  /// No description provided for @groupsEmptyAction.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir des plans'**
  String get groupsEmptyAction;

  /// No description provided for @groupsNewGroupPlan.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau plan de groupe'**
  String get groupsNewGroupPlan;

  /// No description provided for @groupsBadge.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get groupsBadge;

  /// No description provided for @groupDetailLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le groupe.'**
  String get groupDetailLoadError;

  /// No description provided for @groupDetailBackHome.
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get groupDetailBackHome;

  /// No description provided for @groupDetailShareLink.
  ///
  /// In fr, this message translates to:
  /// **'Partager le lien'**
  String get groupDetailShareLink;

  /// No description provided for @groupDetailDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le groupe'**
  String get groupDetailDelete;

  /// No description provided for @groupDetailLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe'**
  String get groupDetailLeave;

  /// No description provided for @groupDetailInviteCode.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'invitation'**
  String get groupDetailInviteCode;

  /// No description provided for @groupDetailShareCode.
  ///
  /// In fr, this message translates to:
  /// **'Partagez ce code avec les membres de votre groupe.'**
  String get groupDetailShareCode;

  /// No description provided for @groupDetailCodeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code copié !'**
  String get groupDetailCodeCopied;

  /// No description provided for @groupDetailCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get groupDetailCopy;

  /// No description provided for @groupDetailDeleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le groupe ?'**
  String get groupDetailDeleteConfirmTitle;

  /// No description provided for @groupDetailDeleteConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Le groupe et toutes les progressions seront supprimés définitivement.'**
  String get groupDetailDeleteConfirmBody;

  /// No description provided for @groupDetailLeaveConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe ?'**
  String get groupDetailLeaveConfirmTitle;

  /// No description provided for @groupDetailLeaveConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous quitterez ce groupe et le plan associé sera supprimé de votre appareil.'**
  String get groupDetailLeaveConfirmBody;

  /// No description provided for @groupDetailLeaveAction.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get groupDetailLeaveAction;

  /// No description provided for @groupDetailAdminBadge.
  ///
  /// In fr, this message translates to:
  /// **'admin'**
  String get groupDetailAdminBadge;

  /// No description provided for @groupDetailReadAt.
  ///
  /// In fr, this message translates to:
  /// **'Lu à {time}'**
  String groupDetailReadAt(String time);

  /// No description provided for @groupsErrorLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les groupes.'**
  String get groupsErrorLoad;

  /// No description provided for @groupsErrorCreate.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer le groupe. Réessayez.'**
  String get groupsErrorCreate;

  /// No description provided for @groupsErrorInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou groupe introuvable.'**
  String get groupsErrorInvalidCode;

  /// No description provided for @groupsErrorJoin.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de rejoindre le groupe. Réessayez.'**
  String get groupsErrorJoin;

  /// No description provided for @groupsErrorLeave.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de quitter le groupe.'**
  String get groupsErrorLeave;

  /// No description provided for @groupsErrorDelete.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer le groupe.'**
  String get groupsErrorDelete;

  /// No description provided for @groupCreatePickPlan.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un plan pour le groupe.'**
  String get groupCreatePickPlan;

  /// No description provided for @groupCreateError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de création.'**
  String get groupCreateError;

  /// No description provided for @groupCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un groupe'**
  String get groupCreateTitle;

  /// No description provided for @groupCreateNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get groupCreateNameLabel;

  /// No description provided for @groupCreateNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Famille Martin, Cellule Alpha…'**
  String get groupCreateNameHint;

  /// No description provided for @groupCreateNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Donnez un nom.'**
  String get groupCreateNameRequired;

  /// No description provided for @groupCreatePlanLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plan de lecture'**
  String get groupCreatePlanLabel;

  /// No description provided for @groupCreateStartDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get groupCreateStartDateLabel;

  /// No description provided for @groupCreateSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le groupe'**
  String get groupCreateSubmit;

  /// No description provided for @groupJoinCodeLength.
  ///
  /// In fr, this message translates to:
  /// **'Le code doit faire 6 caractères.'**
  String get groupJoinCodeLength;

  /// No description provided for @groupJoinInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou expiré.'**
  String get groupJoinInvalidCode;

  /// No description provided for @groupJoinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre un groupe'**
  String get groupJoinTitle;

  /// No description provided for @groupJoinEnterCode.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code d\'invitation'**
  String get groupJoinEnterCode;

  /// No description provided for @groupJoinAskAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Demandez le code à l\'administrateur de votre groupe.'**
  String get groupJoinAskAdmin;

  /// No description provided for @groupJoinSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get groupJoinSubmit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
