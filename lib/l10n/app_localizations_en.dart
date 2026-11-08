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

  @override
  String get widgetNoPlan => 'Create a reading plan to get started';

  @override
  String get widgetReadToday => 'Today\'s reading is done. See you tomorrow!';

  @override
  String widgetStreakAmazing(int n) {
    return 'Amazing: $n days in a row!';
  }

  @override
  String widgetStreakGood(int n) {
    return '$n days in a row. Keep going!';
  }

  @override
  String widgetStreakDay(int n) {
    return 'Day $n. Stay on track!';
  }

  @override
  String get widgetReady => 'Ready for today\'s reading?';

  @override
  String widgetStreakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String get widgetBadgeRead => 'Read';

  @override
  String get widgetSectionToday => 'For today';

  @override
  String get widgetSectionNext => 'Next passage';

  @override
  String get widgetEmpty => 'Open Seedaily to get started';

  @override
  String get widgetDayLabels => 'MTWTFSS';

  @override
  String get notifActionViewPlans => 'View my plans';

  @override
  String get notifActionCreatePlan => 'Create a plan';

  @override
  String get notifChannelName => 'Daily reading';

  @override
  String get notifChannelDescription =>
      'Daily reminders for your Bible reading';

  @override
  String get notifOpenApp => 'Open Seedaily';

  @override
  String get notifDailyTitle => 'Today\'s Reading';

  @override
  String notifDailyTitleStreak(int n) {
    return 'Today\'s Reading · 🔥$n days';
  }

  @override
  String notifEveningBehind(int n) {
    return '⚠️ You\'re $n days behind. A little effort tonight?';
  }

  @override
  String get notifEveningNotRead =>
      '⚠️ You haven\'t read yet today. Take a few minutes!';

  @override
  String get notifGeneric1 => '10 minutes today can nourish your whole day 🌱';

  @override
  String get notifGeneric2 => 'A new chapter is waiting for you today 📖';

  @override
  String get notifGeneric3 => 'Ready for today\'s reading? 🙏';

  @override
  String get notifGeneric4 => 'The Word nourishes you every day ✨';

  @override
  String get notifGeneric5 => 'Keep going, you\'re making great progress 💪';

  @override
  String get notifGeneric6 => 'A moment with God today? 🕊️';

  @override
  String get notifGeneric7 => 'Your daily reading is ready 📖';

  @override
  String get notifGeneric8 => 'Stay the course, you\'re on the right track 🌟';

  @override
  String notifUrgent1(int n) {
    return 'You\'re $n days behind. Start with just one chapter! ⚡';
  }

  @override
  String notifUrgent2(int n) {
    return '⚠️ $n unread days are waiting. A small step today?';
  }

  @override
  String notifUrgent3(int n) {
    return 'You\'re falling behind ($n days). A little effort today? 💪';
  }

  @override
  String notifUrgent4(int n) {
    return 'You\'re $n days off pace. The Word is waiting! ⚠️';
  }

  @override
  String get notifCatchup1 => 'One more push and you\'ll catch up! 🎯';

  @override
  String get notifCatchup2 =>
      'One chapter today and you\'re almost caught up 📖';

  @override
  String get notifCatchup3 =>
      'Consistency comes with practice. You can do it! 💪';

  @override
  String get notifCatchup4 => 'Almost caught up — keep it going! 🔥';

  @override
  String get notifOnTrack1 => 'You\'re on track. The Word is waiting! ✨';

  @override
  String get notifOnTrack2 => 'Perfect, you\'re up to date. Keep it up! 🌟';

  @override
  String get notifOnTrack3 => 'A new chapter is waiting for you today 📖';

  @override
  String get notifOnTrack4 => 'You\'re faithful to your plan. Well done! 🙌';

  @override
  String notifPraise1(int n) {
    return 'Impressive! You\'re $n day(s) ahead 🏆';
  }

  @override
  String notifPraise2(int n) {
    return 'You\'re $n day(s) ahead of your plan. Keep going! 🌟';
  }

  @override
  String notifPraise3(int n) {
    return '$n day(s) ahead! You\'re an inspiration ✨';
  }

  @override
  String notifPraise4(int n) {
    return 'What a pace! $n day(s) ahead. Stay the course! 🔥';
  }

  @override
  String get templateCanonicalPlanTitle => 'Canonical Plan';

  @override
  String get templateCanonicalPlanDescription =>
      'Read the whole Bible in the traditional order, from Genesis to Revelation.';

  @override
  String get templateCanonicalPlanDetails =>
      'This plan follows the classic order of the biblical books as found in most Christian Bibles.\nYou can change the duration (6 months, 1 year, 2 years…), select only some books, or choose your reading days.\nIdeal as a flexible base to build your own complete journey.';

  @override
  String get templateChronologicalPlanTitle => 'Chronological Plan';

  @override
  String get templateChronologicalPlanDescription =>
      'Read the Bible in the historical order of events and writing.';

  @override
  String get templateChronologicalPlanDetails =>
      'This plan places the books and passages in their presumed historical context to better understand how the biblical story unfolds.\nPerfect for following the narrative thread of biblical revelation.\nYou can adjust the duration, and remove or add books depending on your study goal.';

  @override
  String get templateNewTestamentTitle => 'New Testament';

  @override
  String get templateNewTestamentDescription =>
      'Discover the life of Jesus, the birth of the Church and the apostolic teaching.';

  @override
  String get templateNewTestamentDetails =>
      'The 27 books of the New Testament in a journey that adapts to your pace.\nYou can read intensively (30 days) or progressively (3 to 6 months).';

  @override
  String get templateOldTestamentTitle => 'Old Testament';

  @override
  String get templateOldTestamentDescription =>
      'Explore the Law, the history of Israel, the poetic books and the prophets.';

  @override
  String get templateOldTestamentDetails =>
      'The 39 books of the Old Testament, adjustable to your duration.\nYou can select only certain sections.';

  @override
  String get templateGospelsTitle => 'The Gospels';

  @override
  String get templateGospelsDescription =>
      'Matthew, Mark, Luke and John in a journey centered on the life of Jesus.';

  @override
  String get templateGospelsDetails =>
      'Ideal for discovering or rediscovering the person and work of Christ.\nYou can add the book of Acts or adjust the duration (2 weeks to 3 months).\nPerfect for a small group or a new believer.';

  @override
  String get templatePsalmsTitle => 'The Psalms';

  @override
  String get templatePsalmsDescription =>
      '150 psalms to nourish prayer and meditation.';

  @override
  String get templatePsalmsDetails =>
      'A spiritual journey centered on worship, repentance and trust in God.\nChoose your pace: 1 psalm a day or several per reading.\nCan be combined with Proverbs for a balance between prayer and wisdom.';

  @override
  String get templateProverbsTitle => 'The Proverbs';

  @override
  String get templateProverbsDescription =>
      '31 chapters of practical wisdom for everyday life.';

  @override
  String get templateProverbsDetails =>
      'An ideal plan for a monthly reading (1 chapter a day).\nCan be paired with Ecclesiastes or Song of Solomon to go deeper into wisdom literature.\nSimple, short and immediately applicable.';

  @override
  String get templateMcheyneTitle => 'M\'Cheyne Plan';

  @override
  String get templateMcheyneDescription =>
      'A parallel reading of the Old and New Testaments.';

  @override
  String get templateMcheyneDetails =>
      'Created by Robert Murray M\'Cheyne, this plan offers a parallel reading of the Old and New Testaments.\nThe passages are predefined and follow the original structure.\nYou simply choose the start date.';

  @override
  String get templateBibleYearLigueTitle => 'Bible in 1 Year (Ligue)';

  @override
  String get templateBibleYearLigueDescription =>
      'A balanced daily reading of the Old Testament, Psalms, Proverbs and New Testament';

  @override
  String get templateBibleYearLigueDetails =>
      'Each day offers a passage from the Old Testament, a Psalm, a Proverb and a passage from the New Testament.\nA structured, predefined plan, ideal for reading together as a church.';

  @override
  String get templateRevolutionaryTitle => 'Revolutionary Plan';

  @override
  String get templateRevolutionaryDescription =>
      '25 readings per month with built-in rest days.';

  @override
  String get templateRevolutionaryDetails =>
      'A structured plan that encourages consistency without overload.\nThe rest days let you catch up or meditate.\nFixed structure: just choose your start date.';

  @override
  String get templateHornerTitle => 'Horner Plan';

  @override
  String get templateHornerDescription =>
      'Intensive method: 10 chapters a day in parallel readings.';

  @override
  String get templateHornerDetails =>
      'Designed by Professor Grant Horner, this plan splits the Bible into 10 separate lists read at the same time.\nVery demanding, it encourages immersion and repetition of the texts.\nFully predefined structure.';

  @override
  String get pdfTagline => 'Create your Bible reading plans';

  @override
  String pdfReadingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reading days',
      one: '1 reading day',
    );
    return '$_temp0';
  }

  @override
  String pdfGeneratedWith(String app) {
    return 'Generated with $app';
  }

  @override
  String pdfMonthTitle(String month) {
    return 'Reading Plan - $month';
  }

  @override
  String get pdfWeekDays => 'MON,TUE,WED,THU,FRI,SAT,SUN';

  @override
  String get pdfGenreGospelsActs => 'Gospels & Acts';

  @override
  String get pdfGenreEpistles => 'Epistles';

  @override
  String get pdfGenreRevelation => 'Revelation';

  @override
  String get pdfGenreLaw => 'Law / Torah';

  @override
  String get pdfGenreHistory => 'History';

  @override
  String get pdfGenreWisdom => 'Wisdom';

  @override
  String get pdfGenreProphets => 'Prophets';

  @override
  String get bibleVersionLsgDescription =>
      'Classic translation, the most widely used in France';

  @override
  String get bibleVersionMartinDescription =>
      'David Martin\'s translation, faithful to the Received Text';

  @override
  String get bibleVersionOstervaldDescription =>
      'Ostervald\'s revision, classic style';

  @override
  String get bibleVersionEpeeDescription =>
      'Modern translation faithful to the original';

  @override
  String get bibleVersionKjvDescription =>
      'Classic English translation, public domain';

  @override
  String get bibleVersionAsvDescription =>
      'American revision of the KJV, public domain';

  @override
  String get today => 'Today';

  @override
  String percent(int n) {
    return '$n%';
  }

  @override
  String dayOfTotal(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsSignInTitle => 'Group reading';

  @override
  String get groupsSignInBody =>
      'Read with your loved ones and your community. Sign in to create or join a group.';

  @override
  String get groupsSigningIn => 'Signing in…';

  @override
  String get groupsContinueWithGoogle => 'Continue with Google';

  @override
  String get groupsEmptyTitle => 'No groups yet';

  @override
  String get groupsEmptyMessage =>
      'Choose a plan in Discover, then select \"With friends\" to read with your community.';

  @override
  String get groupsEmptyAction => 'Discover plans';

  @override
  String get groupsNewGroupPlan => 'New group plan';

  @override
  String get groupsBadge => 'Group';

  @override
  String get groupDetailLoadError => 'Unable to load the group.';

  @override
  String get groupDetailBackHome => 'Back to home';

  @override
  String get groupDetailShareLink => 'Share the link';

  @override
  String get groupDetailDelete => 'Delete the group';

  @override
  String get groupDetailLeave => 'Leave the group';

  @override
  String get groupDetailInviteCode => 'Invite code';

  @override
  String get groupDetailShareCode => 'Share this code with your group members.';

  @override
  String get groupDetailCodeCopied => 'Code copied!';

  @override
  String get groupDetailCopy => 'Copy';

  @override
  String get groupDetailDeleteConfirmTitle => 'Delete the group?';

  @override
  String get groupDetailDeleteConfirmBody =>
      'The group and all progress will be permanently deleted.';

  @override
  String get groupDetailLeaveConfirmTitle => 'Leave the group?';

  @override
  String get groupDetailLeaveConfirmBody =>
      'You will leave this group and its plan will be removed from your device.';

  @override
  String get groupDetailLeaveAction => 'Leave';

  @override
  String get groupDetailAdminBadge => 'admin';

  @override
  String groupDetailReadAt(String time) {
    return 'Read at $time';
  }

  @override
  String get groupsErrorLoad => 'Unable to load groups.';

  @override
  String get groupsErrorCreate => 'Unable to create the group. Try again.';

  @override
  String get groupsErrorInvalidCode => 'Invalid code or group not found.';

  @override
  String get groupsErrorJoin => 'Unable to join the group. Try again.';

  @override
  String get groupsErrorLeave => 'Unable to leave the group.';

  @override
  String get groupsErrorDelete => 'Unable to delete the group.';

  @override
  String get groupCreatePickPlan => 'Choose a plan for the group.';

  @override
  String get groupCreateError => 'Creation error.';

  @override
  String get groupCreateTitle => 'Create a group';

  @override
  String get groupCreateNameLabel => 'Group name';

  @override
  String get groupCreateNameHint => 'E.g. Martin Family, Alpha Group…';

  @override
  String get groupCreateNameRequired => 'Give it a name.';

  @override
  String get groupCreatePlanLabel => 'Reading plan';

  @override
  String get groupCreateStartDateLabel => 'Start date';

  @override
  String get groupCreateSubmit => 'Create the group';

  @override
  String get groupJoinCodeLength => 'The code must be 6 characters long.';

  @override
  String get groupJoinInvalidCode => 'Invalid or expired code.';

  @override
  String get groupJoinTitle => 'Join a group';

  @override
  String get groupJoinEnterCode => 'Enter the invite code';

  @override
  String get groupJoinAskAdmin => 'Ask your group admin for the code.';

  @override
  String get groupJoinSubmit => 'Join';

  @override
  String get noReadingDays => 'No reading days';

  @override
  String weekNumber(int n) {
    return 'Week $n';
  }

  @override
  String weekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get booksIncludeDeuterocanonical =>
      'Include the deuterocanonical books';

  @override
  String get booksDeuterocanonicalSubtitle =>
      'Books from the Septuagint and the Vulgate';

  @override
  String get booksChronologicalOrder => 'Chronological order';

  @override
  String get booksTanakh => 'Tanakh (Old Testament)';

  @override
  String get booksDeuterocanonical => 'Deuterocanonical';

  @override
  String get booksNewTestament => 'New Testament';

  @override
  String get booksOldTestament => 'Old Testament';

  @override
  String get booksSelectAll => 'Select all';

  @override
  String booksChapterCountShort(int n) {
    return '$n ch.';
  }

  @override
  String get oldTestamentShort => 'OT';

  @override
  String get newTestamentShort => 'NT';

  @override
  String chapterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get dayCompletedBadge => 'COMPLETED';

  @override
  String get dayPreviousUnread => 'Some previous days haven\'t been read yet';

  @override
  String get dayAddBibleToRead => 'Add a Bible to read';

  @override
  String get dayRead => 'Read';

  @override
  String statDaysLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String statBooksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'books',
      one: 'book',
    );
    return '$_temp0';
  }

  @override
  String statChaptersLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'chapters',
      one: 'chapter',
    );
    return '$_temp0';
  }

  @override
  String get statChaptersPerDay => 'ch/day';

  @override
  String get statTotalProgress => 'TOTAL PROGRESS';

  @override
  String statPercentDone(int n) {
    return '$n% Done';
  }

  @override
  String statDaysFraction(int done, int total) {
    return '$done/$total days';
  }

  @override
  String get statProgress => 'Progress';

  @override
  String statDaysCompleted(int done, int total) {
    return '$done / $total days completed';
  }

  @override
  String get todayCardTitle => 'TODAY\'S READING';

  @override
  String get todayCardNoReading => 'No reading';

  @override
  String get todayCardComplete => 'Reading complete';

  @override
  String get todayCardContinue => 'Continue reading';

  @override
  String get calendarPreviewBadge => 'preview';

  @override
  String get calendarPreviewHint => 'Create the plan to see all months';

  @override
  String get calendarWeekDaysSundayFirst => 'Sun,Mon,Tue,Wed,Thu,Fri,Sat';

  @override
  String get planCardDone => 'Done';

  @override
  String planCardStreakShort(int n) {
    return '$n-day streak';
  }

  @override
  String get planCardOnTrack => 'On track';

  @override
  String planCardAhead(int n) {
    return '+$n d. ahead';
  }

  @override
  String planCardBehind(int n) {
    return '$n d. behind';
  }

  @override
  String dayFraction(int day, int total) {
    return 'Day $day/$total';
  }

  @override
  String planCardEnd(String date) {
    return 'Ends: $date';
  }

  @override
  String get planCardShortMonths =>
      'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  String shortDayMonth(int day, String month) {
    return '$month $day';
  }

  @override
  String get planCardReview => 'Review';

  @override
  String get planCardDeletePlan => 'Delete the plan';

  @override
  String planCardDeleteConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?\n\nThis action cannot be undone.';
  }
}
