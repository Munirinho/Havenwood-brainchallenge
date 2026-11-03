import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

class ManorArt extends StatelessWidget {
  final double progress;
  final Color accent;

  const ManorArt({
    super.key,
    required this.progress,
    this.accent = HavenColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 360 / 260,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 1600),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _ManorPainter(progress: value, accent: accent),
          );
        },
      ),
    );
  }
}

class _ManorPainter extends CustomPainter {
  final double progress;
  final Color accent;

  _ManorPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 260);

    _paintSky(canvas);
    _paintMoon(canvas);
    _paintStars(canvas);
    _paintDistantLand(canvas);
    _paintHouse(canvas);
    _paintGarden(canvas);
    _paintFireflies(canvas);

    canvas.restore();
  }

  void _paintSky(Canvas canvas) {
    final rect = const Rect.fromLTWH(0, 0, 360, 260);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1C2B47),
          const Color(0xFF111D31),
          const Color(0xFF09121D),
        ],
        stops: const [0, 0.56, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final haze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.55, 0.12),
        radius: 0.85,
        colors: [accent.withValues(alpha: 0.13), accent.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawRect(rect, haze);
  }

  void _paintMoon(Canvas canvas) {
    const center = Offset(298, 56);
    final glow = Paint()
      ..color = const Color(0xFFFFEDC2).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, 34, glow);
    canvas.drawCircle(
      center,
      19,
      Paint()..color = const Color(0xFFFFF2D1).withValues(alpha: 0.94),
    );
    canvas.drawCircle(
      center + const Offset(6, 3),
      15,
      Paint()..color = const Color(0xFFEEDDB8).withValues(alpha: 0.48),
    );
    canvas.drawCircle(
      center + const Offset(-5, -4),
      3,
      Paint()..color = const Color(0xFFD9C9A9).withValues(alpha: 0.36),
    );
    canvas.drawCircle(
      center + const Offset(4, 7),
      2,
      Paint()..color = const Color(0xFFD9C9A9).withValues(alpha: 0.28),
    );
  }

  void _paintStars(Canvas canvas) {
    const stars = [
      Offset(24, 34),
      Offset(62, 19),
      Offset(104, 47),
      Offset(138, 23),
      Offset(172, 55),
      Offset(215, 28),
      Offset(246, 70),
      Offset(334, 31),
      Offset(320, 92),
      Offset(48, 82),
      Offset(265, 19),
      Offset(190, 14),
    ];
    for (var i = 0; i < stars.length; i++) {
      final pulse = 0.35 + progress * 0.4 + (i % 3) * 0.08;
      canvas.drawCircle(
        stars[i],
        i % 4 == 0 ? 1.5 : 1,
        Paint()..color = Colors.white.withValues(alpha: pulse),
      );
    }
  }

  void _paintDistantLand(Canvas canvas) {
    final farHill = Path()
      ..moveTo(0, 172)
      ..quadraticBezierTo(58, 145, 116, 168)
      ..quadraticBezierTo(170, 188, 228, 163)
      ..quadraticBezierTo(300, 136, 360, 165)
      ..lineTo(360, 260)
      ..lineTo(0, 260)
      ..close();
    canvas.drawPath(farHill, Paint()..color = const Color(0xFF102334));

    final nearHill = Path()
      ..moveTo(0, 192)
      ..quadraticBezierTo(72, 168, 150, 190)
      ..quadraticBezierTo(235, 214, 360, 184)
      ..lineTo(360, 260)
      ..lineTo(0, 260)
      ..close();
    canvas.drawPath(nearHill, Paint()..color = const Color(0xFF0B1926));

    const treePaint = Color(0xFF122B2B);
    _drawTree(canvas, const Offset(34, 178), 44, treePaint);
    _drawTree(canvas, const Offset(326, 174), 38, treePaint);
    _drawTree(canvas, const Offset(60, 184), 26, treePaint);
  }

  void _drawTree(Canvas canvas, Offset base, double height, Color color) {
    final trunk = Paint()
      ..color = const Color(0xFF0A1519)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base - Offset(0, height * 0.5), trunk);
    final crown = Paint()..color = color;
    canvas.drawCircle(base - Offset(0, height * 0.58), height * 0.3, crown);
    canvas.drawCircle(
      base - Offset(height * 0.23, height * 0.45),
      height * 0.22,
      crown,
    );
    canvas.drawCircle(
      base - Offset(-height * 0.24, height * 0.48),
      height * 0.25,
      crown,
    );
  }

  void _paintHouse(Canvas canvas) {
    final wallBase = Color.lerp(
      const Color(0xFF1B2A41),
      const Color(0xFF2A3E5D),
      progress * 0.55,
    )!;
    final wallPaint = Paint()..color = wallBase;
    final wingPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF17253A),
        const Color(0xFF233651),
        progress * 0.5,
      )!;
    final roofPaint = Paint()..color = const Color(0xFF0E1827);
    final roofEdge = Paint()
      ..color = const Color(0xFF425771).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    canvas.drawRect(const Rect.fromLTWH(72, 156, 34, 54), wingPaint);
    canvas.drawRect(const Rect.fromLTWH(254, 156, 34, 54), wingPaint);

    final leftWingRoof = Path()
      ..moveTo(66, 158)
      ..lineTo(90, 139)
      ..lineTo(112, 158)
      ..close();
    final rightWingRoof = Path()
      ..moveTo(248, 158)
      ..lineTo(270, 139)
      ..lineTo(294, 158)
      ..close();
    canvas.drawPath(leftWingRoof, roofPaint);
    canvas.drawPath(rightWingRoof, roofPaint);
    canvas.drawPath(leftWingRoof, roofEdge);
    canvas.drawPath(rightWingRoof, roofEdge);

    canvas.drawRect(const Rect.fromLTWH(98, 132, 164, 78), wallPaint);

    final mainRoof = Path()
      ..moveTo(86, 136)
      ..lineTo(180, 72)
      ..lineTo(274, 136)
      ..close();
    canvas.drawPath(mainRoof, roofPaint);
    canvas.drawPath(mainRoof, roofEdge);

    final roofHighlight = Paint()
      ..color = const Color(0xFF4A5D77).withValues(alpha: 0.25)
      ..strokeWidth = 0.8;
    for (var i = 1; i < 4; i++) {
      final offset = i * 15.0;
      canvas.drawLine(
        Offset(101 + offset, 132 - offset * 0.48),
        Offset(259 - offset, 132 - offset * 0.48),
        roofHighlight,
      );
    }

    canvas.drawRect(const Rect.fromLTWH(154, 102, 52, 108), wallPaint);
    final towerRoof = Path()
      ..moveTo(148, 105)
      ..lineTo(180, 34)
      ..lineTo(212, 105)
      ..close();
    canvas.drawPath(towerRoof, roofPaint);
    canvas.drawPath(towerRoof, roofEdge);

    final spire = Paint()
      ..color = const Color(0xFF8DA0B8)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(180, 34), const Offset(180, 23), spire);
    canvas.drawCircle(
      const Offset(180, 22),
      2.3,
      Paint()..color = accent.withValues(alpha: 0.85),
    );

    final trimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(98, 207), const Offset(262, 207), trimPaint);
    canvas.drawLine(const Offset(154, 207), const Offset(206, 207), trimPaint);

    _drawWindow(canvas, const Rect.fromLTWH(80, 174, 12, 18), 1, arch: true);
    _drawWindow(canvas, const Rect.fromLTWH(268, 174, 12, 18), 2, arch: true);
    _drawWindow(canvas, const Rect.fromLTWH(110, 151, 14, 21), 3);
    _drawWindow(canvas, const Rect.fromLTWH(131, 151, 14, 21), 4);
    _drawWindow(canvas, const Rect.fromLTWH(215, 151, 14, 21), 5);
    _drawWindow(canvas, const Rect.fromLTWH(236, 151, 14, 21), 6);
    _drawWindow(canvas, const Rect.fromLTWH(110, 182, 14, 21), 7);
    _drawWindow(canvas, const Rect.fromLTWH(131, 182, 14, 21), 8);
    _drawWindow(canvas, const Rect.fromLTWH(215, 182, 14, 21), 9);
    _drawWindow(canvas, const Rect.fromLTWH(236, 182, 14, 21), 10);
    _drawRoundWindow(canvas, const Offset(166, 123), 5.2, 11);
    _drawRoundWindow(canvas, const Offset(194, 123), 5.2, 12);
    _drawWindow(canvas, const Rect.fromLTWH(168, 145, 24, 25), 13, arch: true);
    _drawWindow(canvas, const Rect.fromLTWH(168, 178, 24, 30), 14, arch: true);

    _drawDoor(canvas);
    _paintVines(canvas);
  }

  void _drawWindow(Canvas canvas, Rect rect, int index, {bool arch = false}) {
    final lit = (progress * 15).round() >= index;
    final framePaint = Paint()
      ..color = const Color(0xFF0A121D).withValues(alpha: 0.88);
    if (arch) {
      final shape = Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + rect.width / 2)
        ..arcTo(
          Rect.fromLTWH(rect.left, rect.top, rect.width, rect.width),
          math.pi,
          math.pi,
          false,
        )
        ..lineTo(rect.right, rect.bottom)
        ..close();
      canvas.drawPath(shape, framePaint);
      if (lit) {
        final inner = rect.deflate(1.6);
        final shapeLit = Path()
          ..moveTo(inner.left, inner.bottom)
          ..lineTo(inner.left, inner.top + inner.width / 2)
          ..arcTo(
            Rect.fromLTWH(inner.left, inner.top, inner.width, inner.width),
            math.pi,
            math.pi,
            false,
          )
          ..lineTo(inner.right, inner.bottom)
          ..close();
        _drawPaneGlow(canvas, rect.center, rect.width * 0.8);
        canvas.drawPath(shapeLit, Paint()..color = _windowLight);
        canvas.drawLine(
          inner.centerLeft,
          inner.centerRight,
          Paint()
            ..color = const Color(0xFF3A2B16).withValues(alpha: 0.65)
            ..strokeWidth = 0.8,
        );
      }
    } else {
      canvas.drawRect(rect, framePaint);
      if (lit) {
        final inner = rect.deflate(1.6);
        _drawPaneGlow(canvas, rect.center, rect.width * 0.85);
        canvas.drawRect(inner, Paint()..color = _windowLight);
        canvas.drawLine(
          inner.centerLeft,
          inner.centerRight,
          Paint()
            ..color = const Color(0xFF3A2B16).withValues(alpha: 0.55)
            ..strokeWidth = 0.8,
        );
        canvas.drawLine(
          inner.topCenter,
          inner.bottomCenter,
          Paint()
            ..color = const Color(0xFF3A2B16).withValues(alpha: 0.38)
            ..strokeWidth = 0.7,
        );
      }
    }
  }

  void _drawRoundWindow(
    Canvas canvas,
    Offset center,
    double radius,
    int index,
  ) {
    final lit = (progress * 15).round() >= index;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF0A121D));
    if (!lit) return;
    _drawPaneGlow(canvas, center, radius * 1.5);
    canvas.drawCircle(center, radius - 1.3, Paint()..color = _windowLight);
    canvas.drawLine(
      center - Offset(radius - 2, 0),
      center + Offset(radius - 2, 0),
      Paint()
        ..color = const Color(0xFF3A2B16).withValues(alpha: 0.5)
        ..strokeWidth = 0.7,
    );
  }

  Color get _windowLight => Color.lerp(
    const Color(0xFFFFCE74),
    const Color(0xFFFFE8AC),
    (progress + 0.2).clamp(0, 1),
  )!;

  void _drawPaneGlow(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 1.8,
      Paint()
        ..color = _windowLight.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  void _drawDoor(Canvas canvas) {
    final path = Path()
      ..moveTo(162, 210)
      ..lineTo(162, 190)
      ..arcTo(const Rect.fromLTWH(162, 178, 36, 24), math.pi, math.pi, false)
      ..lineTo(198, 210)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF0B141F));
    final inner = Path()
      ..moveTo(165, 210)
      ..lineTo(165, 191)
      ..arcTo(const Rect.fromLTWH(165, 181, 30, 20), math.pi, math.pi, false)
      ..lineTo(195, 210)
      ..close();
    canvas.drawPath(
      inner,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF1B2633),
          accent.withValues(alpha: 0.28),
          progress,
        )!,
    );
    canvas.drawCircle(
      const Offset(189, 198),
      1.7,
      Paint()..color = accent.withValues(alpha: 0.55 + progress * 0.35),
    );
    if (progress > 0.32) {
      final glow = Paint()
        ..shader =
            RadialGradient(
              colors: [
                accent.withValues(alpha: 0.2 * progress),
                accent.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: const Offset(180, 206), radius: 34),
            );
      canvas.drawCircle(const Offset(180, 206), 34, glow);
    }
  }

  void _paintVines(Canvas canvas) {
    final vinePaint = Paint()
      ..color = const Color(0xFF2C5A4E).withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    final retreat = progress * 28;
    for (var i = 0; i < 5; i++) {
      final x = 100.0 + i * 9;
      final path = Path()
        ..moveTo(x, 210)
        ..quadraticBezierTo(
          x + 8,
          196 - retreat * 0.4,
          x + 2,
          184 - retreat * 0.6,
        )
        ..quadraticBezierTo(x - 6, 174 - retreat * 0.4, x + 4, 166 - retreat);
      canvas.drawPath(path, vinePaint);
    }
  }

  void _paintGarden(Canvas canvas) {
    final path = Path()
      ..moveTo(166, 210)
      ..lineTo(194, 210)
      ..quadraticBezierTo(212, 224, 246, 260)
      ..lineTo(114, 260)
      ..quadraticBezierTo(148, 224, 166, 210)
      ..close();
    final pathPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF29384C), const Color(0xFF141E2B)],
      ).createShader(const Rect.fromLTWH(100, 210, 160, 50));
    canvas.drawPath(path, pathPaint);

    final borderGlow = Paint()
      ..color = accent.withValues(alpha: 0.07 + progress * 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      Path()
        ..moveTo(159, 210)
        ..quadraticBezierTo(138, 229, 106, 260),
      borderGlow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(201, 210)
        ..quadraticBezierTo(222, 229, 254, 260),
      borderGlow,
    );

    final hedge = Paint()..color = const Color(0xFF0B1E1A);
    final hedgeHighlight = Paint()
      ..color = const Color(0xFF18352C).withValues(alpha: 0.8);
    for (final spot in const [
      Offset(28, 238),
      Offset(54, 230),
      Offset(76, 244),
      Offset(308, 236),
      Offset(330, 244),
      Offset(288, 250),
    ]) {
      canvas.drawCircle(spot, 20, hedge);
      canvas.drawCircle(spot - const Offset(3, 5), 13, hedgeHighlight);
    }

    final flowerColors = [
      accent,
      HavenColors.rose,
      HavenColors.lilac,
      HavenColors.cream,
    ];
    const flowers = [
      Offset(22, 225),
      Offset(42, 236),
      Offset(63, 221),
      Offset(86, 238),
      Offset(300, 224),
      Offset(318, 234),
      Offset(339, 228),
      Offset(275, 240),
      Offset(112, 250),
      Offset(250, 250),
    ];
    final bloomCount = (progress * flowers.length).round();
    for (var i = 0; i < bloomCount; i++) {
      final spot = flowers[i];
      canvas.drawLine(
        spot,
        spot + const Offset(0, 5),
        Paint()
          ..color = const Color(0xFF2D5948)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(spot, 2.6, Paint()..color = flowerColors[i % 4]);
      if (progress > 0.7) {
        canvas.drawCircle(
          spot,
          6,
          Paint()
            ..color = flowerColors[i % 4].withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    final fog = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          HavenColors.ink.withValues(alpha: 0),
          HavenColors.ink.withValues(alpha: 0.55),
        ],
      ).createShader(const Rect.fromLTWH(0, 222, 360, 38));
    canvas.drawRect(const Rect.fromLTWH(0, 222, 360, 38), fog);
  }

  void _paintFireflies(Canvas canvas) {
    final count = (progress * 14).round();
    const spots = [
      Offset(43, 196),
      Offset(80, 208),
      Offset(128, 194),
      Offset(233, 192),
      Offset(278, 203),
      Offset(315, 190),
      Offset(148, 224),
      Offset(218, 228),
      Offset(103, 216),
      Offset(264, 221),
      Offset(60, 174),
      Offset(302, 164),
      Offset(184, 72),
      Offset(244, 84),
    ];
    for (var i = 0; i < count; i++) {
      final spot = spots[i];
      final alpha = 0.35 + (i % 4) * 0.12;
      canvas.drawCircle(
        spot,
        5,
        Paint()
          ..color = accent.withValues(alpha: alpha * 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        spot,
        1.2,
        Paint()..color = const Color(0xFFFFEDBC).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ManorPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
