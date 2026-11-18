// API models (freezed + json_serializable, snake_case keys via build.yaml).
// Dates are kept as the ISO strings the backend sends; parse them in the UI.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// ------------------------------------------------------------------ auth
@freezed
abstract class Me with _$Me {
  const factory Me({
    required String userId,
    required String role,
    @Default('en') String preferredLanguage,
    String? advocateCode,
    String? advocateName,
    String? displayName,
    String? email,
    String? identityVerification,
    String? mobile,
    String? createdAt,
  }) = _Me;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);
}

@freezed
abstract class RegisterInfo with _$RegisterInfo {
  const factory RegisterInfo({
    required String advocateCode,
    required String advocateName,
    required String source,
    required bool alreadyRegistered,
    String? registeredMobileHint,
    required bool otpAvailable,
    required String identityNote,
  }) = _RegisterInfo;

  factory RegisterInfo.fromJson(Map<String, dynamic> json) => _$RegisterInfoFromJson(json);
}

@freezed
abstract class OtpSent with _$OtpSent {
  const factory OtpSent({
    required String otpId,
    required int expiresIn,
    required String sentTo,
    required String advocateName,
    String? devOtp,
  }) = _OtpSent;

  factory OtpSent.fromJson(Map<String, dynamic> json) => _$OtpSentFromJson(json);
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String sessionId,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => _$AuthTokensFromJson(json);
}

// ------------------------------------------------------------------ advocate cause list
@freezed
abstract class AdvocateListing with _$AdvocateListing {
  const factory AdvocateListing({
    required String itemNo,
    required String courtNo,
    required String listType,
    required String rawCase,
    String? caseNumber,
    String? caseId,
    String? application,
    String? applicationDescription,
    String? petitioner,
    String? respondent,
    @Default([]) List<String> petitionerAdvocates,
    @Default([]) List<String> respondentAdvocates,
    String? district,
    String? stage,
  }) = _AdvocateListing;

  factory AdvocateListing.fromJson(Map<String, dynamic> json) => _$AdvocateListingFromJson(json);
}

@freezed
abstract class AdvocateCourtGroup with _$AdvocateCourtGroup {
  const factory AdvocateCourtGroup({required String courtNo, @Default([]) List<AdvocateListing> cases}) =
      _AdvocateCourtGroup;

  factory AdvocateCourtGroup.fromJson(Map<String, dynamic> json) => _$AdvocateCourtGroupFromJson(json);
}

@freezed
abstract class AdvocateCauseList with _$AdvocateCauseList {
  const factory AdvocateCauseList({
    required String advocateCode,
    String? advocateName,
    required String listDate,
    @Default(true) bool dateOfferedBySource,
    @Default([]) List<String> availableDates,
    required int totalCases,
    @Default([]) List<AdvocateCourtGroup> courts,
    String? fetchedAt,
    @Default(false) bool stale,
    String? source,
  }) = _AdvocateCauseList;

  factory AdvocateCauseList.fromJson(Map<String, dynamic> json) => _$AdvocateCauseListFromJson(json);
}

// ------------------------------------------------------------------ cause lists
@freezed
abstract class ListDates with _$ListDates {
  const factory ListDates({
    required String listType,
    @Default([]) List<String> dates,
    String? fetchedAt,
    @Default(false) bool stale,
  }) = _ListDates;

  factory ListDates.fromJson(Map<String, dynamic> json) => _$ListDatesFromJson(json);
}

@freezed
abstract class CourtSummary with _$CourtSummary {
  const factory CourtSummary({
    required String courtNo,
    required String courtName,
    int? caseCount,
    String? bench,
    String? syncedAt,
  }) = _CourtSummary;

  factory CourtSummary.fromJson(Map<String, dynamic> json) => _$CourtSummaryFromJson(json);
}

@freezed
abstract class CourtsResponse with _$CourtsResponse {
  const factory CourtsResponse({
    required String listType,
    required String listDate,
    @Default([]) List<CourtSummary> courts,
    String? fetchedAt,
    @Default(false) bool stale,
  }) = _CourtsResponse;

