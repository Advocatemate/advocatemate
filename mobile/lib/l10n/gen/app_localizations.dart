import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('te')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AdvocateMate'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Andhra Pradesh High Court, at your fingertips'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMyCauseList.
  ///
  /// In en, this message translates to:
  /// **'My List'**
  String get navMyCauseList;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFavourites.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navFavourites;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcome(String name);

  /// No description provided for @advocateCode.
  ///
  /// In en, this message translates to:
  /// **'Advocate Code'**
  String get advocateCode;

  /// No description provided for @advocateCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your APHC advocate code'**
  String get advocateCodeHint;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmAction;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @myCauseList.
  ///
  /// In en, this message translates to:
  /// **'My Cause List'**
  String get myCauseList;

  /// No description provided for @dailyCauseList.
  ///
  /// In en, this message translates to:
  /// **'Daily Cause List'**
  String get dailyCauseList;

  /// No description provided for @weeklyCauseList.
  ///
  /// In en, this message translates to:
  /// **'Weekly Cause List'**
  String get weeklyCauseList;

  /// No description provided for @supplementaryCauseList.
  ///
  /// In en, this message translates to:
  /// **'Supplementary Cause List'**
  String get supplementaryCauseList;

  /// No description provided for @liveCourts.
  ///
  /// In en, this message translates to:
  /// **'Live Court Display'**
  String get liveCourts;

  /// No description provided for @searchCases.
  ///
  /// In en, this message translates to:
  /// **'Search Cases'**
  String get searchCases;

  /// No description provided for @favouriteAdvocates.
  ///
  /// In en, this message translates to:
  /// **'Favourite Advocates'**
  String get favouriteAdvocates;

  /// No description provided for @favouriteCases.
  ///
  /// In en, this message translates to:
  /// **'Saved Cases'**
  String get favouriteCases;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @publicationStatus.
  ///
  /// In en, this message translates to:
  /// **'Cause-list publication'**
  String get publicationStatus;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select week'**
  String get selectWeek;

  /// No description provided for @court.
  ///
  /// In en, this message translates to:
  /// **'Court {number}'**
  String court(String number);

  /// No description provided for @itemNo.
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String itemNo(String number);

  /// No description provided for @casesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No cases} =1{1 case} other{{count} cases}}'**
  String casesCount(int count);

  /// No description provided for @petitioner.
  ///
  /// In en, this message translates to:
  /// **'Petitioner'**
  String get petitioner;

  /// No description provided for @respondent.
  ///
  /// In en, this message translates to:
  /// **'Respondent'**
  String get respondent;

  /// No description provided for @petitionerAdvocates.
  ///
  /// In en, this message translates to:
  /// **'Petitioner advocates'**
  String get petitionerAdvocates;

  /// No description provided for @respondentAdvocates.
  ///
  /// In en, this message translates to:
  /// **'Respondent advocates'**
  String get respondentAdvocates;

  /// No description provided for @versus.
  ///
  /// In en, this message translates to:
  /// **'vs'**
  String get versus;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String lastUpdated(String time);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Showing saved information. This data may not be current.'**
  String get offlineBanner;

  /// No description provided for @staleBanner.
  ///
  /// In en, this message translates to:
  /// **'The court website could not be reached. Showing the last saved copy.'**
  String get staleBanner;

  /// No description provided for @liveStaleBanner.
  ///
  /// In en, this message translates to:
  /// **'This display data is out of date. It is NOT the current court position.'**
  String get liveStaleBanner;

  /// No description provided for @liveNotCurrent.
  ///
  /// In en, this message translates to:
  /// **'Not current'**
  String get liveNotCurrent;

  /// No description provided for @liveCurrent.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveCurrent;

  /// No description provided for @notInSession.
  ///
  /// In en, this message translates to:
  /// **'Not in session'**
  String get notInSession;

  /// No description provided for @sessionStarted.
  ///
  /// In en, this message translates to:
  /// **'Session started'**
  String get sessionStarted;

  /// No description provided for @currentItem.
  ///
  /// In en, this message translates to:
  /// **'Current item'**
  String get currentItem;

  /// No description provided for @keptBack.
  ///
  /// In en, this message translates to:
  /// **'Kept back'**
  String get keptBack;

  /// No description provided for @autoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh'**
  String get autoRefresh;

  /// No description provided for @emptyCauseList.
  ///
  /// In en, this message translates to:
  /// **'No cases are listed for this date.'**
  String get emptyCauseList;

  /// No description provided for @dateNotOffered.
  ///
  /// In en, this message translates to:
  /// **'APHC has not published a list for this date yet.'**
  String get dateNotOffered;

  /// No description provided for @emptyFavourites.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet.'**
  String get emptyFavourites;

  /// No description provided for @emptyNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications.'**
  String get emptyNotifications;

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'No matching cases in saved court data.'**
  String get emptySearch;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Case number, party or advocate'**
  String get searchHint;

  /// No description provided for @searchHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchHistory;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @caseType.
  ///
  /// In en, this message translates to:
  /// **'Case type'**
  String get caseType;

  /// No description provided for @caseYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get caseYear;

  /// No description provided for @partyName.
  ///
  /// In en, this message translates to:
  /// **'Party name'**
  String get partyName;

  /// No description provided for @advocateName.
  ///
  /// In en, this message translates to:
  /// **'Advocate name'**
  String get advocateName;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortSequence.
  ///
  /// In en, this message translates to:
  /// **'Court order'**
  String get sortSequence;

  /// No description provided for @sortCaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Case number'**
  String get sortCaseNumber;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Case details'**
  String get caseDetails;

  /// No description provided for @caseIdentity.
  ///
  /// In en, this message translates to:
  /// **'Case identity'**
  String get caseIdentity;

  /// No description provided for @caseInformation.
  ///
  /// In en, this message translates to:
  /// **'Case information'**
  String get caseInformation;

  /// No description provided for @parties.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get parties;

  /// No description provided for @advocates.
  ///
  /// In en, this message translates to:
  /// **'Advocates'**
  String get advocates;

  /// No description provided for @vakalath.
  ///
  /// In en, this message translates to:
  /// **'Vakalath'**
  String get vakalath;

  /// No description provided for @listingHistory.
  ///
  /// In en, this message translates to:
  /// **'Listings seen'**
  String get listingHistory;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additionalInformation;

  /// No description provided for @notYetAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not yet available'**
  String get notYetAvailable;

  /// No description provided for @enrichmentPending.
  ///
  /// In en, this message translates to:
  /// **'Fetching latest details from APHC…'**
  String get enrichmentPending;

  /// No description provided for @enrichmentRunning.
  ///
  /// In en, this message translates to:
  /// **'Retrieving case details…'**
  String get enrichmentRunning;

  /// No description provided for @enrichmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Details up to date'**
  String get enrichmentCompleted;

  /// No description provided for @enrichmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve latest details'**
  String get enrichmentFailed;

  /// No description provided for @enrichmentStale.
  ///
  /// In en, this message translates to:
  /// **'Saved details may be out of date'**
  String get enrichmentStale;

  /// No description provided for @caseSummaryPdf.
  ///
  /// In en, this message translates to:
  /// **'Case summary (generated)'**
  String get caseSummaryPdf;

  /// No description provided for @generatedPdfNotice.
  ///
  /// In en, this message translates to:
  /// **'Generated by AdvocateMate from public APHC data. This is NOT an official court document or order.'**
  String get generatedPdfNotice;

  /// No description provided for @officialOrdersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Official order PDFs are not available yet.'**
  String get officialOrdersUnavailable;

  /// No description provided for @weeklyPdf.
  ///
  /// In en, this message translates to:
  /// **'Weekly list PDF'**
  String get weeklyPdf;

  /// No description provided for @officialPdf.
  ///
  /// In en, this message translates to:
  /// **'Official APHC PDF'**
  String get officialPdf;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {percent}%'**
  String downloading(int percent);

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String page(int current, int total);

  /// No description provided for @addFavourite.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get addFavourite;

  /// No description provided for @removeFavourite.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFavourite;

  /// No description provided for @addAdvocate.
  ///
  /// In en, this message translates to:
  /// **'Add advocate'**
  String get addAdvocate;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear saved data'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Saved data cleared'**
  String get cacheCleared;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @prefPublication.
  ///
  /// In en, this message translates to:
  /// **'Cause-list publication'**
  String get prefPublication;

  /// No description provided for @prefFavouriteAdvocates.
  ///
  /// In en, this message translates to:
  /// **'Favourite advocate listings'**
  String get prefFavouriteAdvocates;

  /// No description provided for @prefCaseUpdates.
  ///
  /// In en, this message translates to:
  /// **'Saved case updates'**
  String get prefCaseUpdates;

  /// No description provided for @prefCourtBoard.
  ///
  /// In en, this message translates to:
  /// **'Court board alerts'**
  String get prefCourtBoard;

  /// No description provided for @prefEnrichment.
  ///
  /// In en, this message translates to:
  /// **'Case details ready'**
  String get prefEnrichment;

  /// No description provided for @prefAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get prefAnnouncements;

  /// No description provided for @identityStatus.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityStatus;

  /// No description provided for @identityVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get identityVerified;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source: {name}'**
  String source(String name);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @dataNotice.
  ///
  /// In en, this message translates to:
  /// **'Court data is retrieved from public Andhra Pradesh High Court sources. Always verify with the official cause list.'**
  String get dataNotice;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @googleSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the Google account registered for your advocate code.'**
  String get googleSignInSubtitle;

  /// No description provided for @googleSignInNote.
  ///
  /// In en, this message translates to:
  /// **'Your identity is verified automatically against the advocate registry.'**
  String get googleSignInNote;

  /// No description provided for @advocateCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your Advocate Code'**
  String get advocateCodeTitle;

  /// No description provided for @signedInAsGoogle.
  ///
  /// In en, this message translates to:
  /// **'Signed in with Google as {email}'**
  String signedInAsGoogle(String email);

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get verifyAndContinue;

  /// No description provided for @useDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different Google account'**
  String get useDifferentAccount;

  /// No description provided for @switchGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Google account'**
  String get switchGoogleAccount;

  /// No description provided for @googleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google account'**
  String get googleAccount;

  /// No description provided for @identityRegistryVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified against the advocate registry'**
  String get identityRegistryVerified;

  /// No description provided for @errInvalidAdvocateCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Advocate Code. Please check your code and try again.'**
  String get errInvalidAdvocateCode;

  /// No description provided for @errEmailMismatch.
  ///
  /// In en, this message translates to:
  /// **'Your Google account email does not match the email registered for this advocate code. Please sign in with your registered email address.'**
  String get errEmailMismatch;

  /// No description provided for @errAdvocateAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'This advocate code is already linked to a different Google account.'**
  String get errAdvocateAlreadyLinked;

  /// No description provided for @errGoogleLinkedElsewhere.
  ///
  /// In en, this message translates to:
  /// **'This Google account is already linked to a different advocate code.'**
  String get errGoogleLinkedElsewhere;

  /// No description provided for @errAdvocateNotEligible.
  ///
  /// In en, this message translates to:
  /// **'This advocate code is not active for AdvocateMate access.'**
  String get errAdvocateNotEligible;

  /// No description provided for @errRegistryEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'This advocate code has no registered email address, so it cannot be verified.'**
  String get errRegistryEmailMissing;

  /// No description provided for @errGoogleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get errGoogleCancelled;

  /// No description provided for @errGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not set up in this version of the app.'**
  String get errGoogleNotConfigured;

  /// No description provided for @errGoogleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not available on this device.'**
  String get errGoogleUnavailable;

  /// No description provided for @errGoogleEmailUnverified.
  ///
  /// In en, this message translates to:
  /// **'Your Google account email is not verified.'**
  String get errGoogleEmailUnverified;

  /// No description provided for @errLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'Your Google sign-in expired. Please sign in again.'**
  String get errLinkExpired;

  /// No description provided for @accessEndedNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Access ended: this advocate code is no longer active.'**
  String get accessEndedNotEligible;

  /// No description provided for @passedOverList.
  ///
  /// In en, this message translates to:
  /// **'Passed-over list'**
  String get passedOverList;

  /// No description provided for @passedOverIntro.
  ///
  /// In en, this message translates to:
  /// **'Cases the court kept back (passed over), from the APHC display board.'**
  String get passedOverIntro;

  /// No description provided for @passedOverRecordedSince.
  ///
  /// In en, this message translates to:
  /// **'Recorded since {time}'**
  String passedOverRecordedSince(String time);

  /// No description provided for @passedOverSummary.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, =1{1 item} other{{total} items}} · {pending} pending'**
  String passedOverSummary(int total, int pending);

  /// No description provided for @passedOverNone.
  ///
  /// In en, this message translates to:
  /// **'No passed-over items were recorded for this date.'**
  String get passedOverNone;

  /// No description provided for @passedOverPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get passedOverPending;

  /// No description provided for @passedOverNoLongerPending.
  ///
  /// In en, this message translates to:
  /// **'No longer pending'**
  String get passedOverNoLongerPending;

  /// No description provided for @passedOverOffBoard.
  ///
  /// In en, this message translates to:
  /// **'Off the board'**
  String get passedOverOffBoard;

  /// No description provided for @passedOverKeptAt.
  ///
  /// In en, this message translates to:
  /// **'Kept back at {time}'**
  String passedOverKeptAt(String time);

  /// No description provided for @passedOverNowAt.
  ///
  /// In en, this message translates to:
  /// **'Now at {item}'**
  String passedOverNowAt(String item);

  /// No description provided for @passedOverItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item {item} (not found in the court\'s list)'**
  String passedOverItemNotFound(String item);

  /// No description provided for @passedOverNote.
  ///
  /// In en, this message translates to:
  /// **'Shows only what AdvocateMate saw while checking the board. Always confirm in court.'**
  String get passedOverNote;

  /// No description provided for @passedOverBoardStale.
  ///
  /// In en, this message translates to:
  /// **'The display board has not updated recently. Statuses may be out of date.'**
  String get passedOverBoardStale;

  /// No description provided for @pdfVerified.
  ///
  /// In en, this message translates to:
  /// **'Matches the official PDF ({count} items checked)'**
  String pdfVerified(int count);

  /// No description provided for @pdfDifferences.
  ///
  /// In en, this message translates to:
  /// **'Checked against the official PDF: {differs} differ, {missing} not in the PDF, {extra} only in the PDF'**
  String pdfDifferences(int differs, int missing, int extra);

  /// No description provided for @pdfShowDifferences.
  ///
  /// In en, this message translates to:
  /// **'Show differences'**
  String get pdfShowDifferences;

  /// No description provided for @pdfShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get pdfShowAll;

  /// No description provided for @pdfUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The official PDF could not be read for checking.'**
  String get pdfUnreadable;

  /// No description provided for @pdfNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No official PDF to check against yet.'**
  String get pdfNotAvailable;

  /// No description provided for @pdfFallbackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The online list could not be loaded. These items were read from the official PDF.'**
  String get pdfFallbackUnavailable;

  /// No description provided for @pdfFallbackEmpty.
  ///
  /// In en, this message translates to:
  /// **'The online list is empty. These items were read from the official PDF.'**
  String get pdfFallbackEmpty;

  /// No description provided for @pdfDiffersBadge.
  ///
  /// In en, this message translates to:
  /// **'Differs from PDF'**
  String get pdfDiffersBadge;

  /// No description provided for @pdfNotInPdfBadge.
  ///
  /// In en, this message translates to:
  /// **'Not in PDF'**
  String get pdfNotInPdfBadge;

  /// No description provided for @pdfOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Only in the official PDF'**
  String get pdfOnlyTitle;

  /// No description provided for @courtWise.
  ///
  /// In en, this message translates to:
  /// **'Court-wise'**
  String get courtWise;

  /// No description provided for @advocateCodeWise.
  ///
  /// In en, this message translates to:
  /// **'Advocate code'**
  String get advocateCodeWise;

  /// No description provided for @advocateLookupHint.
  ///
  /// In en, this message translates to:
  /// **'Enter an advocate code'**
  String get advocateLookupHint;

  /// No description provided for @advocateLookupView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get advocateLookupView;

  /// No description provided for @advocateLookupIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter any advocate\'s code to see their cases in the cause list.'**
  String get advocateLookupIntro;

  /// No description provided for @advocateLookupSource.
  ///
  /// In en, this message translates to:
  /// **'From the High Court\'s Lexika service. Its dates can be a day behind the Daily list.'**
  String get advocateLookupSource;

  /// No description provided for @advocateLookupRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get advocateLookupRecent;

  /// No description provided for @advocateLookupInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter digits only (up to 8).'**
  String get advocateLookupInvalid;

  /// No description provided for @errAdvocateNotFound.
  ///
  /// In en, this message translates to:
  /// **'No advocate was found for this code. Check the code and try again.'**
  String get errAdvocateNotFound;

  /// No description provided for @errTooManyLookups.
  ///
  /// In en, this message translates to:
  /// **'Too many advocate lookups. Please wait a few minutes and try again.'**
  String get errTooManyLookups;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quickAccess;

  /// No description provided for @shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// No description provided for @sectionCauseLists.
  ///
  /// In en, this message translates to:
  /// **'Cause lists'**
  String get sectionCauseLists;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data and privacy'**
  String get sectionData;

  /// No description provided for @todaysCauseList.
  ///
  /// In en, this message translates to:
  /// **'Today\'s cause list'**
  String get todaysCauseList;

  /// No description provided for @viewMyList.
  ///
  /// In en, this message translates to:
  /// **'View my list'**
  String get viewMyList;

  /// No description provided for @courtsUploaded.
  ///
  /// In en, this message translates to:
  /// **'{uploaded} of {total} courts uploaded'**
  String courtsUploaded(int uploaded, int total);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
