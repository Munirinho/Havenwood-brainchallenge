import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/models.dart';
import '../theme/haven_theme.dart';

class RoomIllustration extends StatelessWidget {
  final RoomDef room;
  final double progress;

  const RoomIllustration({
    super.key,
    required this.room,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 360 / 220,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _RoomPainter(room: room, progress: value),
          );
        },
      ),
    );
  }
}

class _RoomPainter extends CustomPainter {
  final RoomDef room;
  final double progress;

  _RoomPainter({required this.room, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 220);
    _paintShell(canvas);
    switch (room.index) {
      case 0:
        _paintAtrium(canvas);
      case 1:
        _paintLibrary(canvas);
      case 2:
        _paintGreenhouse(canvas);
      case 3:
        _paintObservatory(canvas);
      case 4:
        _paintClocktower(canvas);
      case 5:
        _paintSanctum(canvas);
    }
    _paintAtmosphere(canvas);
    canvas.restore();
  }

  Color get accent => room.accent;
  Color get glow => room.glow;

  void _paintShell(Canvas canvas) {
    const rect = Rect.fromLTWH(0, 0, 360, 220);
    final wallPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFF15223A), accent, 0.09)!,
          const Color(0xFF09111E),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, wallPaint);

    final upperGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.8),
        radius: 0.9,
        colors: [
          accent.withValues(alpha: 0.13 + progress * 0.06),
          accent.withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, upperGlow);

    final floorRect = const Rect.fromLTWH(0, 166, 360, 54);
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF182331), accent, 0.06)!,
          const Color(0xFF080D16),
        ],
      ).createShader(floorRect);
    canvas.drawRect(floorRect, floorPaint);

    final boardPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 0.8;
    canvas.drawLine(const Offset(0, 166), const Offset(360, 166), boardPaint);
    for (var i = 0; i < 9; i++) {
      final x = i * 46.0;
      canvas.drawLine(Offset(x, 167), Offset(x - 22, 220), boardPaint);
    }

    final wallPanel = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final x = 28.0 + i * 94;
      canvas.drawLine(Offset(x, 20), Offset(x, 164), wallPanel);
    }
  }

  void _paintAtrium(Canvas canvas) {
    final window = Rect.fromLTWH(143, 14, 74, 126);
    _drawArchedWindow(canvas, window, starfield: true, lit: true);

    final curtain = Paint()
      ..color = Color.lerp(
        const Color(0xFF372E46),
        accent,
        0.12,
      )!.withValues(alpha: 0.82);
    final leftCurtain = Path()
      ..moveTo(132, 11)
      ..quadraticBezierTo(146, 54, 137, 144)
      ..lineTo(154, 144)
      ..quadraticBezierTo(150, 74, 152, 18)
      ..close();
    final rightCurtain = Path()
      ..moveTo(228, 11)
      ..quadraticBezierTo(214, 54, 223, 144)
      ..lineTo(206, 144)
      ..quadraticBezierTo(210, 74, 208, 18)
      ..close();
    canvas.drawPath(leftCurtain, curtain);
    canvas.drawPath(rightCurtain, curtain);

    _drawChandelier(canvas, const Offset(180, 0));

    final rug = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.16 + progress * 0.08),
          accent.withValues(alpha: 0.02),
        ],
      ).createShader(const Rect.fromLTWH(48, 176, 264, 42));
    canvas.drawOval(const Rect.fromLTWH(48, 176, 264, 42), rug);
    canvas.drawArc(
      const Rect.fromLTWH(88, 181, 184, 28),
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = accent.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    _drawFireplace(canvas);
    _drawAtriumSofa(canvas);
    _drawPottedPlant(canvas, const Offset(58, 186), 0.82, accent);
    _drawPottedPlant(canvas, const Offset(317, 190), 0.62, accent);

    final flame = Paint()
      ..color = const Color(0xFFFFB76B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    if (progress > 0.3) {
      canvas.drawCircle(
        const Offset(306, 149),
        20 + progress * 10,
        flame..color = flame.color.withValues(alpha: 0.16 * progress),
      );
    }

    _drawFrame(canvas, const Rect.fromLTWH(264, 56, 28, 38), 0.7);
    _drawFrame(canvas, const Rect.fromLTWH(74, 58, 24, 32), 0.5);
  }

  void _drawArchedWindow(
    Canvas canvas,
    Rect rect, {
    required bool starfield,
    required bool lit,
  }) {
    final arch = Path()
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

    if (lit) {
      canvas.drawPath(
        arch,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF233B5D),
              Color.lerp(const Color(0xFF101F33), glow, 0.14)!,
            ],
          ).createShader(rect),
      );
      if (starfield) {
        const stars = [
          Offset(160, 48),
          Offset(178, 30),
          Offset(198, 64),
          Offset(187, 92),
          Offset(163, 84),
          Offset(207, 40),
        ];
        for (final star in stars) {
          canvas.drawCircle(
            star,
            0.9,
            Paint()..color = Colors.white.withValues(alpha: 0.6),
          );
        }
        canvas.drawCircle(
          const Offset(195, 47),
          10,
          Paint()..color = const Color(0xFFF8E8BE).withValues(alpha: 0.8),
        );
        canvas.drawCircle(
          const Offset(195, 47),
          16,
          Paint()
            ..color = const Color(0xFFF8E8BE).withValues(alpha: 0.13)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
        );
      }
    } else {
      canvas.drawPath(arch, Paint()..color = const Color(0xFF0A1421));
    }

    canvas.drawPath(
      arch,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final muntin = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(rect.center.dx, rect.top + 20),
      Offset(rect.center.dx, rect.bottom),
      muntin,
    );
    canvas.drawLine(
      Offset(rect.left + 4, rect.top + rect.height * 0.48),
      Offset(rect.right - 4, rect.top + rect.height * 0.48),
      muntin,
    );
    canvas.drawLine(
      Offset(rect.left + 4, rect.top + rect.height * 0.72),
      Offset(rect.right - 4, rect.top + rect.height * 0.72),
      muntin,
    );
  }

  void _drawChandelier(Canvas canvas, Offset top) {
    final metal = Paint()
      ..color = const Color(0xFFCDB57A).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(top, top + const Offset(0, 34), metal);
    final ringRect = Rect.fromCenter(
      center: top + const Offset(0, 44),
      width: 66,
      height: 18,
    );
    canvas.drawOval(ringRect, metal);
    final armPaint = Paint()
      ..color = const Color(0xFFCDB57A).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final dx = -30.0 + i * 15;
      final end = top + Offset(dx * 1.25, 31 + (dx.abs() * 0.16));
      final path = Path()
        ..moveTo(top.dx, top.dy + 44)
        ..quadraticBezierTo(top.dx + dx * 0.4, top.dy + 36, end.dx, end.dy);
      canvas.drawPath(path, armPaint);
      final lit = (progress * 5).ceil() > i;
      if (lit) {
        canvas.drawCircle(
          end,
          7,
          Paint()
            ..color = const Color(0xFFFFD786).withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(end, 1.7, Paint()..color = const Color(0xFFFFE4A7));
      } else {
        canvas.drawCircle(end, 1.2, Paint()..color = const Color(0xFF8A8064));
      }
    }
    if (progress > 0.05) {
      canvas.drawCircle(
        top + const Offset(0, 50),
        50 + progress * 28,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.16 * progress),
                  accent.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(center: top + const Offset(0, 50), radius: 80),
              ),
      );
    }
  }

  void _drawFireplace(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(272, 104, 68, 64),
      Paint()..color = const Color(0xFF131B28),
    );
    canvas.drawRect(
      const Rect.fromLTWH(266, 100, 80, 8),
      Paint()
        ..color = Color.lerp(const Color(0xFF2A3444), accent, progress * 0.08)!,
    );
    final hearth = Path()
      ..moveTo(284, 166)
      ..lineTo(284, 134)
      ..arcTo(const Rect.fromLTWH(284, 118, 44, 34), math.pi, math.pi, false)
      ..lineTo(328, 166)
      ..close();
    canvas.drawPath(hearth, Paint()..color = const Color(0xFF070D13));
    if (progress > 0.28) {
      final intensity = ((progress - 0.28) / 0.72).clamp(0.25, 1.0);
      final fire = Path()
        ..moveTo(296, 161)
        ..quadraticBezierTo(291, 148, 303, 142)
        ..quadraticBezierTo(302, 151, 308, 153)
        ..quadraticBezierTo(310, 143, 320, 138)
        ..quadraticBezierTo(324, 153, 315, 163)
        ..close();
      canvas.drawPath(
        fire,
        Paint()..color = const Color(0xFFFFA24D).withValues(alpha: intensity),
      );
      canvas.drawCircle(
        const Offset(308, 154),
        22,
        Paint()
          ..color = const Color(0xFFFFB266).withValues(alpha: 0.18 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
    canvas.drawCircle(
      const Offset(270, 120),
      2,
      Paint()..color = accent.withValues(alpha: 0.38),
    );
    canvas.drawCircle(
      const Offset(342, 120),
      2,
      Paint()..color = accent.withValues(alpha: 0.38),
    );
  }

  void _drawAtriumSofa(Canvas canvas) {
    final fabric = Paint()
      ..color = Color.lerp(
        const Color(0xFF27384A),
        const Color(0xFF40566B),
        progress * 0.35,
      )!;
    final fabricLight = Paint()
      ..color = const Color(0xFF4B6174).withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(32, 146, 92, 34),
        const Radius.circular(9),
      ),
      fabric,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, 132, 100, 28),
        const Radius.circular(8),
      ),
      fabric,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 139, 12, 37),
        const Radius.circular(6),
      ),
      fabricLight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(118, 139, 12, 37),
        const Radius.circular(6),
      ),
      fabricLight,
    );
    canvas.drawLine(
      const Offset(43, 178),
      const Offset(38, 188),
      Paint()
        ..color = const Color(0xFF0B1018)
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      const Offset(114, 178),
      const Offset(119, 188),
      Paint()
        ..color = const Color(0xFF0B1018)
        ..strokeWidth = 2.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 137, 20, 17),
        const Radius.circular(5),
      ),
      Paint()..color = accent.withValues(alpha: 0.2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(88, 137, 20, 17),
        const Radius.circular(5),
      ),
      Paint()..color = HavenColors.rose.withValues(alpha: 0.16),
    );
  }

  void _drawFrame(Canvas canvas, Rect rect, double lit) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF1D293A),
    );
    canvas.drawRect(
      rect.deflate(3),
      Paint()
        ..color = Color.lerp(
          const Color(0xFF101A27),
          accent.withValues(alpha: 0.45),
          progress * lit,
        )!,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintLibrary(Canvas canvas) {
    final window = Rect.fromLTWH(147, 16, 66, 118);
    _drawArchedWindow(canvas, window, starfield: true, lit: true);
    _drawBookshelf(canvas, const Rect.fromLTWH(14, 26, 104, 140), 0);
    _drawBookshelf(canvas, const Rect.fromLTWH(242, 26, 104, 140), 1);

    final ladderPaint = Paint()
      ..color = const Color(0xFF5D4A33)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(96, 54), const Offset(124, 166), ladderPaint);
    canvas.drawLine(const Offset(113, 54), const Offset(138, 166), ladderPaint);
    for (var i = 0; i < 5; i++) {
      final y = 74 + i * 18.0;
      canvas.drawLine(
        Offset(99 + i * 3.2, y),
        Offset(115 + i * 3.2, y),
        ladderPaint..strokeWidth = 1.2,
      );
    }

    final rug = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.11 + progress * 0.07),
          accent.withValues(alpha: 0.01),
        ],
      ).createShader(const Rect.fromLTWH(42, 172, 276, 46));
    canvas.drawOval(const Rect.fromLTWH(42, 172, 276, 46), rug);

    final deskTop = Paint()
      ..color = const Color(0xFF2A2630)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(118, 158), const Offset(242, 158), deskTop);
    canvas.drawLine(
      const Offset(128, 158),
      const Offset(125, 185),
      deskTop..strokeWidth = 2.5,
    );
    canvas.drawLine(const Offset(232, 158), const Offset(235, 185), deskTop);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(158, 146, 44, 12),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFD8C9A8).withValues(alpha: 0.72),
    );
    canvas.drawLine(
      const Offset(180, 146),
      const Offset(180, 158),
      Paint()
        ..color = const Color(0xFF9C8A6C)
        ..strokeWidth = 0.8,
    );

    _drawDeskLamp(canvas, const Offset(218, 158));
    _drawReadingChair(canvas);

    if (progress > 0.65) {
      _drawBookStack(canvas, const Offset(62, 179));
    }
    if (progress > 0.85) {
      _drawBookStack(canvas, const Offset(292, 181));
    }

    canvas.drawCircle(
      const Offset(118, 158),
      2,
      Paint()..color = accent.withValues(alpha: 0.4),
    );
  }

  void _drawBookshelf(Canvas canvas, Rect rect, int seed) {
    canvas.drawRect(rect, Paint()..color = const Color(0xFF141A25));
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final shelfPaint = Paint()
      ..color = const Color(0xFF332A25)
      ..strokeWidth = 2.5;
    final colors = [
      accent,
      HavenColors.rose,
      HavenColors.gold,
      HavenColors.sky,
      HavenColors.mint,
      HavenColors.lilac,
    ];
    var bookIndex = 0;
    for (var row = 0; row < 4; row++) {
      final shelfY = rect.top + 30 + row * 32;
      canvas.drawLine(
        Offset(rect.left, shelfY),
        Offset(rect.right, shelfY),
        shelfPaint,
      );
      var x = rect.left + 6;
      for (var book = 0; book < 9; book++) {
        final width = 4.0 + ((seed + row + book) % 3) * 2;
        final height = 18.0 + ((seed + book * 2 + row) % 4) * 2;
        final visible = progress > ((bookIndex % 20) / 25);
        canvas.drawRect(
          Rect.fromLTWH(x, shelfY - height, width, height),
          Paint()
            ..color = visible
                ? colors[bookIndex % colors.length].withValues(alpha: 0.48)
                : const Color(0xFF28303B).withValues(alpha: 0.44),
        );
        x += width + 2.4;
        bookIndex++;
      }
    }
    if (progress > 0.55) {
      canvas.drawRect(
        Rect.fromLTWH(rect.left + 12, rect.bottom - 24, 20, 24),
        Paint()..color = accent.withValues(alpha: 0.15),
      );
    }
  }

  void _drawDeskLamp(Canvas canvas, Offset base) {
    final metal = Paint()
      ..color = const Color(0xFFBAA268)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(base, base - const Offset(0, 22), metal);
    final shade = Path()
      ..moveTo(base.dx - 12, base.dy - 31)
      ..lineTo(base.dx + 12, base.dy - 31)
      ..lineTo(base.dx + 7, base.dy - 20)
      ..lineTo(base.dx - 7, base.dy - 20)
      ..close();
    canvas.drawPath(
      shade,
      Paint()
        ..color = Color.lerp(const Color(0xFF6B5D42), accent, progress * 0.25)!,
    );
    if (progress > 0.15) {
      final intensity = 0.15 + progress * 0.24;
      canvas.drawCircle(
        base - const Offset(0, 20),
        34,
        Paint()
          ..color = accent.withValues(alpha: intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawPath(
        Path()
          ..moveTo(base.dx - 30, base.dy + 2)
          ..lineTo(base.dx + 30, base.dy + 2)
          ..lineTo(base.dx + 50, 190)
          ..lineTo(base.dx - 50, 190)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withValues(alpha: 0.15 * progress),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(base.dx - 50, base.dy, 100, 50)),
      );
    }
  }

  void _drawReadingChair(Canvas canvas) {
    final chair = Paint()
      ..color = Color.lerp(
        const Color(0xFF2C3547),
        const Color(0xFF4A5369),
        progress * 0.4,
      )!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(35, 126, 52, 48),
        const Radius.circular(15),
      ),
      chair,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(42, 150, 50, 30),
        const Radius.circular(10),
      ),
      Paint()..color = chair.color.withValues(alpha: 0.82),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(31, 144, 10, 33),
        const Radius.circular(5),
      ),
      Paint()..color = chair.color.withValues(alpha: 0.76),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(87, 144, 10, 33),
        const Radius.circular(5),
      ),
      Paint()..color = chair.color.withValues(alpha: 0.76),
    );
    canvas.drawLine(
      const Offset(46, 178),
      const Offset(42, 189),
      Paint()
        ..color = const Color(0xFF0D1219)
        ..strokeWidth = 2.4,
    );
    canvas.drawLine(
      const Offset(88, 178),
      const Offset(92, 189),
      Paint()
        ..color = const Color(0xFF0D1219)
        ..strokeWidth = 2.4,
    );
  }

  void _drawBookStack(Canvas canvas, Offset base) {
    final colors = [accent, HavenColors.rose, HavenColors.gold];
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            base.dx - 12 + i * 1.5,
            base.dy - 8 - i * 7,
            24 - i * 2,
            6,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = colors[i].withValues(alpha: 0.55),
      );
    }
  }

  void _paintGreenhouse(Canvas canvas) {
    final glass = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF183449).withValues(alpha: 0.74),
          const Color(0xFF0A1820).withValues(alpha: 0.9),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 360, 166));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 360, 166), glass);

    final moonPaint = Paint()
      ..color = const Color(0xFFF2E6C4).withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawCircle(const Offset(294, 40), 17, moonPaint);
    canvas.drawCircle(
      const Offset(294, 40),
      32,
      Paint()
        ..color = const Color(0xFFF2E6C4).withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    final framePaint = Paint()
      ..color = const Color(0xFF586268).withValues(alpha: 0.42)
      ..strokeWidth = 1.1;
    for (var i = 0; i < 7; i++) {
      final x = 30.0 + i * 50;
      canvas.drawLine(Offset(x, 0), Offset(x, 166), framePaint);
    }
    for (var i = 0; i < 4; i++) {
      final y = 30.0 + i * 38;
      canvas.drawLine(Offset(0, y), Offset(360, y), framePaint);
    }
    final arch = Path()
      ..moveTo(16, 166)
      ..lineTo(16, 86)
      ..quadraticBezierTo(180, -30, 344, 86)
      ..lineTo(344, 166);
    canvas.drawPath(
      arch,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final floorTiles = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.8;
    for (var i = 0; i < 5; i++) {
      final y = 176.0 + i * 10;
      canvas.drawLine(Offset(0, y), Offset(360, y), floorTiles);
    }

    _drawFountain(canvas);
    _drawHangingVines(canvas);
    _drawPottedPlant(canvas, const Offset(58, 166), 1.2, accent);
    _drawPottedPlant(canvas, const Offset(73, 190), 0.74, HavenColors.rose);
    _drawPottedPlant(canvas, const Offset(304, 166), 1.12, accent);
    _drawPottedPlant(canvas, const Offset(326, 184), 0.65, HavenColors.lilac);
    _drawLargeLeaves(canvas, const Offset(264, 142), accent);

    final bloomColors = [
      accent,
      HavenColors.rose,
      HavenColors.gold,
      HavenColors.lilac,
    ];
    const blooms = [
      Offset(34, 151),
      Offset(92, 186),
      Offset(268, 157),
      Offset(334, 157),
      Offset(121, 159),
      Offset(247, 132),
      Offset(45, 184),
      Offset(313, 174),
    ];
    final activeBlooms = (progress * blooms.length).round();
    for (var i = 0; i < activeBlooms; i++) {
      final spot = blooms[i];
      final color = bloomColors[i % bloomColors.length];
      for (var petal = 0; petal < 5; petal++) {
        final angle = petal * math.pi * 2 / 5;
        canvas.drawCircle(
          spot + Offset(math.cos(angle) * 3.2, math.sin(angle) * 3.2),
          2.1,
          Paint()..color = color.withValues(alpha: 0.82),
        );
      }
      canvas.drawCircle(spot, 1.2, Paint()..color = const Color(0xFFFFF2C5));
      if (progress > 0.7) {
        canvas.drawCircle(
          spot,
          7,
          Paint()
            ..color = color.withValues(alpha: 0.13)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }

    final fireflyCount = (progress * 9).round();
    const fireflies = [
      Offset(126, 84),
      Offset(238, 92),
      Offset(286, 112),
      Offset(72, 112),
      Offset(202, 124),
      Offset(156, 68),
      Offset(318, 62),
      Offset(96, 70),
      Offset(262, 71),
    ];
    for (var i = 0; i < fireflyCount; i++) {
      canvas.drawCircle(
        fireflies[i],
        4.5,
        Paint()
          ..color = HavenColors.gold.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        fireflies[i],
        1.1,
        Paint()..color = const Color(0xFFFFEDB0).withValues(alpha: 0.85),
      );
    }
  }

  void _drawFountain(Canvas canvas) {
    final basin = Paint()
      ..color = const Color(0xFF24333A)
      ..style = PaintingStyle.fill;
    canvas.drawOval(const Rect.fromLTWH(130, 170, 100, 26), basin);
    canvas.drawOval(
      const Rect.fromLTWH(140, 173, 80, 18),
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.26 + progress * 0.16),
            const Color(0xFF132128),
          ],
        ).createShader(const Rect.fromLTWH(140, 173, 80, 18)),
    );
    canvas.drawRect(
      const Rect.fromLTWH(176, 150, 8, 26),
      Paint()..color = const Color(0xFF314148),
    );
    canvas.drawOval(
      const Rect.fromLTWH(166, 148, 28, 8),
      Paint()..color = const Color(0xFF2A393F),
    );
    if (progress > 0.2) {
      final water = Paint()
        ..color = accent.withValues(alpha: 0.16 + progress * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawArc(
        const Rect.fromLTWH(174, 130, 12, 26),
        math.pi,
        math.pi,
        false,
        water,
      );
      canvas.drawArc(
        const Rect.fromLTWH(181, 128, 12, 30),
        math.pi,
        math.pi,
        false,
        water,
      );
      canvas.drawCircle(
        const Offset(180, 140),
        16,
        Paint()
          ..color = accent.withValues(alpha: 0.09)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  void _drawHangingVines(Canvas canvas) {
    final vine = Paint()
      ..color = const Color(0xFF2F604C).withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final leaf = Paint()
      ..color = const Color(0xFF3C7A5D).withValues(alpha: 0.58);
    for (var i = 0; i < 4; i++) {
      final start = 48.0 + i * 70;
      final length = 36.0 + ((i * 17) % 34) + progress * 12;
      final path = Path()
        ..moveTo(start, 0)
        ..quadraticBezierTo(start - 8, length * 0.4, start + 2, length)
        ..quadraticBezierTo(start + 12, length * 1.3, start + 5, length * 1.5);
      canvas.drawPath(path, vine);
      for (var leafIndex = 1; leafIndex <= 3; leafIndex++) {
        final t = leafIndex / 3;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(
              start + math.sin(t * math.pi * 2 + i) * 7,
              length * t,
            ),
            width: 9,
            height: 4.5,
          ),
          leaf,
        );
      }
    }
  }

  void _drawLargeLeaves(Canvas canvas, Offset base, Color color) {
    final leafPaint = Paint()..color = color.withValues(alpha: 0.28);
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.35;
      final tip = base + Offset(math.cos(angle) * 45, math.sin(angle) * 55);
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + (tip.dx - base.dx) * 0.2 - 10,
          base.dy + (tip.dy - base.dy) * 0.5,
          tip.dx,
          tip.dy,
        )
        ..quadraticBezierTo(
          base.dx + (tip.dx - base.dx) * 0.7 + 12,
          base.dy + (tip.dy - base.dy) * 0.6,
          base.dx,
          base.dy,
        )
        ..close();
      canvas.drawPath(path, leafPaint);
    }
  }

  void _paintObservatory(Canvas canvas) {
    final slit = Path()
      ..moveTo(148, 156)
      ..lineTo(148, 66)
      ..quadraticBezierTo(180, 4, 212, 66)
      ..lineTo(212, 156)
      ..close();
    canvas.drawPath(
      slit,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1B36), Color(0xFF050A14)],
        ).createShader(const Rect.fromLTWH(148, 0, 64, 156)),
    );
    canvas.drawPath(
      slit,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.11)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const stars = [
      Offset(166, 44),
      Offset(194, 55),
      Offset(178, 78),
      Offset(203, 94),
      Offset(160, 104),
      Offset(188, 122),
      Offset(172, 138),
      Offset(200, 28),
    ];
    for (var i = 0; i < stars.length; i++) {
      final reveal = progress > i / (stars.length + 2);
      canvas.drawCircle(
        stars[i],
        reveal ? 1.3 : 0.7,
        Paint()
          ..color = (reveal ? glow : Colors.white).withValues(
            alpha: reveal ? 0.85 : 0.2,
          ),
      );
    }
    canvas.drawCircle(
      const Offset(188, 78),
      22,
      Paint()
        ..color = accent.withValues(alpha: 0.07 + progress * 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final domeLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 3; i++) {
      final inset = 20.0 + i * 12;
      canvas.drawArc(
        Rect.fromLTWH(inset, 16, 360 - inset * 2, 230),
        math.pi,
        math.pi,
        false,
        domeLine,
      );
    }

    final mosaic = Paint()
      ..color = accent.withValues(alpha: 0.1 + progress * 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(const Rect.fromLTWH(62, 166, 236, 44), mosaic);
    canvas.drawOval(const Rect.fromLTWH(100, 174, 160, 30), mosaic);
    canvas.drawLine(const Offset(180, 166), const Offset(180, 210), mosaic);

    _drawDeskLampChart(canvas);
    _drawTelescope(canvas);

    final brassPaint = Paint()
      ..color = const Color(0xFFB9975B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(34, 96),
      const Offset(34, 166),
      Paint()
        ..color = const Color(0xFF3A3023)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      const Offset(34, 96),
      18,
      Paint()..color = const Color(0xFF25313F),
    );
    canvas.drawArc(
      const Rect.fromLTWH(17, 79, 34, 34),
      -math.pi * 0.8,
      math.pi * 1.6,
      false,
      brassPaint,
    );
    canvas.drawLine(const Offset(20, 108), const Offset(48, 108), brassPaint);
    if (progress > 0.4) {
      canvas.drawCircle(
        const Offset(34, 96),
        28,
        Paint()
          ..color = accent.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }
  }

  void _drawDeskLampChart(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(258, 140, 72, 30),
      Paint()..color = const Color(0xFF1D2533),
    );
    canvas.drawLine(
      const Offset(264, 170),
      const Offset(260, 188),
      Paint()
        ..color = const Color(0xFF0C1119)
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      const Offset(322, 170),
      const Offset(326, 188),
      Paint()
        ..color = const Color(0xFF0C1119)
        ..strokeWidth = 2.5,
    );
    final paper = Rect.fromLTWH(270, 144, 48, 20);
    canvas.drawRect(
      paper,
      Paint()..color = const Color(0xFFC8B992).withValues(alpha: 0.32),
    );
    final chart = Paint()
      ..color = accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final points = [
      const Offset(277, 158),
      const Offset(288, 149),
      const Offset(296, 155),
      const Offset(307, 148),
    ];
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], chart);
    }
    for (final point in points) {
      canvas.drawCircle(point, 1.2, Paint()..color = accent);
    }
    if (progress > 0.5) {
      final candleBase = const Offset(269, 141);
      canvas.drawRect(
        Rect.fromLTWH(candleBase.dx - 1.5, candleBase.dy, 3, 9),
        Paint()..color = const Color(0xFFD8C9A8),
      );
      canvas.drawCircle(
        candleBase + const Offset(0, -2),
        3,
        Paint()
          ..color = HavenColors.gold.withValues(alpha: 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  void _drawTelescope(Canvas canvas) {
    final brass = Paint()
      ..color = const Color(0xFF9A7A4A)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(166, 206), const Offset(180, 170), brass);
    canvas.drawLine(const Offset(202, 207), const Offset(188, 170), brass);
    canvas.drawLine(const Offset(222, 201), const Offset(192, 168), brass);
    canvas.drawCircle(
      const Offset(187, 168),
      7,
      Paint()..color = const Color(0xFF6E5836),
    );

    final tube = Paint()
      ..color = const Color(0xFFB08B54)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(168, 158), const Offset(266, 78), tube);
    final highlight = Paint()
      ..color = const Color(0xFFE0C28C).withValues(alpha: 0.3)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(165, 154), const Offset(263, 74), highlight);
    final tubeDark = Paint()
      ..color = const Color(0xFF533F27)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(160, 165), const Offset(173, 154), tubeDark);
    final lensCenter = const Offset(268, 76);
    canvas.drawCircle(lensCenter, 9, Paint()..color = const Color(0xFF2A3542));
    canvas.drawCircle(
      lensCenter,
      9,
      Paint()
        ..color = const Color(0xFFD8BA81)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    if (progress > 0.25) {
      canvas.drawCircle(
        lensCenter,
        20 + progress * 12,
        Paint()
          ..color = accent.withValues(alpha: 0.13 + progress * 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(
        lensCenter,
        3.5,
        Paint()..color = glow.withValues(alpha: 0.7),
      );
      final beam = Path()
        ..moveTo(lensCenter.dx, lensCenter.dy)
        ..lineTo(354, 44)
        ..lineTo(360, 110)
        ..close();
      canvas.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accent.withValues(alpha: 0.09),
              accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(lensCenter.dx, 44, 100, 70)),
      );
    }
    final ring = Paint()
      ..color = const Color(0xFF6E5836)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(221, 115), width: 22, height: 10),
      ring,
    );
  }

  void _paintClocktower(Canvas canvas) {
    _drawArchedWindow(
      canvas,
      const Rect.fromLTWH(20, 22, 58, 108),
      starfield: true,
      lit: true,
    );
    _drawArchedWindow(
      canvas,
      const Rect.fromLTWH(282, 22, 58, 108),
      starfield: true,
      lit: true,
    );

    _drawGear(canvas, const Offset(90, 144), 22, 9, accent);
    _drawGear(canvas, const Offset(268, 138), 30, 12, HavenColors.gold);
    _drawGear(canvas, const Offset(232, 172), 14, 7, accent);
    _drawGear(canvas, const Offset(128, 172), 11, 6, HavenColors.gold);

    const center = Offset(180, 78);
    canvas.drawCircle(
      center,
      70,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(const Color(0xFF1A2233), accent, 0.16)!,
            const Color(0xFF080E18),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 70)),
    );
    canvas.drawCircle(
      center,
      70,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      center,
      61,
      Paint()
        ..color = accent.withValues(alpha: 0.32 + progress * 0.26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + i * math.pi / 6;
      final outer = 55.0;
      final inner = i % 3 == 0 ? 45.0 : 50.0;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        tickPaint,
      );
    }

    final minuteAngle = -math.pi / 2 + progress * math.pi * 4;
    final hourAngle = -math.pi / 2 + progress * math.pi;
    final handPaint = Paint()
      ..color = glow.withValues(alpha: 0.8)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      center + Offset(math.cos(minuteAngle), math.sin(minuteAngle)) * 43,
      handPaint,
    );
    canvas.drawLine(
      center,
      center + Offset(math.cos(hourAngle), math.sin(hourAngle)) * 29,
      handPaint..strokeWidth = 3.4,
    );
    canvas.drawCircle(center, 4, Paint()..color = accent);

    final swing = math.sin(progress * math.pi * 2) * 24;
    final pendulum = Paint()
      ..color = HavenColors.gold.withValues(alpha: 0.6)
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(180, 148), Offset(180 + swing, 208), pendulum);
    canvas.drawCircle(
      Offset(180 + swing, 209),
      7,
      Paint()..color = HavenColors.gold.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
      Offset(180 + swing, 209),
      15,
      Paint()
        ..color = HavenColors.gold.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final rug = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.1 + progress * 0.08),
          accent.withValues(alpha: 0),
        ],
      ).createShader(const Rect.fromLTWH(52, 172, 256, 46));
    canvas.drawOval(const Rect.fromLTWH(52, 172, 256, 46), rug);
  }

  void _drawGear(
    Canvas canvas,
    Offset center,
    double radius,
    int teeth,
    Color color,
  ) {
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF111A27));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(
      center,
      radius * 0.34,
      Paint()..color = color.withValues(alpha: 0.2),
    );
    final toothPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < teeth; i++) {
      final angle = i * math.pi * 2 / teeth;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius * 0.94),
        center + direction * (radius * 1.18),
        toothPaint,
      );
    }
  }

  void _paintSanctum(Canvas canvas) {
    _drawArchedWindow(
      canvas,
      const Rect.fromLTWH(138, 8, 84, 128),
      starfield: true,
      lit: true,
    );

    for (final x in [50.0, 286.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 42, 24, 128),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF141C2A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 5, 38, 34, 8),
          const Radius.circular(3),
        ),
        Paint()..color = accent.withValues(alpha: 0.22),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 5, 162, 34, 10),
          const Radius.circular(3),
        ),
        Paint()..color = accent.withValues(alpha: 0.16),
      );
      final banner = Path()
        ..moveTo(x + 2, 66)
        ..lineTo(x + 22, 66)
        ..lineTo(x + 22, 128)
        ..lineTo(x + 12, 118)
        ..lineTo(x + 2, 128)
        ..close();
      canvas.drawPath(
        banner,
        Paint()..color = accent.withValues(alpha: 0.1 + progress * 0.08),
      );
      canvas.drawCircle(
        Offset(x + 12, 54),
        3,
        Paint()..color = glow.withValues(alpha: 0.6),
      );
    }

    const orb = Offset(180, 94);
    final orbRadius = 12.0 + progress * 8;
    canvas.drawCircle(
      orb,
      orbRadius * 3.4,
      Paint()
        ..color = accent.withValues(alpha: 0.08 + progress * 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(
      orb,
      orbRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            glow,
            accent.withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromCircle(center: orb, radius: orbRadius)),
    );
    for (var i = 0; i < 3; i++) {
      final ringRadius = orbRadius + 9 + i * 8;
      canvas.drawOval(
        Rect.fromCenter(
          center: orb,
          width: ringRadius * 2,
          height: ringRadius * 0.7,
        ),
        Paint()
          ..color = accent.withValues(alpha: 0.24 - i * 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }

    final altarPaint = Paint()..color = const Color(0xFF1A2231);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(132, 168, 96, 16),
        const Radius.circular(5),
      ),
      altarPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(118, 182, 124, 12),
        const Radius.circular(5),
      ),
      altarPaint..color = const Color(0xFF141B28),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(150, 156, 60, 12),
        const Radius.circular(4),
      ),
      Paint()..color = accent.withValues(alpha: 0.18),
    );

    final ritual = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.22 + progress * 0.12),
          accent.withValues(alpha: 0),
        ],
      ).createShader(const Rect.fromLTWH(88, 176, 184, 40));
    canvas.drawOval(const Rect.fromLTWH(88, 176, 184, 40), ritual);
    canvas.drawOval(
      const Rect.fromLTWH(112, 182, 136, 28),
      Paint()
        ..color = glow.withValues(alpha: 0.24 + progress * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    for (final spot in const [Offset(110, 164), Offset(250, 164)]) {
      canvas.drawRect(
        Rect.fromLTWH(spot.dx - 2, spot.dy - 14, 4, 14),
        Paint()..color = const Color(0xFFD9C9A4),
      );
      canvas.drawCircle(
        Offset(spot.dx, spot.dy - 18),
        3,
        Paint()..color = const Color(0xFFFFE9B0),
      );
      canvas.drawCircle(
        Offset(spot.dx, spot.dy - 18),
        9,
        Paint()
          ..color = HavenColors.gold.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _paintAtmosphere(Canvas canvas) {
    final dustCount = (progress * 16).round();
    for (var i = 0; i < dustCount; i++) {
      final x = 18.0 + ((i * 73) % 326);
      final y = 18.0 + ((i * 41) % 140);
      final radius = 0.5 + ((i * 7) % 10) / 11;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = glow.withValues(alpha: 0.22 + (i % 4) * 0.06),
      );
    }

    final shade = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Color(0x3304090F)],
        stops: [0.64, 1],
      ).createShader(const Rect.fromLTWH(0, 0, 360, 220));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 360, 220), shade);
  }

  void _drawPottedPlant(Canvas canvas, Offset base, double scale, Color color) {
    final potWidth = 22 * scale;
    final potHeight = 18 * scale;
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - potWidth * 0.42, base.dy - potHeight)
        ..lineTo(base.dx + potWidth * 0.42, base.dy - potHeight)
        ..lineTo(base.dx + potWidth * 0.3, base.dy)
        ..lineTo(base.dx - potWidth * 0.3, base.dy)
        ..close(),
      Paint()..color = const Color(0xFF3B3027),
    );
    final leafPaint = Paint()..color = color.withValues(alpha: 0.5);
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.42;
      final tip =
          base +
          Offset(
            math.cos(angle) * 26 * scale,
            -potHeight - 14 * scale + math.sin(angle) * 24 * scale,
          );
      final path = Path()
        ..moveTo(base.dx, base.dy - potHeight)
        ..quadraticBezierTo(
          base.dx + math.cos(angle) * 16 * scale,
          base.dy - potHeight - 24 * scale,
          tip.dx,
          tip.dy,
        )
        ..quadraticBezierTo(
          base.dx + math.cos(angle) * 7 * scale,
          base.dy - potHeight - 8 * scale,
          base.dx,
          base.dy - potHeight,
        )
        ..close();
      canvas.drawPath(path, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoomPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.room != room;
  }
}
