import 'package:advocatemate/features/court_wise_cases/court_wise_screen.dart';
import 'package:advocatemate/shared/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_backend.dart';
import '../support/pump_app.dart';

Map<String, Object?> _item(int seq, String no, String id, String caseNo, {Map<String, Object?>? check}) => {
      'sequence': seq,
      'item_no': no,
      'case_id': id,
      'case_number': caseNo,
      'petitioner': 'PETITIONER $no',
      'respondent': 'RESPONDENT $no',
      'stage': 'ADMISSION',
      'pdf_check': check,
    };

Map<String, Object?> _listing({
  required List<Map<String, Object?>> items,
  Map<String, Object?>? verification,
  String itemsSource = 'online_list',
  String? fallbackReason,
}) =>
    {
      'list_type': 'D',
      'list_date': '2026-11-18',
      'court_no': '3',
      'bench': 'THE HONOURABLE SMT JUSTICE SAMPLE JUDGE',
      'headings': ['(DAILY LIST)'],
      'status': 'synced',
      'total_cases': items.length,
      'fetched_at': '2026-11-18T08:00:00Z',
      'stale': false,
      'items': items,
      'items_source': itemsSource,
      'fallback_reason': fallbackReason,
      'pdf_verification': verification,
    };

const _match = {'status': 'match', 'fields': <String>[]};

