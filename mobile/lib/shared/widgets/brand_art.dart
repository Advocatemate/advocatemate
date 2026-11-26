import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';

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

/// The navy body of [HeroBackgroundPainter] as a clip, so a photo can sit inside the curved hero.
class HeroCurveClipper extends CustomClipper<Path> {
  const HeroCurveClipper({this.curve = 40});
  final double curve;

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(0, size.height - 7)
    ..quadraticBezierTo(size.width * .55, size.height - 7 - curve * .15, size.width, size.height - 7 - curve)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(HeroCurveClipper old) => old.curve != curve;
}

/// Realistic courthouse photo for hero headers: clipped to the hero curve, with a navy fade from the
/// left (where the text sits) and from the bottom, so white text always stays readable.
class HeroPhoto extends StatelessWidget {
  const HeroPhoto({super.key, required this.top, required this.bottom, this.curve = 40, this.textSide = .94});
  final Color top;
  final Color bottom;
  final double curve;

  /// Opacity of the navy fade at the left edge.
  final double textSide;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipPath(
        clipper: HeroCurveClipper(curve: curve),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/court_hero.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(.7, -.55),
              filterQuality: FilterQuality.medium,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    bottom.withValues(alpha: textSide),
                    bottom.withValues(alpha: textSide * .66),
                    bottom.withValues(alpha: .08),
                  ],
                  stops: const [0, .48, 1],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top.withValues(alpha: .35), Colors.transparent, bottom.withValues(alpha: .6)],
                  stops: const [0, .35, 1],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