  factory CourtsResponse.fromJson(Map<String, dynamic> json) => _$CourtsResponseFromJson(json);
}

@freezed
abstract class ApplicationRef with _$ApplicationRef {
  const factory ApplicationRef({required String number, String? description}) = _ApplicationRef;

  factory ApplicationRef.fromJson(Map<String, dynamic> json) => _$ApplicationRefFromJson(json);
}

@freezed
abstract class ListingItem with _$ListingItem {
  const factory ListingItem({
    required int sequence,
    required String itemNo,
    String? caseId,
    required String caseNumber,
    @Default([]) List<ApplicationRef> applications,
    String? petitioner,
    String? respondent,
    @Default([]) List<String> petitionerAdvocates,
    @Default([]) List<String> respondentAdvocates,
    String? district,
    String? listSection,
    String? stage,
    String? remarks,
  }) = _ListingItem;

  factory ListingItem.fromJson(Map<String, dynamic> json) => _$ListingItemFromJson(json);
}

@freezed
abstract class CourtListing with _$CourtListing {
  const factory CourtListing({
    required String listType,
    required String listDate,
    required String courtNo,
    String? bench,
    @Default([]) List<String> headings,
    required String status,
    required int totalCases,
    String? fetchedAt,
    @Default(false) bool stale,
    String? source,
    @Default([]) List<ListingItem> items,
  }) = _CourtListing;

  factory CourtListing.fromJson(Map<String, dynamic> json) => _$CourtListingFromJson(json);
}

@freezed
abstract class PublicationCourt with _$PublicationCourt {
  const factory PublicationCourt({
    required String courtNo,
    String? benchCode,
    String? coram,
    required String status,
    String? uploadedAt,
    @Default(false) bool hasPdf,
  }) = _PublicationCourt;

  factory PublicationCourt.fromJson(Map<String, dynamic> json) => _$PublicationCourtFromJson(json);
}

@freezed
abstract class PublicationStatus with _$PublicationStatus {
  const factory PublicationStatus({
    required String listDate,
    String? fetchedAt,
    @Default(false) bool stale,
    @Default({}) Map<String, int> summary,
    @Default([]) List<PublicationCourt> courts,
  }) = _PublicationStatus;

  factory PublicationStatus.fromJson(Map<String, dynamic> json) => _$PublicationStatusFromJson(json);
}

// ------------------------------------------------------------------ cases
@freezed
abstract class EnrichmentJob with _$EnrichmentJob {
  const factory EnrichmentJob({
    required String id,
    required String status,
    @Default(0) int attempts,
    @Default(0) int maxAttempts,
    String? nextAttemptAt,
    String? errorCode,
  }) = _EnrichmentJob;

  factory EnrichmentJob.fromJson(Map<String, dynamic> json) => _$EnrichmentJobFromJson(json);
}

@freezed
abstract class EnrichmentStatus with _$EnrichmentStatus {
  const factory EnrichmentStatus({
    required String caseId,
    required String state, // not_requested | pending | running | completed | failed
    String? freshness, // fresh | stale
    String? fetchedAt,
    EnrichmentJob? job,
    int? pollAfterSeconds,
  }) = _EnrichmentStatus;

  factory EnrichmentStatus.fromJson(Map<String, dynamic> json) => _$EnrichmentStatusFromJson(json);
}

@freezed
abstract class CaseDetails with _$CaseDetails {
  const factory CaseDetails({
    required Map<String, dynamic> identity,
    @Default({}) Map<String, dynamic> information,
    @Default({}) Map<String, dynamic> parties,
    @Default({}) Map<String, dynamic> advocates,
    @Default({}) Map<String, dynamic> additional,
    required EnrichmentStatus enrichment,
    @Default({}) Map<String, dynamic> provenance,
    @Default([]) List<String> unavailableSections,
    String? unavailableNote,
  }) = _CaseDetails;

  factory CaseDetails.fromJson(Map<String, dynamic> json) => _$CaseDetailsFromJson(json);
}

