import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';
import '../models/models.dart';
import 'widgets.dart';

/// How the court list relates to the official court PDF: verified, differences, read from the PDF, or
/// nothing to check against. Never shown for lists without a PDF check (weekly / supplementary).
class PdfCheckBanner extends StatelessWidget {
  const PdfCheckBanner({super.key, required this.listing, this.showingDifferences = false, this.onToggleDifferences});
  final CourtListing listing;
  final bool showingDifferences;
  final VoidCallback? onToggleDifferences;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (listing.itemsSource == 'official_pdf') {
      return _Banner(
        key: const Key('pdfFallbackBanner'),
        color: AppColors.warning,
        icon: AppIcons.pdf,
        text: listing.fallbackReason == 'online_list_empty' ? l.pdfFallbackEmpty : l.pdfFallbackUnavailable,
      );
    }
    final v = listing.pdfVerification;
    if (v == null) return const SizedBox.shrink();
    switch (v.status) {
      case 'verified':
        return _Banner(
          key: const Key('pdfVerifiedBanner'),
          color: AppColors.success,
          icon: AppIcons.verified,
          text: l.pdfVerified(v.matched),
        );
      case 'differences':
        return _Banner(
          key: const Key('pdfDifferencesBanner'),
          color: AppColors.warning,
          icon: AppIcons.differs,
          text: l.pdfDifferences(v.differs, v.notInPdf, v.pdfOnly),
          action: (v.differs + v.notInPdf) > 0 && onToggleDifferences != null
              ? TextButton(
                  key: const Key('pdfToggleDifferences'),
                  onPressed: onToggleDifferences,
                  child: Text(showingDifferences ? l.pdfShowAll : l.pdfShowDifferences))
              : null,
        );
      case 'failed':
      case 'pdf_empty':
        return _Note(key: const Key('pdfUnreadableNote'), text: l.pdfUnreadable);
      default:
        return _Note(key: const Key('pdfNotAvailableNote'), text: l.pdfNotAvailable);
    }
  }
}

/// Badge for one item that does not match the official PDF (nothing for matching items).
Widget? pdfCheckBadge(BuildContext context, PdfCheck? check) {
  final l = context.l10n;
  switch (check?.status) {
    case 'differs':
      return StatusChip(l.pdfDiffersBadge, color: AppColors.warning, icon: AppIcons.differs);
    case 'not_in_pdf':
      return StatusChip(l.pdfNotInPdfBadge, color: AppColors.warning, icon: AppIcons.unknown);
    default:
      return null;
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.color, required this.icon, required this.text, this.action});
  final Color color;
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) =>
      InfoBanner(color: StatusChip.resolve(context, color), icon: icon, text: text, action: action);
}

class _Note extends StatelessWidget {
  const _Note({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = context.tokens.textTertiary;
    return Padding(
      padding: AppLayout.page(context, top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(AppIcons.pdf, size: 15, color: c),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: t.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
