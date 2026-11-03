import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

class HavenBackdrop extends StatefulWidget {
  final Widget child;
  final Color accent;
  final bool quiet;

  const HavenBackdrop({
    super.key,
    required this.child,
    this.accent = HavenColors.mint,
    this.quiet = false,
  });

  @override
  State<HavenBackdrop> createState() => _HavenBackdropState();
}

class _HavenBackdropState extends State<HavenBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Mote> _motes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    final random = math.Random(11);
    _motes = List.generate(
      widget.quiet ? 22 : 42,
      (_) => _Mote(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 0.5 + random.nextDouble() * 1.8,
        speed: 0.2 + random.nextDouble() * 0.8,
        phase: random.nextDouble() * math.pi * 2,
        drift: (random.nextDouble() - 0.5) * 0.06,
        warm: random.nextDouble() > 0.55,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BackdropPainter(
                    time: _controller.value,
                    accent: widget.accent,
                    motes: _motes,
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Mote {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double drift;
  final bool warm;

  const _Mote({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.drift,
    required this.warm,
  });
}

class _BackdropPainter extends CustomPainter {
  final double time;
  final Color accent;
  final List<_Mote> motes;

  _BackdropPainter({
    required this.time,
    required this.accent,
    required this.motes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF07101C), HavenColors.ink, Color(0xFF0A101C)],
        stops: [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    final tau = math.pi * 2;
    final glowOne = Offset(
      size.width * (0.16 + math.sin(time * tau) * 0.035),
      size.height * (0.18 + math.cos(time * tau * 0.7) * 0.03),
    );
    final glowTwo = Offset(
      size.width * (0.86 + math.cos(time * tau * 0.8) * 0.03),
      size.height * (0.7 + math.sin(time * tau * 0.6) * 0.04),
    );

    _drawGlow(canvas, glowOne, size.width * 0.7, accent.withValues(alpha: 0.1));
    _drawGlow(
      canvas,
      glowTwo,
      size.width * 0.8,
      HavenColors.lilac.withValues(alpha: 0.075),
    );
    _drawGlow(
      canvas,
      Offset(size.width * 0.56, size.height * 0.8),
      size.width * 0.55,
      HavenColors.gold.withValues(alpha: 0.035),
    );

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = LinearGradient(
        colors: [
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.11),
          HavenColors.lilac.withValues(alpha: 0),
        ],
      ).createShader(rect);
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * (0.3 + i * 0.17);
      path.moveTo(-20, y);
      path.cubicTo(
        size.width * 0.28,
        y - 70 + math.sin(time * tau + i) * 22,
        size.width * 0.67,
        y + 60,
        size.width + 30,
        y - 15,
      );
      canvas.drawPath(path, wavePaint);
    }

    for (final mote in motes) {
      final yy = (mote.y - time * mote.speed * 0.08) % 1.0;
      final xx = (mote.x + time * mote.drift) % 1.0;
      final twinkle =
          0.35 + (math.sin(time * tau * 1.4 + mote.phase) + 1) * 0.3;
      final color = mote.warm ? HavenColors.gold : accent;
      canvas.drawCircle(
        Offset(xx * size.width, yy * size.height),
        mote.radius,
        Paint()..color = color.withValues(alpha: twinkle * 0.5),
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.05,
        colors: [
          Colors.transparent,
          HavenColors.ink.withValues(alpha: 0.28),
          const Color(0xFF02050B).withValues(alpha: 0.82),
        ],
        stops: const [0.42, 0.74, 1],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
          .createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.accent != accent ||
        oldDelegate.motes != motes;
  }
}