void main() {
  test('filterListing can show only items that do not match the PDF', () {
    const items = [
      ListingItem(sequence: 1, itemNo: '1', caseNumber: 'WP/1/2026', pdfCheck: PdfCheck(status: 'match')),
      ListingItem(sequence: 2, itemNo: '2', caseNumber: 'WP/2/2026', pdfCheck: PdfCheck(status: 'differs')),
      ListingItem(sequence: 3, itemNo: '3', caseNumber: 'WP/3/2026', pdfCheck: PdfCheck(status: 'not_in_pdf')),
      ListingItem(sequence: 4, itemNo: '4', caseNumber: 'WP/4/2026'),
    ];
    expect(filterListing(items, onlyPdfDifferences: true).map((i) => i.itemNo), ['2', '3']);
    expect(filterListing(items).length, 4);
  });

  testWidgets('court list verified against the official PDF', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/court/3', (_) => _listing(
          items: [_item(1, '1', 'c1', 'WP/11111/2026', check: _match), _item(2, '59', 'c4', 'WP/333/2017', check: _match)],
          verification: {'status': 'verified', 'matched': 2, 'differs': 0, 'not_in_pdf': 0, 'pdf_only': 0},
        ));
    await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    expect(find.byKey(const Key('pdfVerifiedBanner')), findsOneWidget);
    expect(find.text('Matches the official PDF (2 items checked)'), findsOneWidget);
    expect(find.text('Differs from PDF'), findsNothing);
  });

  testWidgets('differences are flagged, filterable, and PDF-only items listed', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/court/3', (_) => _listing(
          items: [
            _item(1, '1', 'c1', 'WP/11111/2026', check: _match),
            _item(2, '59', 'c4', 'WP/333/2017', check: {'status': 'differs', 'fields': ['petitioner_advocates']}),
            _item(3, '59.1', 'c5', 'WP/444/2018', check: {'status': 'not_in_pdf', 'fields': <String>[]}),
          ],
          verification: {
            'status': 'differences', 'matched': 1, 'differs': 1, 'not_in_pdf': 1, 'pdf_only': 1,
            'pdf_only_items': [
              {'sequence': 4, 'item_no': '60', 'case_number': 'WP/555/2019', 'petitioner': 'PETITIONER EPSILON',
                'respondent': 'RESPONDENT EPSILON', 'pdf_pages': [2, 2]},
            ],
          },
        ));
    await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    expect(find.text('Checked against the official PDF: 1 differ, 1 not in the PDF, 1 only in the PDF'), findsOneWidget);
    expect(find.text('Differs from PDF'), findsOneWidget);
    expect(find.text('Not in PDF'), findsOneWidget);
    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('WP/555/2019'), findsOneWidget);
    expect(find.byKey(const Key('pdfOnlySection')), findsOneWidget);

    await tester.drag(list, const Offset(0, 1600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pdfToggleDifferences')));
    await tester.pumpAndSettle();
    expect(find.text('WP/11111/2026'), findsNothing);
    expect(find.text('WP/333/2017'), findsOneWidget);
    expect(find.text('Show all'), findsOneWidget);
  });

  testWidgets('items read from the PDF when the online list is unavailable are labelled', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/court/3', (_) => _listing(
          items: [_item(1, '1', 'c1', 'WP/11111/2026')],
          itemsSource: 'official_pdf',
          fallbackReason: 'online_list_unavailable',
        ));
    await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    expect(find.byKey(const Key('pdfFallbackBanner')), findsOneWidget);
    expect(find.text('The online list could not be loaded. These items were read from the official PDF.'), findsOneWidget);
    expect(find.text('WP/11111/2026'), findsOneWidget);
  });

  testWidgets('unreadable PDF is a quiet note, not an error', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/court/3', (_) => _listing(
          items: [_item(1, '1', 'c1', 'WP/11111/2026')],
          verification: {'status': 'failed', 'error_code': 'parser_failure'},
        ));
    await pumpApp(tester, deps, goTo: '/court/D/3?date=2026-11-18');
    expect(find.byKey(const Key('pdfUnreadableNote')), findsOneWidget);
    expect(find.text('WP/11111/2026'), findsOneWidget);
  });

  testWidgets('passed-over list shows kept-back items with their cases and status', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/passed-over', (_) => {
          'list_date': '2026-11-18',
          'is_today': true,
          'source': 'aphc.gov.in display board (Kept Back Cases)',
          'observed_from': '2026-11-18T05:00:00Z',
          'board_stale': false,
          'available_dates': ['2026-11-18', '2026-11-17'],
          'total': 3,
          'pending': 1,
          'courts': [
            {
              'court_no': '3', 'coram': 'SJ', 'current_item': 'D-73', 'pending': 1,
              'items': [
                {'item_no': '1', 'list_prefix': 'D', 'list_type': 'D', 'status': 'pending',
                  'first_seen_at': '2026-11-18T05:35:00Z', 'last_seen_at': '2026-11-18T06:00:00Z',
                  'case': {'sequence': 1, 'item_no': '1', 'case_id': 'c1', 'case_number': 'WP/11111/2026',
                    'petitioner': 'PETITIONER ALPHA', 'respondent': 'THE STATE OF ANDHRA PRADESH'}},
                {'item_no': '15', 'list_prefix': 'D', 'list_type': 'D', 'status': 'no_longer_pending',
                  'first_seen_at': '2026-11-18T05:40:00Z', 'last_seen_at': '2026-11-18T06:00:00Z',
                  'case': {'sequence': 2, 'item_no': '15', 'case_number': 'WP/333/2017'}},
                {'item_no': '37', 'list_prefix': 'D', 'list_type': 'D', 'status': 'off_board',
                  'first_seen_at': '2026-11-18T05:45:00Z', 'last_seen_at': '2026-11-18T05:50:00Z', 'case': null},
              ],
            },
          ],
          'note': 'Always confirm with the court.',
        });
    final c = await pumpApp(tester, deps, goTo: '/cause-list/passed-over');
    expect(find.text('Passed-over list'), findsOneWidget);
    expect(find.text('3 items · 1 pending'), findsOneWidget);
    expect(find.text('Court 3 · SJ · Now at D-73'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('No longer pending'), findsOneWidget);
    expect(find.text('Off the board'), findsOneWidget);
    expect(find.text("Item 37 (not found in the court's list)"), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(2)); // dates with records
    await tester.tap(find.text('WP/11111/2026'));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/cases/c1');
  });

  testWidgets('empty passed-over list and stale board warning', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/passed-over', (_) => {
          'list_date': '2026-11-18', 'is_today': true, 'board_stale': true, 'available_dates': <String>[],
          'total': 0, 'pending': 0, 'courts': <Object>[],
        });
    await pumpApp(tester, deps, goTo: '/cause-list/passed-over');
    expect(find.text('No passed-over items were recorded for this date.'), findsOneWidget);
    expect(find.byKey(const Key('passedOverBoardStale')), findsOneWidget);
  });

  testWidgets('daily cause list opens the passed-over list', (tester) async {
    final deps = await makeDeps(signedIn: true);
    deps.backend.on('GET', '/cause-list/passed-over', (_) => {
          'list_date': '2026-11-18', 'is_today': true, 'total': 0, 'pending': 0, 'courts': <Object>[],
        });
    final c = await pumpApp(tester, deps, goTo: '/cause-list/daily');
    await tester.tap(find.byKey(const Key('openPassedOver')));
    await tester.pumpAndSettle();
    expect(routerOf(c).state.uri.path, '/cause-list/passed-over');
  });
}
