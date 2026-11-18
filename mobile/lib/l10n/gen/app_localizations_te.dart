// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'అడ్వకేట్‌మేట్';

  @override
  String get appTagline => 'ఆంధ్రప్రదేశ్ హైకోర్టు సమాచారం, మీ చేతిలో';

  @override
  String get navHome => 'హోమ్';

  @override
  String get navMyCauseList => 'నా జాబితా';

  @override
  String get navSearch => 'వెతకండి';

  @override
  String get navFavourites => 'సేవ్ చేసినవి';

  @override
  String get navMore => 'మరిన్ని';

  @override
  String get dashboard => 'డాష్‌బోర్డ్';

  @override
  String welcome(String name) {
    return 'స్వాగతం, $name';
  }

  @override
  String get advocateCode => 'న్యాయవాది కోడ్';

  @override
  String get advocateCodeHint => 'మీ APHC న్యాయవాది కోడ్ నమోదు చేయండి';

  @override
  String get continueAction => 'కొనసాగించండి';

  @override
  String get confirmAction => 'నిర్ధారించండి';

  @override
  String get cancel => 'రద్దు చేయండి';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get refresh => 'రిఫ్రెష్';

  @override
  String get save => 'సేవ్ చేయండి';

  @override
  String get share => 'షేర్ చేయండి';

  @override
  String get download => 'డౌన్‌లోడ్';

  @override
  String get logout => 'లాగ్ అవుట్';

  @override
  String get loginTitle => 'సైన్ ఇన్';

  @override
  String get loginSubtitle =>
      'మీ న్యాయవాది కోడ్ ఉపయోగించండి. మీ మొబైల్ నంబర్‌ను వన్-టైమ్ పాస్‌వర్డ్‌తో ధృవీకరిస్తాము.';

  @override
  String get isThisYou => 'ఇది మీరేనా?';

  @override
  String get identityConfirm => 'అవును, ఇది నేనే';

  @override
  String get identityDeny => 'కాదు, కోడ్ మార్చండి';

  @override
  String get mobileNumber => 'మొబైల్ నంబర్';

  @override
  String get mobileHint => '10 అంకెల మొబైల్ నంబర్';

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String enterOtp(String target) {
    return '$target కు పంపిన OTP నమోదు చేయండి';
  }

  @override
  String get verifyOtp => 'ధృవీకరించి సైన్ ఇన్ చేయండి';

  @override
  String get otpUnavailable => 'ఈ సర్వర్‌లో OTP సైన్-ఇన్ ఇంకా అందుబాటులో లేదు.';

  @override
  String registeredMobileHint(String hint) {
    return 'ఈ కోడ్ $hint నంబర్‌తో నమోదైంది';
  }

  @override
  String get identityNote =>
      'న్యాయవాది కోడ్‌లు బహిరంగమైనవి, కాబట్టి మీ గుర్తింపును మీ మొబైల్ నంబర్ ద్వారా ధృవీకరిస్తాము.';

  @override
  String devOtpNotice(String otp) {
    return 'డెవలప్‌మెంట్ బిల్డ్: OTP $otp';
  }

  @override
  String get today => 'ఈరోజు';

  @override
  String get myCauseList => 'నా కేసుల జాబితా';

  @override
  String get dailyCauseList => 'రోజువారీ కేసుల జాబితా';

  @override
  String get weeklyCauseList => 'వారపు కేసుల జాబితా';

  @override
  String get supplementaryCauseList => 'అనుబంధ కేసుల జాబితా';

  @override
  String get liveCourts => 'ప్రత్యక్ష కోర్టు డిస్‌ప్లే';

  @override
  String get searchCases => 'కేసులను వెతకండి';

  @override
  String get favouriteAdvocates => 'ఇష్టమైన న్యాయవాదులు';

  @override
  String get favouriteCases => 'సేవ్ చేసిన కేసులు';

  @override
  String get notifications => 'నోటిఫికేషన్లు';

  @override
  String get settings => 'సెట్టింగ్‌లు';

  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get publicationStatus => 'కేసుల జాబితా ప్రచురణ';

  @override
  String get selectDate => 'తేదీ ఎంచుకోండి';

  @override
  String get selectWeek => 'వారం ఎంచుకోండి';

  @override
  String court(String number) {
    return 'కోర్టు $number';
  }

  @override
  String itemNo(String number) {
    return 'అంశం $number';
  }

  @override
  String casesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count కేసులు',
      one: '1 కేసు',
      zero: 'కేసులు లేవు',
    );
    return '$_temp0';
  }

  @override
  String get petitioner => 'పిటిషనర్';

  @override
  String get respondent => 'ప్రతివాది';

  @override
  String get petitionerAdvocates => 'పిటిషనర్ న్యాయవాదులు';

  @override
  String get respondentAdvocates => 'ప్రతివాది న్యాయవాదులు';

  @override
  String get versus => 'vs';

  @override
  String lastUpdated(String time) {
    return 'చివరిగా నవీకరించింది $time';
  }

  @override
  String get offlineBanner =>
      'సేవ్ చేసిన సమాచారం చూపబడుతోంది. ఈ సమాచారం తాజాది కాకపోవచ్చు.';

  @override
  String get staleBanner =>
      'కోర్టు వెబ్‌సైట్ అందుబాటులో లేదు. చివరిగా సేవ్ చేసిన కాపీ చూపబడుతోంది.';

  @override
  String get liveStaleBanner =>
      'ఈ డిస్‌ప్లే సమాచారం పాతది. ఇది ప్రస్తుత కోర్టు స్థితి కాదు.';

  @override
  String get liveNotCurrent => 'ప్రస్తుతం కాదు';

  @override
  String get liveCurrent => 'ప్రత్యక్షం';

  @override
  String get notInSession => 'సెషన్‌లో లేదు';

  @override
  String get sessionStarted => 'సెషన్ ప్రారంభమైంది';

  @override
  String get currentItem => 'ప్రస్తుత అంశం';

  @override
  String get keptBack => 'వాయిదా వేసినవి';

  @override
  String get autoRefresh => 'ఆటో-రిఫ్రెష్';

  @override
  String get emptyCauseList => 'ఈ తేదీకి కేసులు జాబితాలో లేవు.';

  @override
  String get dateNotOffered => 'ఈ తేదీకి APHC ఇంకా జాబితా ప్రచురించలేదు.';

  @override
  String get emptyFavourites => 'ఇంకా ఏదీ సేవ్ చేయలేదు.';

  @override
  String get emptyNotifications => 'మీకు నోటిఫికేషన్లు లేవు.';

  @override
  String get emptySearch => 'సేవ్ చేసిన కోర్టు సమాచారంలో సరిపోలే కేసులు లేవు.';

  @override
  String get searchHint => 'కేసు నంబర్, పక్షం లేదా న్యాయవాది';

  @override
  String get searchHistory => 'ఇటీవలి శోధనలు';

  @override
  String get clearHistory => 'చరిత్రను తొలగించండి';

  @override
  String get filters => 'ఫిల్టర్లు';

  @override
  String get caseType => 'కేసు రకం';

  @override
  String get caseYear => 'సంవత్సరం';

  @override
  String get partyName => 'పక్షం పేరు';

  @override
  String get advocateName => 'న్యాయవాది పేరు';

  @override
  String get sortBy => 'క్రమం';

  @override
  String get sortSequence => 'కోర్టు క్రమం';

  @override
  String get sortCaseNumber => 'కేసు నంబర్';

  @override
  String get caseDetails => 'కేసు వివరాలు';

  @override
  String get caseIdentity => 'కేసు గుర్తింపు';

  @override
  String get caseInformation => 'కేసు సమాచారం';

  @override
  String get parties => 'పక్షాలు';

  @override
  String get advocates => 'న్యాయవాదులు';

  @override
  String get vakalath => 'వకాలత్';

  @override
  String get listingHistory => 'నమోదైన జాబితాలు';

  @override
  String get additionalInformation => 'అదనపు సమాచారం';

  @override
  String get notYetAvailable => 'ఇంకా అందుబాటులో లేదు';

  @override
  String get enrichmentPending => 'APHC నుండి తాజా వివరాలు పొందుతున్నాము…';

  @override
  String get enrichmentRunning => 'కేసు వివరాలు పొందుతున్నాము…';

  @override
  String get enrichmentCompleted => 'వివరాలు తాజావి';

  @override
  String get enrichmentFailed => 'తాజా వివరాలు పొందలేకపోయాము';

  @override
  String get enrichmentStale => 'సేవ్ చేసిన వివరాలు పాతవి కావచ్చు';

  @override
  String get caseSummaryPdf => 'కేసు సారాంశం (రూపొందించినది)';

  @override
  String get generatedPdfNotice =>
      'బహిరంగ APHC సమాచారం నుండి అడ్వకేట్‌మేట్ రూపొందించింది. ఇది అధికారిక కోర్టు పత్రం లేదా ఉత్తర్వు కాదు.';

  @override
  String get officialOrdersUnavailable =>
      'అధికారిక ఉత్తర్వుల PDFలు ఇంకా అందుబాటులో లేవు.';

  @override
  String get weeklyPdf => 'వారపు జాబితా PDF';

  @override
  String get officialPdf => 'అధికారిక APHC PDF';

  @override
  String downloading(int percent) {
    return 'డౌన్‌లోడ్ అవుతోంది $percent%';
  }

  @override
  String page(int current, int total) {
    return 'పేజీ $current / $total';
  }

  @override
  String get addFavourite => 'సేవ్ చేయండి';

  @override
  String get removeFavourite => 'తొలగించండి';

  @override
  String get addAdvocate => 'న్యాయవాదిని జోడించండి';

  @override
  String get language => 'భాష';

  @override
  String get theme => 'థీమ్';

  @override
  String get themeSystem => 'సిస్టమ్';

  @override
  String get themeLight => 'లైట్';

  @override
  String get themeDark => 'డార్క్';

  @override
  String get clearCache => 'సేవ్ చేసిన సమాచారం తొలగించండి';

  @override
  String get cacheCleared => 'సేవ్ చేసిన సమాచారం తొలగించబడింది';

  @override
  String get notificationPreferences => 'నోటిఫికేషన్ ప్రాధాన్యతలు';

  @override
  String get prefPublication => 'కేసుల జాబితా ప్రచురణ';

  @override
  String get prefFavouriteAdvocates => 'ఇష్టమైన న్యాయవాదుల జాబితాలు';

  @override
  String get prefCaseUpdates => 'సేవ్ చేసిన కేసుల నవీకరణలు';

  @override
  String get prefCourtBoard => 'కోర్టు బోర్డు హెచ్చరికలు';

  @override
  String get prefEnrichment => 'కేసు వివరాలు సిద్ధం';

  @override
  String get prefAnnouncements => 'ప్రకటనలు';

  @override
  String get identityStatus => 'గుర్తింపు ధృవీకరణ';

  @override
  String get identitySelfDeclared =>
      'స్వయంగా ప్రకటించినది (మొబైల్ ధృవీకరించబడింది)';

  @override
  String get identityVerified => 'ధృవీకరించబడింది';

  @override
  String get markAllRead => 'అన్నీ చదివినట్లు గుర్తించండి';

  @override
  String get errorGeneric =>
      'ఏదో పొరపాటు జరిగింది. దయచేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get errorNetwork => 'ఇంటర్నెట్ కనెక్షన్ లేదు.';

  @override
  String get sessionExpired =>
      'మీ సెషన్ ముగిసింది. దయచేసి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String source(String name) {
    return 'మూలం: $name';
  }

  @override
  String get about => 'గురించి';

  @override
  String get dataNotice =>
      'కోర్టు సమాచారం బహిరంగ ఆంధ్రప్రదేశ్ హైకోర్టు మూలాల నుండి పొందబడుతుంది. ఎల్లప్పుడూ అధికారిక కేసుల జాబితాతో సరిచూసుకోండి.';
}
