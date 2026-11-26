import 'dart:async';
import 'dart:io';

import 'package:advocatemate/features/pdf_viewer/pdf_saver.dart';
import 'package:advocatemate/features/pdf_viewer/pdf_viewer_screen.dart';
import 'package:advocatemate/l10n/gen/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeSaver implements PdfSaver {
  _FakeSaver(this.respond);
  final Future<SavedPdf> Function() respond;
  final calls = <(String, String)>[];

  @override
  Future<SavedPdf> save({required String sourcePath, required String fileName}) {
    calls.add((sourcePath, fileName));
    return respond();
  }
}

Future<void> _pumpButton(WidgetTester tester, PdfSaver saver) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [pdfSaverProvider.overrideWithValue(saver)],
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            actions: const [
              PdfDownloadButton(filePath: '/tmp/preview.pdf', fileName: 'AdvocateMate-Case-Summary-WP-1-2026.pdf'),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('download file names', () {
    final today = DateTime(2026, 11, 26);

    test('case summary uses the case number, made file-system safe', () {
      expect(
        pdfDownloadName(kind: 'summary', label: 'WP/11111/2026', caseId: 'c1'),
        'AdvocateMate-Case-Summary-WP-11111-2026.pdf',
      );
      expect(
        pdfDownloadName(kind: 'summary', label: ' CRL.P / 12 : 2025 ', caseId: 'c1'),
        'AdvocateMate-Case-Summary-CRL.P-12-2025.pdf',
      );
    });

    test('case summary falls back to the case id when no number is known', () {
      expect(pdfDownloadName(kind: 'summary', label: '', caseId: 'c1'), 'AdvocateMate-Case-Summary-c1.pdf');
    });

    test('official court and weekly lists are named by court and date', () {
      expect(
        pdfDownloadName(kind: 'court', courtNo: '3', isoDate: '2026-11-18'),
        'APHC-Court-3-Cause-List-2026-11-18.pdf',
      );
      expect(pdfDownloadName(kind: 'weekly', today: today), 'APHC-Weekly-Cause-List-2026-11-26.pdf');
    });

    test('the route label reaches the download name', () {
      final r = PdfRequest.fromQuery({'kind': 'summary', 'case': 'c1', 'label': 'WP/11111/2026'});
      expect(r.downloadName, 'AdvocateMate-Case-Summary-WP-11111-2026.pdf');
      expect(r.fileName, 'case-summary-advocatemate-generated.pdf'); // preview copy unchanged
    });
  });

  group('DocumentsPdfSaver (iOS)', () {
    late Directory tmp;
    late File source;
    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('am_pdf_test');
      source = File('${tmp.path}${Platform.pathSeparator}preview.pdf')..writeAsBytesSync('%PDF-1.7 one'.codeUnits);
    });
    tearDown(() => tmp.delete(recursive: true));

    test('saves the exact bytes, skips an identical copy, numbers a different file', () async {
      final docs = await Directory('${tmp.path}${Platform.pathSeparator}docs').create();
      final saver = DocumentsPdfSaver(directory: () async => docs);

      final first = await saver.save(sourcePath: source.path, fileName: 'Case.pdf');
      expect(first.status, PdfSaveStatus.saved);
      expect(File('${docs.path}${Platform.pathSeparator}Case.pdf').readAsBytesSync(), source.readAsBytesSync());

      final again = await saver.save(sourcePath: source.path, fileName: 'Case.pdf');
      expect(again.status, PdfSaveStatus.alreadySaved);
      expect(docs.listSync(), hasLength(1));

      source.writeAsBytesSync('%PDF-1.7 two'.codeUnits);
      final other = await saver.save(sourcePath: source.path, fileName: 'Case.pdf');
      expect(other.status, PdfSaveStatus.saved);
      expect(File('${docs.path}${Platform.pathSeparator}Case (2).pdf').existsSync(), isTrue);
    });

    test('a missing source file is reported as a failure', () async {
      final saver = DocumentsPdfSaver(directory: () async => tmp);
      expect(
        saver.save(sourcePath: '${tmp.path}/missing.pdf', fileName: 'x.pdf'),
        throwsA(isA<PdfSaveException>().having((e) => e.code, 'code', 'failed')),
      );
    });
  });

  group('AndroidPdfSaver', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(AndroidPdfSaver.channel, null));

    test('passes path and name to the platform and maps the result', () async {
      MethodCall? seen;
      messenger.setMockMethodCallHandler(AndroidPdfSaver.channel, (call) async {
        seen = call;
        return {'status': 'exists', 'location': 'Downloads › AdvocateMate'};
      });
      final r = await AndroidPdfSaver().save(sourcePath: '/a.pdf', fileName: 'b.pdf');
      expect(seen?.method, 'savePdf');
      expect(seen?.arguments, {'path': '/a.pdf', 'name': 'b.pdf'});
      expect(r.status, PdfSaveStatus.alreadySaved);
      expect(r.location, 'Downloads › AdvocateMate');
    });

    test('a refused storage permission is reported as such', () async {
      messenger.setMockMethodCallHandler(
        AndroidPdfSaver.channel,
        (call) async => throw PlatformException(code: 'permission_denied'),
      );
      expect(
        AndroidPdfSaver().save(sourcePath: '/a.pdf', fileName: 'b.pdf'),
        throwsA(isA<PdfSaveException>().having((e) => e.code, 'code', 'permission_denied')),
      );
    });
  });

  group('Download button', () {
    testWidgets('saves the open file under its download name and confirms', (tester) async {
      final done = Completer<SavedPdf>();
      final saver = _FakeSaver(() => done.future);
      await _pumpButton(tester, saver);

      await tester.tap(find.byKey(const Key('pdfDownloadButton')));
      await tester.pump();
      expect(saver.calls, [('/tmp/preview.pdf', 'AdvocateMate-Case-Summary-WP-1-2026.pdf')]);
      expect(find.byType(CircularProgressIndicator), findsOneWidget); // saving indicator
      expect(find.byTooltip('Saving PDF…'), findsOneWidget);

      done.complete(const SavedPdf(PdfSaveStatus.saved, 'Downloads › AdvocateMate'));
      await tester.pumpAndSettle();
      expect(find.text('PDF saved to Downloads › AdvocateMate'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('says when the same PDF was already saved', (tester) async {
      await _pumpButton(
        tester,
        _FakeSaver(() async => const SavedPdf(PdfSaveStatus.alreadySaved, 'Downloads › AdvocateMate')),
      );
      await tester.tap(find.byKey(const Key('pdfDownloadButton')));
      await tester.pumpAndSettle();
      expect(find.text('This PDF is already saved in Downloads › AdvocateMate'), findsOneWidget);
    });

    testWidgets('explains a refused permission and other failures', (tester) async {
      await _pumpButton(tester, _FakeSaver(() async => throw const PdfSaveException('permission_denied')));
      await tester.tap(find.byKey(const Key('pdfDownloadButton')));
      await tester.pumpAndSettle();
      expect(find.text('Allow storage access to save PDFs on this device.'), findsOneWidget);

      await _pumpButton(tester, _FakeSaver(() async => throw StateError('disk full')));
      await tester.tap(find.byKey(const Key('pdfDownloadButton')));
      await tester.pumpAndSettle();
      expect(find.text('Could not save the PDF. Please try again.'), findsOneWidget);
    });
  });
}
