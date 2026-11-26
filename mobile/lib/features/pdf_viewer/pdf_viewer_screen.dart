import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors.dart';
import '../../core/providers.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_theme.dart';

/// What to open: official weekly / court PDF (proxied by backend) or generated summary.
class PdfRequest {
  const PdfRequest({required this.kind, this.caseId, this.courtNo, this.isoDate});
  final String kind; // weekly | court | summary
  final String? caseId;
  final String? courtNo;
  final String? isoDate;

  factory PdfRequest.fromQuery(Map<String, String> q) =>
      PdfRequest(kind: q['kind'] ?? 'weekly', caseId: q['case'], courtNo: q['court'], isoDate: q['date']);

  bool get isGenerated => kind == 'summary';

  String get path => switch (kind) {
        'summary' => '/cases/$caseId/pdf',
        'court' => '/cause-list/court/$courtNo/pdf',
        _ => '/cause-list/weekly.pdf',
      };

  Map<String, dynamic>? get query => kind == 'court' ? {'date': isoDate} : null;

  String get fileName => switch (kind) {
        'summary' => 'case-summary-advocatemate-generated.pdf',
        'court' => 'aphc-court-$courtNo-$isoDate.pdf',
        _ => 'aphc-weekly-cause-list.pdf',
      };
}

class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({super.key, required this.request});
  final PdfRequest request;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  double _progress = 0;
  Object? _error;
  String? _file;
  bool? _official;
  PdfControllerPinch? _controller;
  final _cancel = CancelToken();

  @override
  void initState() {
    super.initState();
    _download();
  }

  @override
  void dispose() {
    _cancel.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    setState(() {
      _error = null;
      _progress = 0;
    });
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${widget.request.fileName}';
      final headers = await ref.read(apiClientProvider).download(widget.request.path, path,
          query: widget.request.query, cancel: _cancel, onProgress: (p) => mounted ? setState(() => _progress = p) : null);
      if (!mounted) return;
      final official = headers.value('x-document-official') == 'true';
      final bytes = await File(path).openRead(0, 5).first;
      if (String.fromCharCodes(bytes) != '%PDF-') throw ApiException.unknown('The file received is not a PDF.');
      // Open here (not lazily inside the controller) so a corrupt or truncated PDF is
      // caught below and shown as an error with Retry instead of an unhandled exception.
      final PdfDocument document;
      try {
        document = await PdfDocument.openFile(path);
      } catch (_) {
        throw ApiException.unknown('This PDF could not be opened. It may be incomplete or damaged.');
      }
      if (!mounted) {
        await document.close();
        return;
      }
      setState(() {
        _file = path;
        _official = official;
        _controller = PdfControllerPinch(document: Future.value(document));
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = switch (widget.request.kind) {
      'summary' => l.caseSummaryPdf,
      'court' => '${l.officialPdf} · ${l.court(widget.request.courtNo ?? '')}',
      _ => l.weeklyPdf,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_file != null)
            IconButton(
              tooltip: l.share,
              icon: const Icon(AppIcons.share),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  files: [XFile(_file!, mimeType: 'application/pdf')],
                  text: widget.request.isGenerated ? l.generatedPdfNotice : null,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.request.isGenerated || _official == false)
            InfoBanner(
              key: const Key('generatedNotice'),
              color: context.tokens.danger,
              icon: AppIcons.warning,
              text: l.generatedPdfNotice,
              margin: AppLayout.page(context, top: AppSpacing.xs, bottom: AppSpacing.sm),
            ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final l = context.l10n;
    if (_error != null) return ErrorState(error: _error!, onRetry: _download);
    final c = _controller;
    if (c == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconBadge(AppIcons.pdf, size: 64, iconSize: 28),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(minHeight: 6, value: _progress > 0 ? _progress : null),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.downloading((_progress * 100).round()), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(child: PdfViewPinch(controller: c)),
        SafeArea(
          top: false,
          child: PdfPageNumber(
            controller: c,
            builder: (_, loadingState, page, pagesCount) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: context.tokens.cardBorder),
                    boxShadow: AppShadows.card(Theme.of(context).brightness),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).previousPageTooltip,
                        icon: const Icon(AppIcons.chevronLeft),
                        onPressed: page > 1
                            ? () => c.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut)
                            : null,
                      ),
                      Text(l.page(page, pagesCount ?? 0), style: Theme.of(context).textTheme.labelLarge),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).nextPageTooltip,
                        icon: const Icon(AppIcons.chevronRight),
                        onPressed: page < (pagesCount ?? 0)
                            ? () => c.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
