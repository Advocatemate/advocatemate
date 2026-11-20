// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Me _$MeFromJson(Map<String, dynamic> json) => _Me(
  userId: json['user_id'] as String,
  role: json['role'] as String,
  preferredLanguage: json['preferred_language'] as String? ?? 'en',
  advocateCode: json['advocate_code'] as String?,
  advocateName: json['advocate_name'] as String?,
  displayName: json['display_name'] as String?,
  email: json['email'] as String?,
  googleEmail: json['google_email'] as String?,
  identityVerification: json['identity_verification'] as String?,
  verificationMethod: json['verification_method'] as String?,
  linkedAt: json['linked_at'] as String?,
  mobile: json['mobile'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$MeToJson(_Me instance) => <String, dynamic>{
  'user_id': instance.userId,
  'role': instance.role,
  'preferred_language': instance.preferredLanguage,
  'advocate_code': ?instance.advocateCode,
  'advocate_name': ?instance.advocateName,
  'display_name': ?instance.displayName,
  'email': ?instance.email,
  'google_email': ?instance.googleEmail,
  'identity_verification': ?instance.identityVerification,
  'verification_method': ?instance.verificationMethod,
  'linked_at': ?instance.linkedAt,
  'mobile': ?instance.mobile,
  'created_at': ?instance.createdAt,
};

_GoogleSignInResult _$GoogleSignInResultFromJson(Map<String, dynamic> json) =>
    _GoogleSignInResult(
      status: json['status'] as String,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      sessionId: json['session_id'] as String?,
      linkToken: json['link_token'] as String?,
      linkExpiresIn: (json['link_expires_in'] as num?)?.toInt(),
      googleEmail: json['google_email'] as String?,
    );

Map<String, dynamic> _$GoogleSignInResultToJson(_GoogleSignInResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'access_token': ?instance.accessToken,
      'refresh_token': ?instance.refreshToken,
      'expires_in': ?instance.expiresIn,
      'session_id': ?instance.sessionId,
      'link_token': ?instance.linkToken,
      'link_expires_in': ?instance.linkExpiresIn,
      'google_email': ?instance.googleEmail,
    };

_AdvocateListing _$AdvocateListingFromJson(Map<String, dynamic> json) =>
    _AdvocateListing(
      itemNo: json['item_no'] as String,
      courtNo: json['court_no'] as String,
      listType: json['list_type'] as String,
      rawCase: json['raw_case'] as String,
      caseNumber: json['case_number'] as String?,
      caseId: json['case_id'] as String?,
      application: json['application'] as String?,
      applicationDescription: json['application_description'] as String?,
      petitioner: json['petitioner'] as String?,
      respondent: json['respondent'] as String?,
      petitionerAdvocates:
          (json['petitioner_advocates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      respondentAdvocates:
          (json['respondent_advocates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      district: json['district'] as String?,
      stage: json['stage'] as String?,
    );

Map<String, dynamic> _$AdvocateListingToJson(_AdvocateListing instance) =>
    <String, dynamic>{
      'item_no': instance.itemNo,
      'court_no': instance.courtNo,
      'list_type': instance.listType,
      'raw_case': instance.rawCase,
      'case_number': ?instance.caseNumber,
      'case_id': ?instance.caseId,
      'application': ?instance.application,
      'application_description': ?instance.applicationDescription,
      'petitioner': ?instance.petitioner,
      'respondent': ?instance.respondent,
      'petitioner_advocates': instance.petitionerAdvocates,
      'respondent_advocates': instance.respondentAdvocates,
      'district': ?instance.district,
      'stage': ?instance.stage,
    };

_AdvocateCourtGroup _$AdvocateCourtGroupFromJson(Map<String, dynamic> json) =>
    _AdvocateCourtGroup(
      courtNo: json['court_no'] as String,
      cases:
          (json['cases'] as List<dynamic>?)
              ?.map((e) => AdvocateListing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AdvocateCourtGroupToJson(_AdvocateCourtGroup instance) =>
    <String, dynamic>{
      'court_no': instance.courtNo,
      'cases': instance.cases.map((e) => e.toJson()).toList(),
    };

_AdvocateCauseList _$AdvocateCauseListFromJson(Map<String, dynamic> json) =>
    _AdvocateCauseList(
      advocateCode: json['advocate_code'] as String,
      advocateName: json['advocate_name'] as String?,
      listDate: json['list_date'] as String,
      dateOfferedBySource: json['date_offered_by_source'] as bool? ?? true,
      availableDates:
          (json['available_dates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalCases: (json['total_cases'] as num).toInt(),
      courts:
          (json['courts'] as List<dynamic>?)
              ?.map(
                (e) => AdvocateCourtGroup.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      fetchedAt: json['fetched_at'] as String?,
      stale: json['stale'] as bool? ?? false,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$AdvocateCauseListToJson(_AdvocateCauseList instance) =>
    <String, dynamic>{
      'advocate_code': instance.advocateCode,
      'advocate_name': ?instance.advocateName,
      'list_date': instance.listDate,
      'date_offered_by_source': instance.dateOfferedBySource,
      'available_dates': instance.availableDates,
      'total_cases': instance.totalCases,
      'courts': instance.courts.map((e) => e.toJson()).toList(),
      'fetched_at': ?instance.fetchedAt,
      'stale': instance.stale,
      'source': ?instance.source,
    };

_ListDates _$ListDatesFromJson(Map<String, dynamic> json) => _ListDates(
  listType: json['list_type'] as String,
  dates:
      (json['dates'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  fetchedAt: json['fetched_at'] as String?,
  stale: json['stale'] as bool? ?? false,
);

Map<String, dynamic> _$ListDatesToJson(_ListDates instance) =>
    <String, dynamic>{
      'list_type': instance.listType,
      'dates': instance.dates,
      'fetched_at': ?instance.fetchedAt,
      'stale': instance.stale,
    };

_CourtSummary _$CourtSummaryFromJson(Map<String, dynamic> json) =>
    _CourtSummary(
      courtNo: json['court_no'] as String,
      courtName: json['court_name'] as String,
      caseCount: (json['case_count'] as num?)?.toInt(),
      bench: json['bench'] as String?,
      syncedAt: json['synced_at'] as String?,
    );

Map<String, dynamic> _$CourtSummaryToJson(_CourtSummary instance) =>
    <String, dynamic>{
      'court_no': instance.courtNo,
      'court_name': instance.courtName,
      'case_count': ?instance.caseCount,
      'bench': ?instance.bench,
      'synced_at': ?instance.syncedAt,
    };

_CourtsResponse _$CourtsResponseFromJson(Map<String, dynamic> json) =>
    _CourtsResponse(
      listType: json['list_type'] as String,
      listDate: json['list_date'] as String,
      courts:
          (json['courts'] as List<dynamic>?)
              ?.map((e) => CourtSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fetchedAt: json['fetched_at'] as String?,
      stale: json['stale'] as bool? ?? false,
    );

Map<String, dynamic> _$CourtsResponseToJson(_CourtsResponse instance) =>
    <String, dynamic>{
      'list_type': instance.listType,
      'list_date': instance.listDate,
      'courts': instance.courts.map((e) => e.toJson()).toList(),
      'fetched_at': ?instance.fetchedAt,
      'stale': instance.stale,
    };

_ApplicationRef _$ApplicationRefFromJson(Map<String, dynamic> json) =>
    _ApplicationRef(
      number: json['number'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ApplicationRefToJson(_ApplicationRef instance) =>
    <String, dynamic>{
      'number': instance.number,
      'description': ?instance.description,
    };

_ListingItem _$ListingItemFromJson(Map<String, dynamic> json) => _ListingItem(
  sequence: (json['sequence'] as num).toInt(),
  itemNo: json['item_no'] as String,
  caseId: json['case_id'] as String?,
  caseNumber: json['case_number'] as String,
  applications:
      (json['applications'] as List<dynamic>?)
          ?.map((e) => ApplicationRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  petitioner: json['petitioner'] as String?,
  respondent: json['respondent'] as String?,
  petitionerAdvocates:
      (json['petitioner_advocates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  respondentAdvocates:
      (json['respondent_advocates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  district: json['district'] as String?,
  listSection: json['list_section'] as String?,
  stage: json['stage'] as String?,
  remarks: json['remarks'] as String?,
  pdfCheck: json['pdf_check'] == null
      ? null
      : PdfCheck.fromJson(json['pdf_check'] as Map<String, dynamic>),
  pdfPages: (json['pdf_pages'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$ListingItemToJson(_ListingItem instance) =>
    <String, dynamic>{
      'sequence': instance.sequence,
      'item_no': instance.itemNo,
      'case_id': ?instance.caseId,
      'case_number': instance.caseNumber,
      'applications': instance.applications.map((e) => e.toJson()).toList(),
      'petitioner': ?instance.petitioner,
      'respondent': ?instance.respondent,
      'petitioner_advocates': instance.petitionerAdvocates,
      'respondent_advocates': instance.respondentAdvocates,
      'district': ?instance.district,
      'list_section': ?instance.listSection,
      'stage': ?instance.stage,
      'remarks': ?instance.remarks,
      'pdf_check': ?instance.pdfCheck?.toJson(),
      'pdf_pages': ?instance.pdfPages,
    };

_CourtListing _$CourtListingFromJson(Map<String, dynamic> json) =>
    _CourtListing(
      listType: json['list_type'] as String,
      listDate: json['list_date'] as String,
      courtNo: json['court_no'] as String,
      bench: json['bench'] as String?,
      headings:
          (json['headings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String,
      totalCases: (json['total_cases'] as num).toInt(),
      fetchedAt: json['fetched_at'] as String?,
      stale: json['stale'] as bool? ?? false,
      source: json['source'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ListingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      itemsSource: json['items_source'] as String? ?? 'online_list',
      fallbackReason: json['fallback_reason'] as String?,
      pdfVerification: json['pdf_verification'] == null
          ? null
          : PdfVerification.fromJson(
              json['pdf_verification'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CourtListingToJson(_CourtListing instance) =>
    <String, dynamic>{
      'list_type': instance.listType,
      'list_date': instance.listDate,
      'court_no': instance.courtNo,
      'bench': ?instance.bench,
      'headings': instance.headings,
      'status': instance.status,
      'total_cases': instance.totalCases,
      'fetched_at': ?instance.fetchedAt,
      'stale': instance.stale,
      'source': ?instance.source,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'items_source': instance.itemsSource,
      'fallback_reason': ?instance.fallbackReason,
      'pdf_verification': ?instance.pdfVerification?.toJson(),
    };

_PdfCheck _$PdfCheckFromJson(Map<String, dynamic> json) => _PdfCheck(
  status: json['status'] as String,
  fields:
      (json['fields'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PdfCheckToJson(_PdfCheck instance) => <String, dynamic>{
  'status': instance.status,
  'fields': instance.fields,
};

_PdfVerification _$PdfVerificationFromJson(Map<String, dynamic> json) =>
    _PdfVerification(
      status: json['status'] as String,
      source: json['source'] as String?,
      sourceUrl: json['source_url'] as String?,
      checkedAt: json['checked_at'] as String?,
      matched: (json['matched'] as num?)?.toInt() ?? 0,
      differs: (json['differs'] as num?)?.toInt() ?? 0,
      notInPdf: (json['not_in_pdf'] as num?)?.toInt() ?? 0,
      pdfOnly: (json['pdf_only'] as num?)?.toInt() ?? 0,
      pdfOnlyItems:
          (json['pdf_only_items'] as List<dynamic>?)
              ?.map((e) => ListingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      errorCode: json['error_code'] as String?,
    );

Map<String, dynamic> _$PdfVerificationToJson(_PdfVerification instance) =>
    <String, dynamic>{
      'status': instance.status,
      'source': ?instance.source,
      'source_url': ?instance.sourceUrl,
      'checked_at': ?instance.checkedAt,
      'matched': instance.matched,
      'differs': instance.differs,
      'not_in_pdf': instance.notInPdf,
      'pdf_only': instance.pdfOnly,
      'pdf_only_items': instance.pdfOnlyItems.map((e) => e.toJson()).toList(),
      'error_code': ?instance.errorCode,
    };

_PassedOverEntry _$PassedOverEntryFromJson(Map<String, dynamic> json) =>
    _PassedOverEntry(
      itemNo: json['item_no'] as String,
      listPrefix: json['list_prefix'] as String,
      listType: json['list_type'] as String?,
      status: json['status'] as String,
      firstSeenAt: json['first_seen_at'] as String,
      lastSeenAt: json['last_seen_at'] as String,
      removedAt: json['removed_at'] as String?,
      listing: json['case'] == null
          ? null
          : ListingItem.fromJson(json['case'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PassedOverEntryToJson(_PassedOverEntry instance) =>
    <String, dynamic>{
      'item_no': instance.itemNo,
      'list_prefix': instance.listPrefix,
      'list_type': ?instance.listType,
      'status': instance.status,
      'first_seen_at': instance.firstSeenAt,
      'last_seen_at': instance.lastSeenAt,
      'removed_at': ?instance.removedAt,
      'case': ?instance.listing?.toJson(),
    };

_PassedOverCourt _$PassedOverCourtFromJson(Map<String, dynamic> json) =>
    _PassedOverCourt(
      courtNo: json['court_no'] as String,
      coram: json['coram'] as String?,
      currentItem: json['current_item'] as String?,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => PassedOverEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PassedOverCourtToJson(_PassedOverCourt instance) =>
    <String, dynamic>{
      'court_no': instance.courtNo,
      'coram': ?instance.coram,
      'current_item': ?instance.currentItem,
      'pending': instance.pending,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_PassedOverList _$PassedOverListFromJson(Map<String, dynamic> json) =>
    _PassedOverList(
      listDate: json['list_date'] as String,
      isToday: json['is_today'] as bool? ?? false,
      source: json['source'] as String?,
      observedFrom: json['observed_from'] as String?,
      boardFetchedAt: json['board_fetched_at'] as String?,
      boardStale: json['board_stale'] as bool?,
      availableDates:
          (json['available_dates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      courts:
          (json['courts'] as List<dynamic>?)
              ?.map((e) => PassedOverCourt.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PassedOverListToJson(_PassedOverList instance) =>
    <String, dynamic>{
      'list_date': instance.listDate,
      'is_today': instance.isToday,
      'source': ?instance.source,
      'observed_from': ?instance.observedFrom,
      'board_fetched_at': ?instance.boardFetchedAt,
      'board_stale': ?instance.boardStale,
      'available_dates': instance.availableDates,
      'total': instance.total,
      'pending': instance.pending,
      'courts': instance.courts.map((e) => e.toJson()).toList(),
      'note': ?instance.note,
    };

_PublicationCourt _$PublicationCourtFromJson(Map<String, dynamic> json) =>
    _PublicationCourt(
      courtNo: json['court_no'] as String,
      benchCode: json['bench_code'] as String?,
      coram: json['coram'] as String?,
      status: json['status'] as String,
      uploadedAt: json['uploaded_at'] as String?,
      hasPdf: json['has_pdf'] as bool? ?? false,
    );

Map<String, dynamic> _$PublicationCourtToJson(_PublicationCourt instance) =>
    <String, dynamic>{
      'court_no': instance.courtNo,
      'bench_code': ?instance.benchCode,
      'coram': ?instance.coram,
      'status': instance.status,
      'uploaded_at': ?instance.uploadedAt,
      'has_pdf': instance.hasPdf,
    };

_PublicationStatus _$PublicationStatusFromJson(Map<String, dynamic> json) =>
    _PublicationStatus(
      listDate: json['list_date'] as String,
      fetchedAt: json['fetched_at'] as String?,
      stale: json['stale'] as bool? ?? false,
      summary:
          (json['summary'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      courts:
          (json['courts'] as List<dynamic>?)
              ?.map((e) => PublicationCourt.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PublicationStatusToJson(_PublicationStatus instance) =>
    <String, dynamic>{
      'list_date': instance.listDate,
      'fetched_at': ?instance.fetchedAt,
      'stale': instance.stale,
      'summary': instance.summary,
      'courts': instance.courts.map((e) => e.toJson()).toList(),
    };

_EnrichmentJob _$EnrichmentJobFromJson(Map<String, dynamic> json) =>
    _EnrichmentJob(
      id: json['id'] as String,
      status: json['status'] as String,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      maxAttempts: (json['max_attempts'] as num?)?.toInt() ?? 0,
      nextAttemptAt: json['next_attempt_at'] as String?,
      errorCode: json['error_code'] as String?,
    );

Map<String, dynamic> _$EnrichmentJobToJson(_EnrichmentJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'attempts': instance.attempts,
      'max_attempts': instance.maxAttempts,
      'next_attempt_at': ?instance.nextAttemptAt,
      'error_code': ?instance.errorCode,
    };

_EnrichmentStatus _$EnrichmentStatusFromJson(Map<String, dynamic> json) =>
    _EnrichmentStatus(
      caseId: json['case_id'] as String,
      state: json['state'] as String,
      freshness: json['freshness'] as String?,
      fetchedAt: json['fetched_at'] as String?,
      job: json['job'] == null
          ? null
          : EnrichmentJob.fromJson(json['job'] as Map<String, dynamic>),
      pollAfterSeconds: (json['poll_after_seconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EnrichmentStatusToJson(_EnrichmentStatus instance) =>
    <String, dynamic>{
      'case_id': instance.caseId,
      'state': instance.state,
      'freshness': ?instance.freshness,
      'fetched_at': ?instance.fetchedAt,
      'job': ?instance.job?.toJson(),
      'poll_after_seconds': ?instance.pollAfterSeconds,
    };

_CaseDetails _$CaseDetailsFromJson(Map<String, dynamic> json) => _CaseDetails(
  identity: json['identity'] as Map<String, dynamic>,
  information: json['information'] as Map<String, dynamic>? ?? const {},
  parties: json['parties'] as Map<String, dynamic>? ?? const {},
  advocates: json['advocates'] as Map<String, dynamic>? ?? const {},
  additional: json['additional'] as Map<String, dynamic>? ?? const {},
  enrichment: EnrichmentStatus.fromJson(
    json['enrichment'] as Map<String, dynamic>,
  ),
  provenance: json['provenance'] as Map<String, dynamic>? ?? const {},
  unavailableSections:
      (json['unavailable_sections'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  unavailableNote: json['unavailable_note'] as String?,
);

Map<String, dynamic> _$CaseDetailsToJson(_CaseDetails instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'information': instance.information,
      'parties': instance.parties,
      'advocates': instance.advocates,
      'additional': instance.additional,
      'enrichment': instance.enrichment.toJson(),
      'provenance': instance.provenance,
      'unavailable_sections': instance.unavailableSections,
      'unavailable_note': ?instance.unavailableNote,
    };

_BoardCourt _$BoardCourtFromJson(Map<String, dynamic> json) => _BoardCourt(
  courtNo: json['court_no'] as String,
  state: json['state'] as String,
  currentItem: json['current_item'] as String?,
  keptBack: json['kept_back'] as String?,
  pendingSerials:
      (json['pending_serials'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  coram: json['coram'] as String?,
);

Map<String, dynamic> _$BoardCourtToJson(_BoardCourt instance) =>
    <String, dynamic>{
      'court_no': instance.courtNo,
      'state': instance.state,
      'current_item': ?instance.currentItem,
      'kept_back': ?instance.keptBack,
      'pending_serials': instance.pendingSerials,
      'coram': ?instance.coram,
    };

_LiveBoard _$LiveBoardFromJson(Map<String, dynamic> json) => _LiveBoard(
  fetchedAt: json['fetched_at'] as String,
  ageSeconds: (json['age_seconds'] as num).toInt(),
  stale: json['stale'] as bool,
  isCurrent: json['is_current'] as bool,
  staleAfterSeconds: (json['stale_after_seconds'] as num?)?.toInt() ?? 180,
  source: json['source'] as String?,
  courts:
      (json['courts'] as List<dynamic>?)
          ?.map((e) => BoardCourt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  note: json['note'] as String?,
);

Map<String, dynamic> _$LiveBoardToJson(_LiveBoard instance) =>
    <String, dynamic>{
      'fetched_at': instance.fetchedAt,
      'age_seconds': instance.ageSeconds,
      'stale': instance.stale,
      'is_current': instance.isCurrent,
      'stale_after_seconds': instance.staleAfterSeconds,
      'source': ?instance.source,
      'courts': instance.courts.map((e) => e.toJson()).toList(),
      'note': ?instance.note,
    };

_FavouriteAdvocate _$FavouriteAdvocateFromJson(Map<String, dynamic> json) =>
    _FavouriteAdvocate(
      id: json['id'] as String,
      advocateCode: json['advocate_code'] as String,
      advocateName: json['advocate_name'] as String?,
      label: json['label'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$FavouriteAdvocateToJson(_FavouriteAdvocate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'advocate_code': instance.advocateCode,
      'advocate_name': ?instance.advocateName,
      'label': ?instance.label,
      'created_at': instance.createdAt,
    };

_FavouriteCase _$FavouriteCaseFromJson(Map<String, dynamic> json) =>
    _FavouriteCase(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      caseNumber: json['case_number'] as String,
      note: json['note'] as String?,
      petitioner: json['petitioner'] as String?,
      respondent: json['respondent'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$FavouriteCaseToJson(_FavouriteCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'case_id': instance.caseId,
      'case_number': instance.caseNumber,
      'note': ?instance.note,
      'petitioner': ?instance.petitioner,
      'respondent': ?instance.respondent,
      'created_at': instance.createdAt,
    };

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      deepLink: json['deep_link'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? const {},
      read: json['read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'title': instance.title,
      'body': instance.body,
      'deep_link': ?instance.deepLink,
      'data': instance.data,
      'read': instance.read,
      'created_at': instance.createdAt,
    };

_NotificationPage _$NotificationPageFromJson(Map<String, dynamic> json) =>
    _NotificationPage(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NotificationPageToJson(_NotificationPage instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'unread_count': instance.unreadCount,
      'total': instance.total,
    };

_NotificationPrefs _$NotificationPrefsFromJson(Map<String, dynamic> json) =>
    _NotificationPrefs(
      causeListPublication: json['cause_list_publication'] as bool? ?? true,
      favouriteAdvocates: json['favourite_advocates'] as bool? ?? true,
      caseUpdates: json['case_updates'] as bool? ?? true,
      courtBoard: json['court_board'] as bool? ?? true,
      enrichment: json['enrichment'] as bool? ?? true,
      announcements: json['announcements'] as bool? ?? true,
    );

Map<String, dynamic> _$NotificationPrefsToJson(_NotificationPrefs instance) =>
    <String, dynamic>{
      'cause_list_publication': instance.causeListPublication,
      'favourite_advocates': instance.favouriteAdvocates,
      'case_updates': instance.caseUpdates,
      'court_board': instance.courtBoard,
      'enrichment': instance.enrichment,
      'announcements': instance.announcements,
    };

_LastListed _$LastListedFromJson(Map<String, dynamic> json) => _LastListed(
  listDate: json['list_date'] as String,
  courtNo: json['court_no'] as String,
  itemNo: json['item_no'] as String,
);

Map<String, dynamic> _$LastListedToJson(_LastListed instance) =>
    <String, dynamic>{
      'list_date': instance.listDate,
      'court_no': instance.courtNo,
      'item_no': instance.itemNo,
    };

_SearchResult _$SearchResultFromJson(Map<String, dynamic> json) =>
    _SearchResult(
      caseId: json['case_id'] as String,
      caseNumber: json['case_number'] as String,
      petitioner: json['petitioner'] as String?,
      respondent: json['respondent'] as String?,
      status: json['status'] as String?,
      lastListed: json['last_listed'] == null
          ? null
          : LastListed.fromJson(json['last_listed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResultToJson(_SearchResult instance) =>
    <String, dynamic>{
      'case_id': instance.caseId,
      'case_number': instance.caseNumber,
      'petitioner': ?instance.petitioner,
      'respondent': ?instance.respondent,
      'status': ?instance.status,
      'last_listed': ?instance.lastListed?.toJson(),
    };

_SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    _SearchResponse(
      total: (json['total'] as num?)?.toInt() ?? 0,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      exactCaseNumber: json['exact_case_number'] as String?,
      exactCaseKnown: json['exact_case_known'] as bool? ?? false,
      hint: json['hint'] as String?,
    );

Map<String, dynamic> _$SearchResponseToJson(_SearchResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'results': instance.results.map((e) => e.toJson()).toList(),
      'exact_case_number': ?instance.exactCaseNumber,
      'exact_case_known': instance.exactCaseKnown,
      'hint': ?instance.hint,
    };