extension CaseDetailsX on CaseDetails {
  String get caseId => identity['case_id'] as String;
  String get display => identity['display'] as String? ?? '';
  List<Map<String, dynamic>> _list(Map<String, dynamic> m, String k) =>
      ((m[k] as List?) ?? const []).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get petitioners => _list(parties, 'petitioners');
  List<Map<String, dynamic>> get respondents => _list(parties, 'respondents');
  List<Map<String, dynamic>> get vakalath => _list(advocates, 'vakalath');
  List<Map<String, dynamic>> get observedListings => _list(additional, 'observed_listings');
}

// ------------------------------------------------------------------ live board
@freezed
abstract class BoardCourt with _$BoardCourt {
  const factory BoardCourt({
    required String courtNo,
    required String state, // not_in_session | session_started | in_progress
    String? currentItem,
    String? keptBack,
    @Default([]) List<String> pendingSerials,
    String? coram,
  }) = _BoardCourt;

  factory BoardCourt.fromJson(Map<String, dynamic> json) => _$BoardCourtFromJson(json);
}

@freezed
abstract class LiveBoard with _$LiveBoard {
  const factory LiveBoard({
    required String fetchedAt,
    required int ageSeconds,
    required bool stale,
    required bool isCurrent,
    @Default(180) int staleAfterSeconds,
    String? source,
    @Default([]) List<BoardCourt> courts,
    String? note,
  }) = _LiveBoard;

  factory LiveBoard.fromJson(Map<String, dynamic> json) => _$LiveBoardFromJson(json);
}

// ------------------------------------------------------------------ favourites / notifications / search
@freezed
abstract class FavouriteAdvocate with _$FavouriteAdvocate {
  const factory FavouriteAdvocate({
    required String id,
    required String advocateCode,
    String? advocateName,
    String? label,
    required String createdAt,
  }) = _FavouriteAdvocate;

  factory FavouriteAdvocate.fromJson(Map<String, dynamic> json) => _$FavouriteAdvocateFromJson(json);
}

@freezed
abstract class FavouriteCase with _$FavouriteCase {
  const factory FavouriteCase({
    required String id,
    required String caseId,
    required String caseNumber,
    String? note,
    String? petitioner,
    String? respondent,
    required String createdAt,
  }) = _FavouriteCase;

  factory FavouriteCase.fromJson(Map<String, dynamic> json) => _$FavouriteCaseFromJson(json);
}

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String category,
    required String title,
    required String body,
    String? deepLink,
    @Default({}) Map<String, dynamic> data,
    @Default(false) bool read,
    required String createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}

@freezed
abstract class NotificationPage with _$NotificationPage {
  const factory NotificationPage({
    @Default([]) List<AppNotification> items,
    @Default(0) int unreadCount,
    @Default(0) int total,
  }) = _NotificationPage;

  factory NotificationPage.fromJson(Map<String, dynamic> json) => _$NotificationPageFromJson(json);
}

@freezed
abstract class NotificationPrefs with _$NotificationPrefs {
  const factory NotificationPrefs({
    @Default(true) bool causeListPublication,
    @Default(true) bool favouriteAdvocates,
    @Default(true) bool caseUpdates,
    @Default(true) bool courtBoard,
    @Default(true) bool enrichment,
    @Default(true) bool announcements,
  }) = _NotificationPrefs;

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) => _$NotificationPrefsFromJson(json);
}

@freezed
abstract class LastListed with _$LastListed {
  const factory LastListed({required String listDate, required String courtNo, required String itemNo}) = _LastListed;

  factory LastListed.fromJson(Map<String, dynamic> json) => _$LastListedFromJson(json);
}

@freezed
abstract class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String caseId,
    required String caseNumber,
    String? petitioner,
    String? respondent,
    String? status,
    LastListed? lastListed,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
}

@freezed
abstract class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    @Default(0) int total,
    @Default([]) List<SearchResult> results,
    String? exactCaseNumber,
    @Default(false) bool exactCaseKnown,
    String? hint,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) => _$SearchResponseFromJson(json);
}
