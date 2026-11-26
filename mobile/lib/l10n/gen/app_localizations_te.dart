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

  @override
  String get signInWithGoogle => 'Google తో సైన్ ఇన్ చేయండి';

  @override
  String get googleSignInSubtitle =>
      'మీ న్యాయవాది కోడ్‌కు నమోదైన Google ఖాతాను ఉపయోగించండి.';

  @override
  String get googleSignInNote =>
      'మీ గుర్తింపు న్యాయవాదుల రిజిస్ట్రీతో స్వయంచాలకంగా ధృవీకరించబడుతుంది.';

  @override
  String get advocateCodeTitle => 'మీ న్యాయవాది కోడ్ నమోదు చేయండి';

  @override
  String signedInAsGoogle(String email) {
    return '$email గా Google తో సైన్ ఇన్ అయ్యారు';
  }

  @override
  String get verifyAndContinue => 'ధృవీకరించి కొనసాగించండి';

  @override
  String get useDifferentAccount => 'వేరే Google ఖాతాను ఉపయోగించండి';

  @override
  String get switchGoogleAccount => 'Google ఖాతా మార్చండి';

  @override
  String get googleAccount => 'Google ఖాతా';

  @override
  String get identityRegistryVerified =>
      'న్యాయవాదుల రిజిస్ట్రీతో ధృవీకరించబడింది';

  @override
  String get errInvalidAdvocateCode =>
      'చెల్లని న్యాయవాది కోడ్. దయచేసి మీ కోడ్‌ను తనిఖీ చేసి మళ్ళీ ప్రయత్నించండి.';

  @override
  String get errEmailMismatch =>
      'మీ Google ఖాతా ఇమెయిల్ ఈ న్యాయవాది కోడ్‌కు నమోదైన ఇమెయిల్‌తో సరిపోలడం లేదు. దయచేసి మీ నమోదిత ఇమెయిల్‌తో సైన్ ఇన్ చేయండి.';

  @override
  String get errAdvocateAlreadyLinked =>
      'ఈ న్యాయవాది కోడ్ ఇప్పటికే వేరే Google ఖాతాకు లింక్ చేయబడింది.';

  @override
  String get errGoogleLinkedElsewhere =>
      'ఈ Google ఖాతా ఇప్పటికే వేరే న్యాయవాది కోడ్‌కు లింక్ చేయబడింది.';

  @override
  String get errAdvocateNotEligible =>
      'ఈ న్యాయవాది కోడ్ అడ్వకేట్‌మేట్ ఉపయోగానికి క్రియాశీలంగా లేదు.';

  @override
  String get errRegistryEmailMissing =>
      'ఈ న్యాయవాది కోడ్‌కు నమోదైన ఇమెయిల్ లేదు, కాబట్టి ధృవీకరించలేము.';

  @override
  String get errGoogleCancelled => 'Google సైన్ ఇన్ రద్దు చేయబడింది.';

  @override
  String get errGoogleNotConfigured =>
      'ఈ యాప్ వెర్షన్‌లో Google సైన్ ఇన్ సెటప్ చేయబడలేదు.';

  @override
  String get errGoogleUnavailable =>
      'ఈ పరికరంలో Google సైన్ ఇన్ అందుబాటులో లేదు.';

  @override
  String get errGoogleEmailUnverified =>
      'మీ Google ఖాతా ఇమెయిల్ ధృవీకరించబడలేదు.';

  @override
  String get errLinkExpired =>
      'మీ Google సైన్ ఇన్ గడువు ముగిసింది. దయచేసి మళ్ళీ సైన్ ఇన్ చేయండి.';

  @override
  String get accessEndedNotEligible =>
      'యాక్సెస్ ముగిసింది: ఈ న్యాయవాది కోడ్ ఇకపై క్రియాశీలంగా లేదు.';

  @override
  String get passedOverList => 'పాస్-ఓవర్ జాబితా';

  @override
  String get passedOverIntro =>
      'కోర్టు వెనక్కి ఉంచిన (పాస్-ఓవర్) కేసులు, APHC డిస్‌ప్లే బోర్డు నుండి.';

  @override
  String passedOverRecordedSince(String time) {
    return '$time నుండి నమోదు చేయబడింది';
  }

  @override
  String passedOverSummary(int total, int pending) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total అంశాలు',
      one: '1 అంశం',
    );
    return '$_temp0 · $pending పెండింగ్';
  }

  @override
  String get passedOverNone => 'ఈ తేదీకి పాస్-ఓవర్ అంశాలు ఏవీ నమోదు కాలేదు.';

  @override
  String get passedOverPending => 'పెండింగ్';

  @override
  String get passedOverNoLongerPending => 'ఇక పెండింగ్‌లో లేదు';

  @override
  String get passedOverOffBoard => 'బోర్డులో లేదు';

  @override
  String passedOverKeptAt(String time) {
    return '$timeకి వెనక్కి ఉంచబడింది';
  }

  @override
  String passedOverNowAt(String item) {
    return 'ప్రస్తుతం $item';
  }

  @override
  String passedOverItemNotFound(String item) {
    return 'అంశం $item (కోర్టు జాబితాలో కనబడలేదు)';
  }

  @override
  String get passedOverNote =>
      'AdvocateMate బోర్డును తనిఖీ చేసినప్పుడు చూసినవి మాత్రమే. ఎల్లప్పుడూ కోర్టులో నిర్ధారించుకోండి.';

  @override
  String get passedOverBoardStale =>
      'డిస్‌ప్లే బోర్డు ఇటీవల నవీకరించబడలేదు. స్థితులు పాతవి కావచ్చు.';

  @override
  String pdfVerified(int count) {
    return 'అధికారిక PDFతో సరిపోలింది ($count అంశాలు తనిఖీ చేయబడ్డాయి)';
  }

  @override
  String pdfDifferences(int differs, int missing, int extra) {
    return 'అధికారిక PDFతో తనిఖీ: $differs తేడాలు, $missing PDFలో లేవు, $extra PDFలో మాత్రమే ఉన్నాయి';
  }

  @override
  String get pdfShowDifferences => 'తేడాలు చూపించు';

  @override
  String get pdfShowAll => 'అన్నీ చూపించు';

  @override
  String get pdfUnreadable => 'తనిఖీ కోసం అధికారిక PDFని చదవలేకపోయాం.';

  @override
  String get pdfNotAvailable =>
      'తనిఖీ చేయడానికి అధికారిక PDF ఇంకా అందుబాటులో లేదు.';

  @override
  String get pdfFallbackUnavailable =>
      'ఆన్‌లైన్ జాబితా లోడ్ కాలేదు. ఈ అంశాలు అధికారిక PDF నుండి చదవబడ్డాయి.';

  @override
  String get pdfFallbackEmpty =>
      'ఆన్‌లైన్ జాబితా ఖాళీగా ఉంది. ఈ అంశాలు అధికారిక PDF నుండి చదవబడ్డాయి.';

  @override
  String get pdfDiffersBadge => 'PDF నుండి తేడా';

  @override
  String get pdfNotInPdfBadge => 'PDFలో లేదు';

  @override
  String get pdfOnlyTitle => 'అధికారిక PDFలో మాత్రమే';

  @override
  String get courtWise => 'కోర్టు వారీగా';

  @override
  String get advocateCodeWise => 'న్యాయవాది కోడ్';

  @override
  String get advocateLookupHint => 'న్యాయవాది కోడ్ నమోదు చేయండి';

  @override
  String get advocateLookupView => 'చూడండి';

  @override
  String get advocateLookupIntro =>
      'ఏ న్యాయవాది కోడ్‌నైనా నమోదు చేసి, కాజ్ లిస్ట్‌లో వారి కేసులు చూడండి.';

  @override
  String get advocateLookupSource =>
      'హైకోర్టు Lexika సేవ నుండి. దాని తేదీలు డైలీ జాబితా కంటే ఒక రోజు వెనుక ఉండవచ్చు.';

  @override
  String get advocateLookupRecent => 'ఇటీవలివి';

  @override
  String get advocateLookupInvalid => 'అంకెలు మాత్రమే నమోదు చేయండి (8 వరకు).';

  @override
  String get errAdvocateNotFound =>
      'ఈ కోడ్‌కు న్యాయవాది కనబడలేదు. కోడ్ సరిచూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get errTooManyLookups =>
      'చాలా ఎక్కువ న్యాయవాది శోధనలు. కొన్ని నిమిషాలు ఆగి మళ్లీ ప్రయత్నించండి.';

  @override
  String get quickAccess => 'త్వరిత ప్రవేశం';

  @override
  String get sectionCauseLists => 'కాజ్ లిస్ట్‌లు';

  @override
  String get sectionAccount => 'ఖాతా';

  @override
  String get sectionAppearance => 'రూపం';

  @override
  String get sectionData => 'డేటా మరియు గోప్యత';

  @override
  String stepOf(int current, int total) {
    return 'దశ $current/$total';
  }

  @override
  String get viewAll => 'అన్నీ చూడండి';

  @override
  String get liveDisplayBoard => 'లైవ్ డిస్‌ప్లే బోర్డ్';

  @override
  String get courtShortName => 'ఏపీ హైకోర్టు';

  @override
  String get justiceForAll => 'అందరికీ న్యాయం';

  @override
  String get justiceForAllSubtitle =>
      'స్మార్ట్ లీగల్ టూల్స్‌తో న్యాయవాదులకు సాధికారత';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get savingPdf => 'PDF సేవ్ అవుతోంది…';

  @override
  String pdfSaved(String location) {
    return 'PDF $locationలో సేవ్ అయింది';
  }

  @override
  String pdfAlreadySaved(String location) {
    return 'ఈ PDF ఇప్పటికే $locationలో సేవ్ అయి ఉంది';
  }

  @override
  String get pdfSaveFailed => 'PDF సేవ్ చేయలేకపోయాం. మళ్లీ ప్రయత్నించండి.';

  @override
  String get pdfSavePermission =>
      'PDFలను ఈ పరికరంలో సేవ్ చేయడానికి నిల్వ అనుమతి ఇవ్వండి.';
}
