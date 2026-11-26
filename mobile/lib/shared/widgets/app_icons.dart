import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart' show IconData;

/// The app's only icon set: Lucide, one stroke weight. Screens refer to icons by meaning
/// (`AppIcons.court`), never by a library glyph, so the look stays consistent.
abstract final class AppIcons {
  // Sizes
  static const sizeSm = 18.0;
  static const size = 20.0;
  static const sizeMd = 22.0;
  static const sizeLg = 24.0;

  // Navigation
  static const IconData home = LucideIcons.house;
  static const IconData myList = LucideIcons.clipboardList;
  static const IconData search = LucideIcons.search;
  static const IconData saved = LucideIcons.bookmark;
  static const IconData more = LucideIcons.layoutGrid;

  // Cause lists and courts
  static const IconData daily = LucideIcons.calendarDays;
  static const IconData weekly = LucideIcons.calendarRange;
  static const IconData supplementary = LucideIcons.calendarPlus;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData dateMissing = LucideIcons.calendarX2;
  static const IconData passedOver = LucideIcons.listRestart;
  static const IconData liveBoard = LucideIcons.monitorPlay;
  static const IconData court = LucideIcons.landmark;
  static const IconData judge = LucideIcons.scale;
  static const IconData cases = LucideIcons.briefcaseBusiness;
  static const IconData caseUpdate = LucideIcons.gavel;
  static const IconData advocate = LucideIcons.userRound;
  static const IconData advocates = LucideIcons.users;
  static const IconData advocateSearch = LucideIcons.userSearch;
  static const IconData addAdvocate = LucideIcons.userPlus;
  static const IconData advocateCode = LucideIcons.idCard;
  static const IconData listing = LucideIcons.scrollText;
  static const IconData publication = LucideIcons.megaphone;

  // Account
  static const IconData notifications = LucideIcons.bell;
  static const IconData notificationsOff = LucideIcons.bellOff;
  static const IconData profile = LucideIcons.circleUserRound;
  static const IconData settings = LucideIcons.settings;
  static const IconData support = LucideIcons.lifeBuoy;
  static const IconData switchAccount = LucideIcons.arrowLeftRight;
  static const IconData logout = LucideIcons.logOut;
  static const IconData signIn = LucideIcons.logIn;
  static const IconData email = LucideIcons.mail;
  static const IconData verified = LucideIcons.badgeCheck;
  static const IconData shield = LucideIcons.shieldCheck;
  static const IconData language = LucideIcons.languages;
  static const IconData theme = LucideIcons.sunMoon;
  static const IconData clearData = LucideIcons.eraser;
  static const IconData info = LucideIcons.info;

  // Saving
  static const IconData save = LucideIcons.bookmarkPlus;
  static const IconData savedOn = LucideIcons.bookmarkCheck;
  static const IconData delete = LucideIcons.trash2;

  // Actions
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData filters = LucideIcons.slidersHorizontal;
  static const IconData sort = LucideIcons.arrowUpDown;
  static const IconData clear = LucideIcons.x;
  static const IconData share = LucideIcons.share2;
  static const IconData pdf = LucideIcons.fileText;
  static const IconData suggestion = LucideIcons.arrowUpLeft;
  static const IconData openExternal = LucideIcons.squareArrowOutUpRight;

  // States
  static const IconData empty = LucideIcons.inbox;
  static const IconData searchEmpty = LucideIcons.searchX;
  static const IconData offline = LucideIcons.wifiOff;
  static const IconData error = LucideIcons.circleAlert;
  static const IconData warning = LucideIcons.triangleAlert;
  static const IconData history = LucideIcons.history;
  static const IconData clock = LucideIcons.clock;
  static const IconData sync = LucideIcons.refreshCw;
  static const IconData check = LucideIcons.check;
  static const IconData checkCircle = LucideIcons.circleCheck;
  static const IconData offBoard = LucideIcons.circleMinus;
  static const IconData differs = LucideIcons.gitCompareArrows;
  static const IconData unknown = LucideIcons.circleHelp;
  static const IconData liveDot = LucideIcons.circleDot;
  static const IconData factCheck = LucideIcons.fileCheck;
}
