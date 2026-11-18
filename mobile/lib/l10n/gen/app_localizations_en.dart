// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AdvocateMate';

  @override
  String get appTagline => 'Andhra Pradesh High Court, at your fingertips';

  @override
  String get navHome => 'Home';

  @override
  String get navMyCauseList => 'My List';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavourites => 'Saved';

  @override
  String get navMore => 'More';

  @override
  String get dashboard => 'Dashboard';

  @override
  String welcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get advocateCode => 'Advocate Code';

  @override
  String get advocateCodeHint => 'Enter your APHC advocate code';

  @override
  String get continueAction => 'Continue';

  @override
  String get confirmAction => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get download => 'Download';

  @override
  String get logout => 'Log out';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle =>
      'Use your advocate code. We verify your mobile number with a one-time password.';

  @override
  String get isThisYou => 'Is this you?';

  @override
  String get identityConfirm => 'Yes, this is me';

  @override
  String get identityDeny => 'No, change code';

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get mobileHint => '10-digit mobile number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String enterOtp(String target) {
    return 'Enter the OTP sent to $target';
  }

  @override
  String get verifyOtp => 'Verify & sign in';

  @override
  String get otpUnavailable =>
      'OTP sign-in is not available on this server yet.';

  @override
  String registeredMobileHint(String hint) {
    return 'This code is registered to $hint';
  }

  @override
  String get identityNote =>
      'Advocate codes are public, so your identity is verified through your mobile number.';

  @override
  String devOtpNotice(String otp) {
    return 'Development build: OTP is $otp';
  }

  @override
  String get today => 'Today';

  @override
  String get myCauseList => 'My Cause List';

  @override
  String get dailyCauseList => 'Daily Cause List';

  @override
  String get weeklyCauseList => 'Weekly Cause List';

  @override
  String get supplementaryCauseList => 'Supplementary Cause List';

  @override
  String get liveCourts => 'Live Court Display';

  @override
  String get searchCases => 'Search Cases';

  @override
  String get favouriteAdvocates => 'Favourite Advocates';

  @override
  String get favouriteCases => 'Saved Cases';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get publicationStatus => 'Cause-list publication';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectWeek => 'Select week';

  @override
  String court(String number) {
    return 'Court $number';
  }

  @override
  String itemNo(String number) {
    return 'Item $number';
  }

  @override
  String casesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases',
      one: '1 case',
      zero: 'No cases',
    );
    return '$_temp0';
  }

  @override
  String get petitioner => 'Petitioner';

  @override
  String get respondent => 'Respondent';

  @override
  String get petitionerAdvocates => 'Petitioner advocates';

  @override
  String get respondentAdvocates => 'Respondent advocates';

  @override
  String get versus => 'vs';

  @override
  String lastUpdated(String time) {
    return 'Last updated $time';
  }

  @override
  String get offlineBanner =>
      'Showing saved information. This data may not be current.';

  @override
  String get staleBanner =>
      'The court website could not be reached. Showing the last saved copy.';

  @override
  String get liveStaleBanner =>
      'This display data is out of date. It is NOT the current court position.';

  @override
  String get liveNotCurrent => 'Not current';

  @override
  String get liveCurrent => 'Live';

  @override
  String get notInSession => 'Not in session';

  @override
  String get sessionStarted => 'Session started';

  @override
  String get currentItem => 'Current item';

  @override
  String get keptBack => 'Kept back';

  @override
  String get autoRefresh => 'Auto-refresh';

  @override
  String get emptyCauseList => 'No cases are listed for this date.';

  @override
  String get dateNotOffered =>
      'APHC has not published a list for this date yet.';

  @override
  String get emptyFavourites => 'Nothing saved yet.';

  @override
  String get emptyNotifications => 'You have no notifications.';

  @override
  String get emptySearch => 'No matching cases in saved court data.';

  @override
  String get searchHint => 'Case number, party or advocate';

  @override
  String get searchHistory => 'Recent searches';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get filters => 'Filters';

  @override
  String get caseType => 'Case type';

  @override
  String get caseYear => 'Year';

  @override
  String get partyName => 'Party name';

  @override
  String get advocateName => 'Advocate name';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortSequence => 'Court order';

  @override
  String get sortCaseNumber => 'Case number';

  @override
  String get caseDetails => 'Case details';

  @override
  String get caseIdentity => 'Case identity';

  @override
  String get caseInformation => 'Case information';

  @override
  String get parties => 'Parties';

  @override
  String get advocates => 'Advocates';

  @override
  String get vakalath => 'Vakalath';

  @override
  String get listingHistory => 'Listings seen';

  @override
  String get additionalInformation => 'Additional information';

  @override
  String get notYetAvailable => 'Not yet available';

  @override
  String get enrichmentPending => 'Fetching latest details from APHC…';

  @override
  String get enrichmentRunning => 'Retrieving case details…';

  @override
  String get enrichmentCompleted => 'Details up to date';

  @override
  String get enrichmentFailed => 'Could not retrieve latest details';

  @override
  String get enrichmentStale => 'Saved details may be out of date';

  @override
  String get caseSummaryPdf => 'Case summary (generated)';

  @override
  String get generatedPdfNotice =>
      'Generated by AdvocateMate from public APHC data. This is NOT an official court document or order.';

  @override
  String get officialOrdersUnavailable =>
      'Official order PDFs are not available yet.';

  @override
  String get weeklyPdf => 'Weekly list PDF';

  @override
  String get officialPdf => 'Official APHC PDF';

  @override
  String downloading(int percent) {
    return 'Downloading $percent%';
  }

  @override
  String page(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get addFavourite => 'Save';

  @override
  String get removeFavourite => 'Remove';

  @override
  String get addAdvocate => 'Add advocate';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get clearCache => 'Clear saved data';

  @override
  String get cacheCleared => 'Saved data cleared';

  @override
  String get notificationPreferences => 'Notification preferences';

  @override
  String get prefPublication => 'Cause-list publication';

  @override
  String get prefFavouriteAdvocates => 'Favourite advocate listings';

  @override
  String get prefCaseUpdates => 'Saved case updates';

  @override
  String get prefCourtBoard => 'Court board alerts';

  @override
  String get prefEnrichment => 'Case details ready';

  @override
  String get prefAnnouncements => 'Announcements';

  @override
  String get identityStatus => 'Identity verification';

  @override
  String get identitySelfDeclared => 'Self-declared (mobile verified)';

  @override
  String get identityVerified => 'Verified';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get sessionExpired => 'Your session has ended. Please sign in again.';

  @override
  String source(String name) {
    return 'Source: $name';
  }

  @override
  String get about => 'About';

  @override
  String get dataNotice =>
      'Court data is retrieved from public Andhra Pradesh High Court sources. Always verify with the official cause list.';
}
