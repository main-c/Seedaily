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

  @override
  String get widgetNoPlan => 'Créez un plan de lecture pour commencer';

  @override
  String get widgetReadToday => 'Lecture du jour terminée. A demain !';

  @override
  String widgetStreakAmazing(int n) {
    return 'Incroyable : $n jours de suite !';
  }

  @override
  String widgetStreakGood(int n) {
    return '$n jours de suite. Continuez !';
  }

  @override
  String widgetStreakDay(int n) {
    return 'Jour $n. Restez dans le rythme !';
  }

  @override
  String get widgetReady => 'Prêt pour ta lecture du jour ?';

  @override
  String widgetStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'jours',
      one: 'jour',
    );
    return '$_temp0';
  }

  @override
  String get widgetBadgeRead => 'Lu';

  @override
  String get widgetSectionToday => 'Pour aujourd\'hui';

  @override
  String get widgetSectionNext => 'Prochain passage';

  @override
  String get widgetEmpty => 'Ouvre Seedaily pour commencer';

  @override
  String get widgetDayLabels => 'LMMJVSD';

  @override
  String get notifActionViewPlans => 'Voir mes plans';

  @override
  String get notifActionCreatePlan => 'Créer un plan';

  @override
  String get notifChannelName => 'Lecture quotidienne';

  @override
  String get notifChannelDescription =>
      'Rappels quotidiens pour votre lecture biblique';

  @override
  String get notifOpenApp => 'Ouvrir Seedaily';

  @override
  String get notifDailyTitle => 'Lecture du Jour';

  @override
  String notifDailyTitleStreak(int n) {
    return 'Lecture du Jour · 🔥$n jours';
  }

  @override
  String notifEveningBehind(int n) {
    return '⚠️ Tu as $n jours de retard. Un petit effort ce soir?';
  }

  @override
  String get notifEveningNotRead =>
      '⚠️ Tu n\'as pas encore lu aujourd\'hui. Prends quelques minutes!';

  @override
  String get notifGeneric1 =>
      '10 minutes aujourd\'hui peuvent nourrir toute ta journée 🌱';

  @override
  String get notifGeneric2 => 'Un nouveau chapitre t\'attend aujourd\'hui 📖';

  @override
  String get notifGeneric3 => 'Prêt pour ta lecture du jour ? 🙏';

  @override
  String get notifGeneric4 => 'La Parole te nourrit chaque jour ✨';

  @override
  String get notifGeneric5 => 'Continue ton parcours, tu progresses bien 💪';

  @override
  String get notifGeneric6 => 'Un moment avec Dieu aujourd\'hui ? 🕊️';

  @override
  String get notifGeneric7 => 'Ta lecture quotidienne est prête 📖';

  @override
  String get notifGeneric8 => 'Garde le cap, tu es sur la bonne voie 🌟';

  @override
  String notifUrgent1(int n) {
    return 'Tu as $n jours de retard. Commence par un seul chapitre ! ⚡';
  }

  @override
  String notifUrgent2(int n) {
    return '⚠️ $n jours non lus t\'attendent. Un petit pas aujourd\'hui ?';
  }

  @override
  String notifUrgent3(int n) {
    return 'Le retard s\'accumule ($n jours). Un effort aujourd\'hui ? 💪';
  }

  @override
  String notifUrgent4(int n) {
    return 'Tu es à $n jours du rythme. La Parole t\'attend ! ⚠️';
  }

  @override
  String get notifCatchup1 => 'Encore un effort et tu rattrapes ton plan ! 🎯';

  @override
  String get notifCatchup2 =>
      'Un chapitre aujourd\'hui et tu es presque à jour 📖';

  @override
  String get notifCatchup3 =>
      'La régularité vient avec la pratique. Tu peux le faire ! 💪';

  @override
  String get notifCatchup4 => 'Presque rattrapé — continue sur ta lancée ! 🔥';

  @override
  String get notifOnTrack1 => 'Tu es dans le rythme. La Parole t\'attend ! ✨';

  @override
  String get notifOnTrack2 => 'Parfait, tu es à jour. Continue comme ça ! 🌟';

  @override
  String get notifOnTrack3 => 'Un nouveau chapitre t\'attend aujourd\'hui 📖';

  @override
  String get notifOnTrack4 => 'Tu es fidèle à ton plan. Bravo ! 🙌';

  @override
  String notifPraise1(int n) {
    return 'Impressionnant ! Tu es en avance de $n jour(s) 🏆';
  }

  @override
  String notifPraise2(int n) {
    return 'Tu es $n jour(s) en avance sur ton plan. Continue ! 🌟';
  }

  @override
  String notifPraise3(int n) {
    return 'En avance de $n jour(s) ! Tu es une inspiration ✨';
  }

  @override
  String notifPraise4(int n) {
    return 'Quel rythme ! $n jour(s) d\'avance. Garde le cap ! 🔥';
  }

  @override
  String get templateCanonicalPlanTitle => 'Plan Canonique';

  @override
  String get templateCanonicalPlanDescription =>
      'Lecture de toute la Bible dans l’ordre traditionnel de Genèse a Apocalypse.';

  @override
  String get templateCanonicalPlanDetails =>
      'Ce plan suit l’ordre classique des livres bibliques tel que présenté dans la plupart des Bibles chrétiennes.\nVous pouvez modifier la durée (6 mois, 1 an, 2 ans…), sélectionner certains livres seulement, ou choisir vos jours de lecture.\nIdéal comme base flexible pour construire votre propre parcours complet.';

  @override
  String get templateChronologicalPlanTitle => 'Plan Chronologique';

  @override
  String get templateChronologicalPlanDescription =>
      'Lecture de la Bible selon l’ordre historique des événements et de rédaction.';

  @override
  String get templateChronologicalPlanDetails =>
      'Ce plan replace les livres et passages dans leur contexte historique présumé afin de mieux comprendre la progression de l’histoire biblique.\nParfait pour suivre le fil narratif de la révélation biblique.\nVous pouvez ajuster la durée, retirer ou ajouter des livres selon votre objectif d’étude.';

  @override
  String get templateNewTestamentTitle => 'Nouveau Testament';

  @override
  String get templateNewTestamentDescription =>
      'Découvrez la vie de Jésus, la naissance de l’Église et l’enseignement apostolique.';

  @override
  String get templateNewTestamentDetails =>
      'Les 27 livres du Nouveau Testament dans un parcours adaptable à votre rythme.\nVous pouvez lire en format intensif (30 jours) ou progressif (3 à 6 mois).';

  @override
  String get templateOldTestamentTitle => 'Ancien Testament';

  @override
  String get templateOldTestamentDescription =>
      'Explorez la Loi, l’histoire d’Israël, les livres poétiques et les prophètes.';

  @override
  String get templateOldTestamentDetails =>
      'Les 39 livres de l’Ancien Testament, ajustables selon votre durée.\n              Vous pouvez sélectionner uniquement certaines sections.';

  @override
  String get templateGospelsTitle => 'Les Évangiles';

  @override
  String get templateGospelsDescription =>
      'Matthieu, Marc, Luc et Jean dans un parcours centré sur la vie de Jésus.';

  @override
  String get templateGospelsDetails =>
      'Idéal pour découvrir ou redécouvrir la personne et l’œuvre du Christ.\nVous pouvez compléter avec le livre des Actes ou adapter la durée (2 semaines à 3 mois).\nParfait pour un groupe de croissance ou un nouveau croyant.';

  @override
  String get templatePsalmsTitle => 'Les Psaumes';

  @override
  String get templatePsalmsDescription =>
      '150 psaumes pour nourrir la prière et la méditation.';

  @override
  String get templatePsalmsDetails =>
      'Un parcours spirituel centré sur l’adoration, la repentance et la confiance en Dieu.\nChoisissez votre rythme : 1 psaume par jour ou plusieurs par lecture.\nPeut être combiné avec Proverbes pour un équilibre entre prière et sagesse.';

  @override
  String get templateProverbsTitle => 'Les Proverbes';

  @override
  String get templateProverbsDescription =>
      '31 chapitres de sagesse pratique pour la vie quotidienne.';

  @override
  String get templateProverbsDetails =>
      'Un plan idéal pour une lecture mensuelle (1 chapitre par jour).\nPeut être associé à Ecclésiaste ou Cantique des cantiques pour approfondir la littérature sapientielle.\nSimple, court et applicable immédiatement.';

  @override
  String get templateMcheyneTitle => 'Plan M\'Cheyne';

  @override
  String get templateMcheyneDescription =>
      'Une lecture parallèle de l’Ancien et du Nouveau Testament.';

  @override
  String get templateMcheyneDetails =>
      'Créé par Robert Murray M’Cheyne, ce plan propose une lecture parallèle de l’Ancien et du Nouveau Testament.\nLes passages sont prédéfinis et suivent la structure originale.\nVous choisissez simplement la date de début.';

  @override
  String get templateBibleYearLigueTitle => 'Bible en 1 an (Ligue)';

  @override
  String get templateBibleYearLigueDescription =>
      'Lecture quotidienne équilibrée de l\'ancien testament, les Psaumes, Les Proverbes et du nouveau testament';

  @override
  String get templateBibleYearLigueDetails =>
      'Chaque jour propose un passage de l’Ancien Testament, un Psaume, un Proverbe et un passage du Nouveau Testament.\nPlan structuré et prédéfini, idéal pour une lecture communautaire en Église.';

  @override
  String get templateRevolutionaryTitle => 'Plan révolutionnaire';

  @override
  String get templateRevolutionaryDescription =>
      '25 lectures par mois avec jours de repos intégrés..';

  @override
  String get templateRevolutionaryDetails =>
      'Plan structuré pour favoriser la régularité sans surcharge.\nLes jours de pause permettent de rattraper ou méditer.\nStructure fixe : il suffit de choisir votre date de départ.';

  @override
  String get templateHornerTitle => 'Plan Horner';

  @override
  String get templateHornerDescription =>
      'Méthode intensive : 10 chapitres par jour en lectures parallèles.';

  @override
  String get templateHornerDetails =>
      'Conçu par le Professeur Grant Horner, ce plan divise la Bible en 10 listes distinctes lues simultanément.\nTrès exigeant, il favorise l’immersion et la répétition des textes.\nStructure entièrement prédéfinie.';

  @override
  String get pdfTagline => 'Générez vos plans de lecture biblique';

  @override
  String pdfReadingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de lecture',
      one: '1 jour de lecture',
    );
    return '$_temp0';
  }

  @override
  String pdfGeneratedWith(String app) {
    return 'Généré avec $app';
  }

  @override
  String pdfMonthTitle(String month) {
    return 'Plan de Lecture - $month';
  }

  @override
  String get pdfWeekDays => 'LUN,MAR,MER,JEU,VEN,SAM,DIM';

  @override
  String get pdfGenreGospelsActs => 'Évangiles & Actes';

  @override
  String get pdfGenreEpistles => 'Épîtres';

  @override
  String get pdfGenreRevelation => 'Apocalypse';

  @override
  String get pdfGenreLaw => 'Loi / Torah';

  @override
  String get pdfGenreHistory => 'Historiques';

  @override
  String get pdfGenreWisdom => 'Sapientiaux';

  @override
  String get pdfGenreProphets => 'Prophètes';

  @override
  String get bibleVersionLsgDescription =>
      'Traduction classique, la plus répandue en France';

  @override
  String get bibleVersionMartinDescription =>
      'Traduction de David Martin, fidèle au texte reçu';

  @override
  String get bibleVersionOstervaldDescription =>
      'Révision d\'Ostervald, style classique';

  @override
  String get bibleVersionEpeeDescription =>
      'Traduction moderne fidèle à l\'original';

  @override
  String get bibleVersionKjvDescription =>
      'Traduction anglaise classique, domaine public';

  @override
  String get bibleVersionAsvDescription =>
      'Révision américaine de la KJV, domaine public';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String percent(int n) {
    return '$n %';
  }

  @override
  String dayOfTotal(int day, int total) {
    return 'Jour $day sur $total';
  }

  @override
  String get groupsTitle => 'Groupes';

  @override
  String get groupsSignInTitle => 'Lecture en groupe';

  @override
  String get groupsSignInBody =>
      'Lisez avec vos proches et votre communauté. Connectez-vous pour créer ou rejoindre un groupe.';

  @override
  String get groupsSigningIn => 'Connexion…';

  @override
  String get groupsContinueWithGoogle => 'Continuer avec Google';

  @override
  String get groupsEmptyTitle => 'Aucun groupe pour l\'instant';

  @override
  String get groupsEmptyMessage =>
      'Choisissez un plan dans Découvrir, puis sélectionnez \"Avec des amis\" pour lire avec votre communauté.';

  @override
  String get groupsEmptyAction => 'Découvrir des plans';

  @override
  String get groupsNewGroupPlan => 'Nouveau plan de groupe';

  @override
  String get groupsBadge => 'Groupe';

  @override
  String get groupDetailLoadError => 'Impossible de charger le groupe.';

  @override
  String get groupDetailBackHome => 'Retour à l\'accueil';

  @override
  String get groupDetailShareLink => 'Partager le lien';

  @override
  String get groupDetailDelete => 'Supprimer le groupe';

  @override
  String get groupDetailLeave => 'Quitter le groupe';

  @override
  String get groupDetailInviteCode => 'Code d\'invitation';

  @override
  String get groupDetailShareCode =>
      'Partagez ce code avec les membres de votre groupe.';

  @override
  String get groupDetailCodeCopied => 'Code copié !';

  @override
  String get groupDetailCopy => 'Copier';

  @override
  String get groupDetailDeleteConfirmTitle => 'Supprimer le groupe ?';

  @override
  String get groupDetailDeleteConfirmBody =>
      'Le groupe et toutes les progressions seront supprimés définitivement.';

  @override
  String get groupDetailLeaveConfirmTitle => 'Quitter le groupe ?';

  @override
  String get groupDetailLeaveConfirmBody =>
      'Vous quitterez ce groupe et le plan associé sera supprimé de votre appareil.';

  @override
  String get groupDetailLeaveAction => 'Quitter';

  @override
  String get groupDetailAdminBadge => 'admin';

  @override
  String groupDetailReadAt(String time) {
    return 'Lu à $time';
  }

  @override
  String get groupsErrorLoad => 'Impossible de charger les groupes.';

  @override
  String get groupsErrorCreate => 'Impossible de créer le groupe. Réessayez.';

  @override
  String get groupsErrorInvalidCode => 'Code invalide ou groupe introuvable.';

  @override
  String get groupsErrorJoin => 'Impossible de rejoindre le groupe. Réessayez.';

  @override
  String get groupsErrorLeave => 'Impossible de quitter le groupe.';

  @override
  String get groupsErrorDelete => 'Impossible de supprimer le groupe.';

  @override
  String get groupCreatePickPlan => 'Choisissez un plan pour le groupe.';

  @override
  String get groupCreateError => 'Erreur de création.';

  @override
  String get groupCreateTitle => 'Créer un groupe';

  @override
  String get groupCreateNameLabel => 'Nom du groupe';

  @override
  String get groupCreateNameHint => 'Ex : Famille Martin, Cellule Alpha…';

  @override
  String get groupCreateNameRequired => 'Donnez un nom.';

  @override
  String get groupCreatePlanLabel => 'Plan de lecture';

  @override
  String get groupCreateStartDateLabel => 'Date de début';

  @override
  String get groupCreateSubmit => 'Créer le groupe';

  @override
  String get groupJoinCodeLength => 'Le code doit faire 6 caractères.';

  @override
  String get groupJoinInvalidCode => 'Code invalide ou expiré.';

  @override
  String get groupJoinTitle => 'Rejoindre un groupe';

  @override
  String get groupJoinEnterCode => 'Entrez le code d\'invitation';

  @override
  String get groupJoinAskAdmin =>
      'Demandez le code à l\'administrateur de votre groupe.';

  @override
  String get groupJoinSubmit => 'Rejoindre';
}
