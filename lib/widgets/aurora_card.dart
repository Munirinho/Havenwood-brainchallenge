import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

class AuroraCard extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final double radius;
  final bool glow;

  const AuroraCard({
    super.key,
    required this.child,
    required this.colors,
    this.radius = 24,
    this.glow = false,
  });

  @override
  State<AuroraCard> createState() => _AuroraCardState();
}

class _AuroraCardState extends State<AuroraCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.colors.first;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.glow
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.16),
                  blurRadius: 38,
                  spreadRadius: -8,
                ),
              ]
            : null,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _AuroraBorderPainter(
              progress: _controller.value,
              colors: widget.colors,
              radius: widget.radius,
            ),
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.all(1.4),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: HavenColors.night,
            borderRadius: BorderRadius.circular(widget.radius - 1.4),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _AuroraBorderPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double radius;

  _AuroraBorderPainter({
    required this.progress,
    required this.colors,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = SweepGradient(
      colors: [...colors, colors.first],
      transform: GradientRotation(progress * math.pi * 2),
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.8), Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AuroraBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.radius != radius;
  }
}
