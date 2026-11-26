import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/formatters.dart';
import '../../shared/widgets/widgets.dart';

/// Outcome of saving a PDF into the device's user-visible storage.
enum PdfSaveStatus { saved, alreadySaved }

class SavedPdf {
  const SavedPdf(this.status, this.location);
  final PdfSaveStatus status;

  /// Where the person can find the file, e.g. "Downloads › AdvocateMate".
  final String location;
}

/// [code] is `permission_denied` (Android 7–9 storage permission refused) or `failed`.
class PdfSaveException implements Exception {
  const PdfSaveException(this.code);
  final String code;

  @override
  String toString() => 'PdfSaveException($code)';
}

/// Copies an already downloaded and validated PDF into storage the person can open from a file app.
abstract interface class PdfSaver {
  Future<SavedPdf> save({required String sourcePath, required String fileName});
}

/// Android: MainActivity's `in.advocatemate.app/downloads` channel writes to Downloads/AdvocateMate
/// (MediaStore on Android 10+, the public Downloads folder with storage permission on Android 7–9).
class AndroidPdfSaver implements PdfSaver {
  static const channel = MethodChannel('in.advocatemate.app/downloads');

  @override
  Future<SavedPdf> save({required String sourcePath, required String fileName}) async {
    try {
      final r = await channel.invokeMapMethod<String, Object?>('savePdf', {'path': sourcePath, 'name': fileName});
      if (r == null) throw const PdfSaveException('failed');
      return SavedPdf(
        r['status'] == 'exists' ? PdfSaveStatus.alreadySaved : PdfSaveStatus.saved,
        (r['location'] as String?) ?? 'Downloads',
      );
    } on PlatformException catch (e) {
      throw PdfSaveException(e.code == 'permission_denied' ? 'permission_denied' : 'failed');
    }
  }
}

/// iOS (and anything else): the app's Documents folder, which Info.plist exposes in the Files app
/// (On My iPhone › AdvocateMate). An identical file with the same name is not saved twice; a different
/// file with the same name gets a numbered copy.
class DocumentsPdfSaver implements PdfSaver {
  DocumentsPdfSaver({Future<Directory> Function()? directory, this.location = 'Files › On My iPhone › AdvocateMate'})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;
  final String location;

  @override
  Future<SavedPdf> save({required String sourcePath, required String fileName}) async {
    try {
      final dir = await _directory();
      final bytes = await File(sourcePath).readAsBytes();
      final stem = fileName.toLowerCase().endsWith('.pdf') ? fileName.substring(0, fileName.length - 4) : fileName;
      var target = File('${dir.path}${Platform.pathSeparator}$fileName');
      for (var n = 2; await target.exists(); n++) {
        if (await _sameContent(target, bytes)) return SavedPdf(PdfSaveStatus.alreadySaved, location);
        target = File('${dir.path}${Platform.pathSeparator}$stem ($n).pdf');
      }
      await target.writeAsBytes(bytes, flush: true);
      return SavedPdf(PdfSaveStatus.saved, location);
    } on FileSystemException {
      throw const PdfSaveException('failed');
    }
  }

  static Future<bool> _sameContent(File f, List<int> bytes) async {
    if (await f.length() != bytes.length) return false;
    final other = await f.readAsBytes();
    for (var i = 0; i < other.length; i++) {
      if (other[i] != bytes[i]) return false;
    }
    return true;
  }
}

final pdfSaverProvider = Provider<PdfSaver>((ref) => Platform.isAndroid ? AndroidPdfSaver() : DocumentsPdfSaver());

/// Meaningful, file-system-safe name for a downloaded PDF.
/// [kind] is `summary` (AdvocateMate-generated case summary), `court` or `weekly` (official APHC lists).
String pdfDownloadName({
  required String kind,
  String? label,
  String? caseId,
  String? courtNo,
  String? isoDate,
  DateTime? today,
}) {
  String clean(String? s) => (s ?? '')
      .trim()
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '');
  String or(String a, String fallback) => a.isEmpty ? fallback : a;
  final name = switch (kind) {
    'summary' => 'AdvocateMate-Case-Summary-${or(clean(label), or(clean(caseId), 'Case'))}',
    'court' =>
      'APHC-Court-${or(clean(courtNo), 'X')}-Cause-List-${or(clean(isoDate), Fmt.isoDate(today ?? DateTime.now()))}',
    _ => 'APHC-Weekly-Cause-List-${Fmt.isoDate(today ?? DateTime.now())}',
  };
  return '$name.pdf';
}

/// App-bar Download action: saves the open PDF (the exact bytes shown) and reports the result.
class PdfDownloadButton extends ConsumerStatefulWidget {
  const PdfDownloadButton({super.key, required this.filePath, required this.fileName});
  final String filePath;
  final String fileName;

  @override
  ConsumerState<PdfDownloadButton> createState() => _PdfDownloadButtonState();
}

class _PdfDownloadButtonState extends ConsumerState<PdfDownloadButton> {
  bool _saving = false;

  Future<void> _save() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    String message;
    try {
      final r = await ref.read(pdfSaverProvider).save(sourcePath: widget.filePath, fileName: widget.fileName);
      message = r.status == PdfSaveStatus.saved ? l.pdfSaved(r.location) : l.pdfAlreadySaved(r.location);
    } on PdfSaveException catch (e) {
      message = e.code == 'permission_denied' ? l.pdfSavePermission : l.pdfSaveFailed;
    } catch (_) {
      message = l.pdfSaveFailed;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(key: const Key('pdfSaveMessage'), content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return IconButton(
      key: const Key('pdfDownloadButton'),
      tooltip: _saving ? l.savingPdf : l.download,
      onPressed: _saving ? null : _save,
      icon: _saving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2))
          : const Icon(AppIcons.download),
    );
  }
}
