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

  /// No description provided for @noReadingDays.
  ///
  /// In fr, this message translates to:
  /// **'Aucun jour de lecture'**
  String get noReadingDays;

  /// No description provided for @weekNumber.
  ///
  /// In fr, this message translates to:
  /// **'Semaine {n}'**
  String weekNumber(int n);

  /// No description provided for @weekOf.
  ///
  /// In fr, this message translates to:
  /// **'Semaine du {date}'**
  String weekOf(String date);

  /// No description provided for @booksIncludeDeuterocanonical.
  ///
  /// In fr, this message translates to:
  /// **'Inclure les deutérocanoniques'**
  String get booksIncludeDeuterocanonical;

  /// No description provided for @booksDeuterocanonicalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Livres de la Septante et de la Vulgate'**
  String get booksDeuterocanonicalSubtitle;

  /// No description provided for @booksChronologicalOrder.
  ///
  /// In fr, this message translates to:
  /// **'Ordre chronologique'**
  String get booksChronologicalOrder;

  /// No description provided for @booksTanakh.
  ///
  /// In fr, this message translates to:
  /// **'Tanakh (Ancien Testament)'**
  String get booksTanakh;

  /// No description provided for @booksDeuterocanonical.
  ///
  /// In fr, this message translates to:
  /// **'Deutérocanoniques'**
  String get booksDeuterocanonical;

  /// No description provided for @booksNewTestament.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Testament'**
  String get booksNewTestament;

  /// No description provided for @booksOldTestament.
  ///
  /// In fr, this message translates to:
  /// **'Ancien Testament'**
  String get booksOldTestament;

  /// No description provided for @booksSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get booksSelectAll;

  /// No description provided for @booksChapterCountShort.
  ///
  /// In fr, this message translates to:
  /// **'{n} ch.'**
  String booksChapterCountShort(int n);

  /// No description provided for @oldTestamentShort.
  ///
  /// In fr, this message translates to:
  /// **'AT'**
  String get oldTestamentShort;

  /// No description provided for @newTestamentShort.
  ///
  /// In fr, this message translates to:
  /// **'NT'**
  String get newTestamentShort;

  /// No description provided for @chapterCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 chapitre} =1{1 chapitre} other{{count} chapitres}}'**
  String chapterCount(int count);

  /// No description provided for @dayCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 jour} =1{1 jour} other{{count} jours}}'**
  String dayCount(int count);

  /// No description provided for @dayCompletedBadge.
  ///
  /// In fr, this message translates to:
  /// **'COMPLÉTÉ'**
  String get dayCompletedBadge;

  /// No description provided for @dayPreviousUnread.
  ///
  /// In fr, this message translates to:
  /// **'Des jours précédents ne sont pas encore lus'**
  String get dayPreviousUnread;

  /// No description provided for @dayAddBibleToRead.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une Bible pour lire'**
  String get dayAddBibleToRead;

  /// No description provided for @dayRead.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get dayRead;

  /// No description provided for @statDaysLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{jour} other{jours}}'**
  String statDaysLabel(int count);

  /// No description provided for @statBooksLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{livre} other{livres}}'**
  String statBooksLabel(int count);

  /// No description provided for @statChaptersLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{chapitre} other{chapitres}}'**
  String statChaptersLabel(int count);

  /// No description provided for @statChaptersPerDay.
  ///
  /// In fr, this message translates to:
  /// **'chap/jour'**
  String get statChaptersPerDay;

  /// No description provided for @statTotalProgress.
  ///
  /// In fr, this message translates to:
  /// **'PROGRESSION TOTALE'**
  String get statTotalProgress;

  /// No description provided for @statPercentDone.
  ///
  /// In fr, this message translates to:
  /// **'{n}% Terminé'**
  String statPercentDone(int n);

  /// No description provided for @statDaysFraction.
  ///
  /// In fr, this message translates to:
  /// **'{done}/{total} jours'**
  String statDaysFraction(int done, int total);

  /// No description provided for @statProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get statProgress;

  /// No description provided for @statDaysCompleted.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} jours complétés'**
  String statDaysCompleted(int done, int total);

  /// No description provided for @todayCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'LECTURE DU JOUR'**
  String get todayCardTitle;

  /// No description provided for @todayCardNoReading.
  ///
  /// In fr, this message translates to:
  /// **'Aucune lecture'**
  String get todayCardNoReading;

  /// No description provided for @todayCardComplete.
  ///
  /// In fr, this message translates to:
  /// **'Lecture complète'**
  String get todayCardComplete;

  /// No description provided for @todayCardContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer la lecture'**
  String get todayCardContinue;

  /// No description provided for @calendarPreviewBadge.
  ///
  /// In fr, this message translates to:
  /// **'aperçu'**
  String get calendarPreviewBadge;

  /// No description provided for @calendarPreviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez le plan pour voir tous les mois'**
  String get calendarPreviewHint;

  /// No description provided for @calendarWeekDaysSundayFirst.
  ///
  /// In fr, this message translates to:
  /// **'Dim,Lun,Mar,Mer,Jeu,Ven,Sam'**
  String get calendarWeekDaysSundayFirst;

  /// No description provided for @planCardDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get planCardDone;

  /// No description provided for @planCardStreakShort.
  ///
  /// In fr, this message translates to:
  /// **'{n} j. de suite'**
  String planCardStreakShort(int n);

  /// No description provided for @planCardOnTrack.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get planCardOnTrack;

  /// No description provided for @planCardAhead.
  ///
  /// In fr, this message translates to:
  /// **'+{n} j. d\'avance'**
  String planCardAhead(int n);

  /// No description provided for @planCardBehind.
  ///
  /// In fr, this message translates to:
  /// **'{n} j. de retard'**
  String planCardBehind(int n);

  /// No description provided for @dayFraction.
  ///
  /// In fr, this message translates to:
  /// **'Jour {day}/{total}'**
  String dayFraction(int day, int total);

  /// No description provided for @planCardEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin : {date}'**
  String planCardEnd(String date);

  /// No description provided for @planCardShortMonths.
  ///
  /// In fr, this message translates to:
  /// **'Jan.,Fév.,Mar.,Avr.,Mai,Jun.,Jul.,Aoû.,Sep.,Oct.,Nov.,Déc.'**
  String get planCardShortMonths;

  /// No description provided for @shortDayMonth.
  ///
  /// In fr, this message translates to:
  /// **'{day} {month}'**
  String shortDayMonth(int day, String month);

  /// No description provided for @planCardReview.
  ///
  /// In fr, this message translates to:
  /// **'Revoir'**
  String get planCardReview;

  /// No description provided for @planCardDeletePlan.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le plan'**
  String get planCardDeletePlan;

  /// No description provided for @planCardDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer \"{title}\" ?\n\nCette action est irréversible.'**
  String planCardDeleteConfirm(String title);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plan de lecture'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier plan pour commencer'**
  String get homeEmptyMessage;

  /// No description provided for @homeEmptyFilter.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plan dans cette catégorie'**
  String get homeEmptyFilter;

  /// No description provided for @homeMyPlans.
  ///
  /// In fr, this message translates to:
  /// **'Mes Plans'**
  String get homeMyPlans;

  /// No description provided for @homeActivePlans.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 PLAN ACTIF} =1{1 PLAN ACTIF} other{{count} PLANS ACTIFS}}'**
  String homeActivePlans(int count);

  /// No description provided for @homeStreakDays.
  ///
  /// In fr, this message translates to:
  /// **'{n} j.'**
  String homeStreakDays(int n);

  /// No description provided for @homeBestStreak.
  ///
  /// In fr, this message translates to:
  /// **'Rec. {n}'**
  String homeBestStreak(int n);

  /// No description provided for @homeFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get homeFilterAll;

  /// No description provided for @homeFilterInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get homeFilterInProgress;

  /// No description provided for @homeFilterCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminés'**
  String get homeFilterCompleted;

  /// No description provided for @milestone365.
  ///
  /// In fr, this message translates to:
  /// **'Une année complète de fidélité. Exceptionnel!'**
  String get milestone365;

  /// No description provided for @milestone100.
  ///
  /// In fr, this message translates to:
  /// **'Cent jours de lecture. Vous êtes un exemple!'**
  String get milestone100;

  /// No description provided for @milestone60.
  ///
  /// In fr, this message translates to:
  /// **'Deux mois sans interruption. Remarquable!'**
  String get milestone60;

  /// No description provided for @milestone30.
  ///
  /// In fr, this message translates to:
  /// **'Un mois complet de lecture. Bravo!'**
  String get milestone30;

  /// No description provided for @milestone14.
  ///
  /// In fr, this message translates to:
  /// **'Deux semaines consécutives. Continuez!'**
  String get milestone14;

  /// No description provided for @milestone7.
  ///
  /// In fr, this message translates to:
  /// **'Une semaine complète. Bel élan!'**
  String get milestone7;

  /// No description provided for @milestoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'{n} jours de streak!'**
  String milestoneTitle(int n);

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navDiscover.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir'**
  String get navDiscover;

  /// No description provided for @tourSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get tourSkip;

  /// No description provided for @tourFabBody.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur ce bouton pour accéder à la page Découvrir et choisir un modèle de plan.'**
  String get tourFabBody;

  /// No description provided for @tourDiscoverBody.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez ici tous les modèles disponibles. Continuons pour les explorer.'**
  String get tourDiscoverBody;

  /// No description provided for @tourSettingsBody.
  ///
  /// In fr, this message translates to:
  /// **'Thème clair / sombre, rappels quotidiens, et préférences de lecture.'**
  String get tourSettingsBody;

  /// No description provided for @tourCustomPlanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan personnalisé'**
  String get tourCustomPlanTitle;

  /// No description provided for @tourCustomPlanBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez un plan sur mesure : choisissez vous-même les livres, la durée, le rythme et les jours de lecture.'**
  String get tourCustomPlanBody;

  /// No description provided for @tourTemplatesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modèles prêts à l\'emploi'**
  String get tourTemplatesTitle;

  /// No description provided for @tourTemplatesBody.
  ///
  /// In fr, this message translates to:
  /// **'Plans structurés (M\'Cheyne, Horner…) et thématiques (Évangiles, Psaumes…) — choisissez et c\'est parti.'**
  String get tourTemplatesBody;

  /// No description provided for @discoverSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher...'**
  String get discoverSearchHint;

  /// No description provided for @discoverSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un plan ou créez le vôtre'**
  String get discoverSubtitle;

  /// No description provided for @discoverNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plan trouvé pour \"{query}\"'**
  String discoverNoResults(String query);

  /// No description provided for @discoverStructuredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plans structurés'**
  String get discoverStructuredTitle;

  /// No description provided for @discoverStructuredSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Structure fixe: choisissez simplement votre date de début'**
  String get discoverStructuredSubtitle;

  /// No description provided for @discoverThematicTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plans thématiques'**
  String get discoverThematicTitle;

  /// No description provided for @discoverThematicSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Livres ciblés: ajustez la durée et le rythme'**
  String get discoverThematicSubtitle;

  /// No description provided for @discoverCustomTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un plan personnalisé'**
  String get discoverCustomTitle;

  /// No description provided for @discoverCustomSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous choisirez vous-mêmes les livres, la durée, le rythme de lecture'**
  String get discoverCustomSubtitle;

  /// No description provided for @aboutDescriptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get aboutDescriptionTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Seedaily est une application de génération de plans de lecture biblique personnalisés. Créez votre propre parcours de lecture adapté à votre rythme et vos objectifs spirituels.'**
  String get aboutDescription;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalités'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeatureTemplates.
  ///
  /// In fr, this message translates to:
  /// **'11+ modèles de plans prêts à l\'emploi'**
  String get aboutFeatureTemplates;

  /// No description provided for @aboutFeatureCustom.
  ///
  /// In fr, this message translates to:
  /// **'Plans entièrement personnalisables'**
  String get aboutFeatureCustom;

  /// No description provided for @aboutFeatureReader.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur biblique intégré (LSG, Darby…)'**
  String get aboutFeatureReader;

  /// No description provided for @aboutFeatureProgress.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de progression et streak'**
  String get aboutFeatureProgress;

  /// No description provided for @aboutFeaturePdf.
  ///
  /// In fr, this message translates to:
  /// **'Export PDF et partage'**
  String get aboutFeaturePdf;

  /// No description provided for @aboutFeatureReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels quotidiens personnalisables'**
  String get aboutFeatureReminders;

  /// No description provided for @aboutFeatureWidget.
  ///
  /// In fr, this message translates to:
  /// **'Widget écran d\'accueil'**
  String get aboutFeatureWidget;

  /// No description provided for @aboutLinksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Liens'**
  String get aboutLinksTitle;

  /// No description provided for @aboutRateApp.
  ///
  /// In fr, this message translates to:
  /// **'Noter l\'application'**
  String get aboutRateApp;

  /// No description provided for @aboutReportBug.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un bug'**
  String get aboutReportBug;

  /// No description provided for @aboutCreditsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Crédits'**
  String get aboutCreditsTitle;

  /// No description provided for @aboutCredits.
  ///
  /// In fr, this message translates to:
  /// **'Développé par Yannik KADJIE.\nImage  : Unsplash.\n'**
  String get aboutCredits;

  /// No description provided for @aboutCopyright.
  ///
  /// In fr, this message translates to:
  /// **'© {year} Seedaily. Tous droits réservés.'**
  String aboutCopyright(int year);

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutLinkCopied.
  ///
  /// In fr, this message translates to:
  /// **'Lien copié : {url}'**
  String aboutLinkCopied(String url);

  /// No description provided for @bibleLibraryIntro.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargez une version pour lire directement dans l\'app. Toutes les versions sont en domaine public.'**
  String get bibleLibraryIntro;

  /// No description provided for @bibleLibraryUse.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser'**
  String get bibleLibraryUse;

  /// No description provided for @bibleLibraryDownloadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de téléchargement : {error}'**
  String bibleLibraryDownloadError(String error);

  /// No description provided for @bibleLibraryDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette version ?'**
  String get bibleLibraryDeleteTitle;

  /// No description provided for @bibleLibraryDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'La version \"{name}\" sera supprimée de l\'appareil.'**
  String bibleLibraryDeleteBody(String name);

  /// No description provided for @readerChapterNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre introuvable.\nVérifiez que la version est bien téléchargée.'**
  String get readerChapterNotFound;

  /// No description provided for @readerAlreadyRead.
  ///
  /// In fr, this message translates to:
  /// **'Déjà lu'**
  String get readerAlreadyRead;

  /// No description provided for @readerMarkAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get readerMarkAsRead;

  /// No description provided for @readerAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get readerAppearance;

  /// No description provided for @readerPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu — \"{book}\"'**
  String readerPreview(String book);

  /// No description provided for @readerLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger ce chapitre'**
  String get readerLoadError;

  /// No description provided for @planNotFoundTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plan introuvable'**
  String get planNotFoundTitle;

  /// No description provided for @planNotFoundBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce plan n\'existe pas'**
  String get planNotFoundBody;

  /// No description provided for @planInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get planInvite;

  /// No description provided for @planShareWithFriends.
  ///
  /// In fr, this message translates to:
  /// **'Partager avec des amis'**
  String get planShareWithFriends;

  /// No description provided for @planSettings.
  ///
  /// In fr, this message translates to:
  /// **'Configuration'**
  String get planSettings;

  /// No description provided for @planExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get planExport;

  /// No description provided for @planMyProgress.
  ///
  /// In fr, this message translates to:
  /// **'Ma progression'**
  String get planMyProgress;

  /// No description provided for @planPercentComplete.
  ///
  /// In fr, this message translates to:
  /// **'{n}% complété'**
  String planPercentComplete(int n);

  /// No description provided for @planFriendsReading.
  ///
  /// In fr, this message translates to:
  /// **'Amis qui lisent'**
  String get planFriendsReading;

  /// No description provided for @planPaceOnTrack.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes à jour'**
  String get planPaceOnTrack;

  /// No description provided for @planPaceAhead.
  ///
  /// In fr, this message translates to:
  /// **'En avance de {n} j.'**
  String planPaceAhead(int n);

  /// No description provided for @planPaceBehind.
  ///
  /// In fr, this message translates to:
  /// **'En retard de {n} j.'**
  String planPaceBehind(int n);

  /// No description provided for @planSignInRequired.
  ///
  /// In fr, this message translates to:
  /// **'Connexion requise'**
  String get planSignInRequired;

  /// No description provided for @planSignInRequiredBody.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous avec Google pour partager ce plan avec des amis.'**
  String get planSignInRequiredBody;

  /// No description provided for @planConvertBody.
  ///
  /// In fr, this message translates to:
  /// **'Créez un groupe depuis votre plan \"{title}\". Vos amis pourront vous rejoindre et vous suivrez votre progression ensemble.'**
  String planConvertBody(String title);

  /// No description provided for @planGroupNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Famille, Cellule, Amis…'**
  String get planGroupNameHint;

  /// No description provided for @planShareMessage.
  ///
  /// In fr, this message translates to:
  /// **'Je lis \"{title}\" sur Seedaily et j\'aimerais qu\'on le lise ensemble 🙏\n\n{url}'**
  String planShareMessage(String title, String url);

  /// No description provided for @planShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Lire la Bible ensemble'**
  String get planShareSubject;

  /// No description provided for @planCreating.
  ///
  /// In fr, this message translates to:
  /// **'Création…'**
  String get planCreating;

  /// No description provided for @planCreateAndInvite.
  ///
  /// In fr, this message translates to:
  /// **'Créer le groupe et inviter'**
  String get planCreateAndInvite;

  /// No description provided for @planGroupUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Groupe non disponible. Réessayez dans un instant.'**
  String get planGroupUnavailable;

  /// No description provided for @planGroupMembers.
  ///
  /// In fr, this message translates to:
  /// **'Membres du groupe'**
  String get planGroupMembers;

  /// No description provided for @planExportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter mon plan'**
  String get planExportTitle;

  /// No description provided for @planExportBody.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisez l\'apparence de votre plan de lecture avant de le télécharger au format PDF.'**
  String get planExportBody;

  /// No description provided for @planExportColorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Colorer par genre biblique'**
  String get planExportColorsTitle;

  /// No description provided for @planExportColorsBody.
  ///
  /// In fr, this message translates to:
  /// **'Attribue une couleur spécifique à chaque type de livre comme la Loi, les Prophètes, les Évangiles.'**
  String get planExportColorsBody;

  /// No description provided for @planExportCheckboxesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les cases à cocher'**
  String get planExportCheckboxesTitle;

  /// No description provided for @planExportCheckboxesBody.
  ///
  /// In fr, this message translates to:
  /// **'Pour le suivi papier. Ajoute une case vide à côté de chaque session de lecture.'**
  String get planExportCheckboxesBody;

  /// No description provided for @planExportGenerating.
  ///
  /// In fr, this message translates to:
  /// **'Génération…'**
  String get planExportGenerating;

  /// No description provided for @planExportGenerate.
  ///
  /// In fr, this message translates to:
  /// **'Générer le PDF'**
  String get planExportGenerate;
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
