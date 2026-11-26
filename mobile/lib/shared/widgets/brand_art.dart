import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';

/// Classical courthouse silhouette (pediment, columns, wings, steps) drawn in code — no image asset.
/// [color] is the base tone; the drawing fades out towards the left so text in front stays readable.
class CourthousePainter extends CustomPainter {
  const CourthousePainter({required this.color, this.fadeLeft = true});
  final Color color;
  final bool fadeLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: fadeLeft ? [color.withValues(alpha: 0), color, color] : [color, color],
        stops: fadeLeft ? const [0, .45, 1] : null,
      ).createShader(rect);
    final line = Paint()
      ..color = color.withValues(alpha: color.a * .9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .006;

    // Own layer so the window cut-outs (dstOut) only erase the building, not the hero behind it.
    canvas.saveLayer(rect, Paint());
    final baseY = h * .96;
    final mainL = w * .22, mainR = w * .86;
    final colTop = h * .42, colBottom = h * .82;

    // Steps
    for (var i = 0; i < 3; i++) {
      final inset = i * w * .025;
      canvas.drawRect(
        Rect.fromLTRB(
          mainL - w * .06 + inset,
          baseY - (i + 1) * h * .045,
          mainR + w * .06 - inset,
          baseY - i * h * .045,
        ),
        fill,
      );
    }
    // Side wings with windows
    for (final (l, r) in [(0.0, mainL), (mainR, w)]) {
      canvas.drawRect(Rect.fromLTRB(l, h * .5, r, colBottom), fill);
      canvas.drawRect(Rect.fromLTRB(l, h * .47, r, h * .5), fill);
      for (var row = 0; row < 2; row++) {
        for (var c = 0; c < 2; c++) {
          final cw = (r - l) / 2;
          final x = l + cw * c + cw * .3;
          final y = h * .55 + row * h * .13;
          canvas.drawRect(Rect.fromLTWH(x, y, cw * .4, h * .08), Paint()..blendMode = BlendMode.dstOut);
        }
      }
    }
    // Entablature + pediment
    canvas.drawRect(Rect.fromLTRB(mainL - w * .02, colTop - h * .07, mainR + w * .02, colTop), fill);
    final ped = Path()
      ..moveTo(mainL - w * .03, colTop - h * .07)
      ..lineTo((mainL + mainR) / 2, h * .12)
      ..lineTo(mainR + w * .03, colTop - h * .07)
      ..close();
    canvas.drawPath(ped, fill);
    canvas.drawPath(
      Path()
        ..moveTo(mainL + w * .04, colTop - h * .09)
        ..lineTo((mainL + mainR) / 2, h * .17)
        ..lineTo(mainR - w * .04, colTop - h * .09),
      line..blendMode = BlendMode.dstOut,
    );
    // Columns
    const n = 6;
    final colW = (mainR - mainL) / (n * 2 - 1);
    for (var i = 0; i < n; i++) {
      final x = mainL + i * colW * 2;
      canvas.drawRect(Rect.fromLTRB(x, colTop + h * .02, x + colW, colBottom), fill);
      canvas.drawRect(Rect.fromLTRB(x - colW * .2, colTop, x + colW * 1.2, colTop + h * .025), fill);
    }
    canvas.drawRect(Rect.fromLTRB(mainL - w * .02, colBottom, mainR + w * .02, colBottom + h * .03), fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CourthousePainter old) => old.color != color || old.fadeLeft != fadeLeft;
}

/// Navy hero whose bottom edge sweeps up to the right, trimmed with a gold band.
class HeroBackgroundPainter extends CustomPainter {
  const HeroBackgroundPainter({required this.top, required this.bottom, this.curve = 40});
  final Color top;
  final Color bottom;
  final double curve;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Gold band first; the navy body is drawn 7 px higher so only the band's lower edge shows.
    final goldPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..quadraticBezierTo(size.width * .55, size.height - curve * .15, size.width, size.height - curve)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      goldPath,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0xFFE3C27A), AppColors.gold, Color(0xFF9C7631)])
            .createShader(rect),
    );
    final body = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 7)
      ..quadraticBezierTo(size.width * .55, size.height - 7 - curve * .15, size.width, size.height - 7 - curve)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(HeroBackgroundPainter old) => old.top != top || old.bottom != bottom || old.curve != curve;
}

/// Gold swoosh tucked into the bottom-right corner of a dark card.
class GoldSwooshPainter extends CustomPainter {
  const GoldSwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * .35, h)
      ..quadraticBezierTo(w * .8, h * .78, w, h * .1)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFE6C784), AppColors.gold, Color(0xFFA77E35)],
        ).createShader(Offset.zero & size),
    );
    // A thin navy line separates the swoosh from the card, as in a ribbon.
    final inner = Path()
      ..moveTo(w * .45, h)
      ..quadraticBezierTo(w * .85, h * .82, w, h * .32);
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.navyDeep.withValues(alpha: .55),
    );
  }

  @override
  bool shouldRepaint(GoldSwooshPainter old) => false;
}
