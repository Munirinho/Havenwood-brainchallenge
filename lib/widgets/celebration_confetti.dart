import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

class CelebrationConfetti extends StatefulWidget {
  final Color accent;
  final int count;

  const CelebrationConfetti({
    super.key,
    this.accent = HavenColors.gold,
    this.count = 70,
  });

  @override
  State<CelebrationConfetti> createState() => _CelebrationConfettiState();
}

class _CelebrationConfettiState extends State<CelebrationConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiPiece> _pieces;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    final colors = [
      widget.accent,
      HavenColors.mint,
      HavenColors.lilac,
      HavenColors.cream,
      HavenColors.rose,
    ];
    _pieces = List.generate(widget.count, (index) {
      return _ConfettiPiece(
        angle: -math.pi * 0.95 + random.nextDouble() * math.pi * 0.9,
        speed: 0.3 + random.nextDouble() * 0.9,
        spin: (random.nextDouble() - 0.5) * 14,
        size: 3 + random.nextDouble() * 6,
        color: colors[random.nextInt(colors.length)],
        striped: random.nextBool(),
        delay: random.nextDouble() * 0.16,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ConfettiPainter(
                pieces: _pieces,
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  final double angle;
  final double speed;
  final double spin;
  final double size;
  final Color color;
  final bool striped;
  final double delay;

  const _ConfettiPiece({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.size,
    required this.color,
    required this.striped,
    required this.delay,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, size.height * 0.32);
    for (final piece in pieces) {
      final t = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final travel = t * piece.speed * size.height * 0.9;
      final dx = math.cos(piece.angle) * travel;
      final dy = math.sin(piece.angle) * travel + t * t * size.height * 0.5;
      final position = origin + Offset(dx, dy);
      final opacity = t < 0.75 ? 1.0 : (1 - (t - 0.75) / 0.25).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(piece.spin * t);
      final paint = Paint()
        ..color = piece.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      if (piece.striped) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.46,
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, piece.size * 0.37, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
