import 'package:flutter/material.dart';

import '../theme/haven_theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final double radius;
  final double borderOpacity;
  final bool glow;
  final Color? glowColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.tint,
    this.radius = 26,
    this.borderOpacity = 0.1,
    this.glow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: panelGradient(tint: tint),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withValues(alpha: borderOpacity),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          if (glow)
            BoxShadow(
              color: (glowColor ?? HavenColors.mint).withValues(alpha: 0.12),
              blurRadius: 48,
              spreadRadius: -4,
            ),
        ],
      ),
      child: child,
    );
  }
}

class HavenButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final IconData? trailing;
  final VoidCallback? onPressed;
  final Color color;
  final bool expand;
  final double height;
  final bool muted;

  const HavenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing = Icons.arrow_forward_rounded,
    this.color = HavenColors.mint,
    this.expand = false,
    this.height = 54,
    this.muted = false,
  });

  @override
  State<HavenButton> createState() => _HavenButtonState();
}

class _HavenButtonState extends State<HavenButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final background = widget.muted
        ? Colors.white.withValues(alpha: 0.07)
        : widget.color;
    final foreground = widget.muted ? HavenColors.cream : HavenColors.ink;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 19, color: foreground),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: foreground, fontSize: 13.5),
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 10),
            Icon(widget.trailing, size: 18, color: foreground),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.expand ? double.infinity : null,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                if (enabled && !widget.muted)
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.24),
                    blurRadius: 26,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: widget.muted
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.lerp(widget.color, Colors.white, 0.24)!,
                              widget.color,
                            ],
                          ),
                    color: widget.muted ? background : null,
                    border: widget.muted
                        ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                        : null,
                  ),
                  child: InkWell(
                    onTap: widget.onPressed,
                    onHighlightChanged: (value) {
                      if (_pressed != value) setState(() => _pressed = value);
                    },
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HavenIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const HavenIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Icon(
            icon,
            size: size * 0.44,
            color: color ?? HavenColors.cream,
          ),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class StarRow extends StatelessWidget {
  final int earned;
  final double size;
  final bool showEmpty;

  const StarRow({
    super.key,
    required this.earned,
    this.size = 14,
    this.showEmpty = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final active = index < earned;
        if (!active && !showEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(right: index == 2 ? 0 : size * 0.16),
          child: Icon(
            active ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: active
                ? HavenColors.gold
                : Colors.white.withValues(alpha: 0.16),
          ),
        );
      }),
    );
  }
}

class PillTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool dense;

  const PillTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 10 : 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: dense ? 8 : 9,
              letterSpacing: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionEyebrow extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  const SectionEyebrow({
    super.key,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: HavenColors.mist.withValues(alpha: 0.8)),
        ),
        const Spacer(),
        if (trailing != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              trailing!,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: HavenColors.gold),
            ),
          ),
      ],
    );
  }
}

class HavenProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const HavenProgressBar({
    super.key,
    required this.value,
    this.color = HavenColors.mint,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Colors.white.withValues(alpha: 0.075)),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, animated, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animated,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color.lerp(color, Colors.white, 0.26)!, color],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.07));
  }
}
