import 'package:flutter/material.dart';

import '../../audio/soundtrack.dart';
import '../../game/models.dart';
import '../../theme/haven_theme.dart';
import '../../widgets/animated_backdrop.dart';
import '../../widgets/celebration_confetti.dart';
import '../../widgets/haven_widgets.dart';
import '../../widgets/soundtrack_toggle.dart';

class PuzzleShell extends StatefulWidget {
  final PuzzleDef puzzle;
  final Widget child;

  const PuzzleShell({super.key, required this.puzzle, required this.child});

  @override
  State<PuzzleShell> createState() => _PuzzleShellState();
}

class _PuzzleShellState extends State<PuzzleShell> {
  @override
  void initState() {
    super.initState();
    SoundtrackPlayer.instance.playFor(widget.puzzle);
  }

  @override
  void dispose() {
    SoundtrackPlayer.instance.leavePuzzle(widget.puzzle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = widget.puzzle;
    return Scaffold(
      body: HavenBackdrop(
        accent: puzzle.accent,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                child: Row(
                  children: [
                    HavenIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            puzzle.kind.label.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: puzzle.accent,
                                  letterSpacing: 1.5,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            puzzle.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SoundtrackToggleButton(color: puzzle.accent),
                    const SizedBox(width: 8),
                    HavenIconButton(
                      icon: Icons.help_outline_rounded,
                      onPressed: () => showPuzzleHelp(context, puzzle),
                    ),
                  ],
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}

class PuzzleStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const PuzzleStatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8,
                    color: HavenColors.dim,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(fontSize: 11.5, color: HavenColors.cream),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showPuzzleHelp(BuildContext context, PuzzleDef puzzle) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'How to play',
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
              tint: puzzle.accent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlowIcon(icon: puzzle.kind.icon, color: puzzle.accent),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              puzzle.kind.label.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: puzzle.accent),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'How to play',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ...puzzle.kind.howTo.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: puzzle.accent.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: puzzle.accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: puzzle.accent,
                                      fontSize: 9,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  HavenButton(
                    label: 'I understand',
                    icon: Icons.check_rounded,
                    trailing: null,
                    color: puzzle.accent,
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> celebratePuzzle(
  BuildContext context, {
  required PuzzleDef puzzle,
  required int stars,
  required int totalStars,
  required bool roomComplete,
  required bool allComplete,
}) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Challenge complete',
    barrierColor: Colors.black.withValues(alpha: 0.78),
    transitionDuration: const Duration(milliseconds: 420),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CelebrationConfetti(accent: puzzle.accent),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: _CompletionCard(
                    puzzle: puzzle,
                    stars: stars,
                    totalStars: totalStars,
                    roomComplete: roomComplete,
                    allComplete: allComplete,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _CompletionCard extends StatelessWidget {
  final PuzzleDef puzzle;
  final int stars;
  final int totalStars;
  final bool roomComplete;
  final bool allComplete;

  const _CompletionCard({
    required this.puzzle,
    required this.stars,
    required this.totalStars,
    required this.roomComplete,
    required this.allComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isRandom = puzzle.isRandom;
    final title = isRandom
        ? 'Chance Trial Complete'
        : allComplete
        ? 'Havenwood Awakens'
        : roomComplete
        ? 'Chamber Restored'
        : 'Challenge Complete';
    final overline = isRandom
        ? 'A WANDERING CHALLENGE'
        : allComplete
        ? 'THE MIND IN BLOOM'
        : roomComplete
        ? 'A ROOM REMEMBERS'
        : 'LIGHT RETURNS';

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
      tint: puzzle.accent,
      glow: true,
      glowColor: puzzle.accent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GlowIcon(icon: puzzle.kind.icon, color: puzzle.accent, size: 64),
          const SizedBox(height: 20),
          Text(
            overline,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: puzzle.accent, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall
                ?.copyWith(fontSize: 36),
          ),
          const SizedBox(height: 8),
          Text(
            puzzle.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: HavenColors.mist),
          ),
          const SizedBox(height: 22),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final start = index * 0.17;
                  final local = ((value - start) / 0.55).clamp(0.0, 1.0);
                  final scale = Curves.easeOutBack.transform(local);
                  final active = index < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Opacity(
                      opacity: local,
                      child: Transform.scale(
                        scale: 0.3 + scale * 0.7,
                        child: Icon(
                          active
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 43,
                          color: active
                              ? HavenColors.gold
                              : Colors.white.withValues(alpha: 0.15),
                          shadows: active
                              ? [
                                  Shadow(
                                    color: HavenColors.gold.withValues(
                                      alpha: 0.45,
                                    ),
                                    blurRadius: 18,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            puzzle.kind.celebration,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.55, color: HavenColors.mist),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRandom ? Icons.auto_awesome_rounded : Icons.star_rounded,
                  color: isRandom ? puzzle.accent : HavenColors.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isRandom
                        ? 'Your manor progress is untouched'
                        : '$totalStars total stars',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: HavenColors.cream),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          HavenButton(
            label: isRandom
                ? 'Back to chance trials'
                : roomComplete
                ? 'See the restored chamber'
                : 'Continue',
            color: puzzle.accent,
            trailing: Icons.arrow_forward_rounded,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

Future<bool> showPuzzleFailure(
  BuildContext context, {
  required PuzzleDef puzzle,
  required String message,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Try again',
    barrierColor: Colors.black.withValues(alpha: 0.76),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: GlassPanel(
              padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
              tint: HavenColors.coral,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: HavenColors.coral.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HavenColors.coral.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.nights_stay_rounded,
                      color: HavenColors.coral,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'The light wavers',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  HavenButton(
                    label: 'Try again',
                    icon: Icons.refresh_rounded,
                    trailing: null,
                    color: HavenColors.coral,
                    expand: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  const SizedBox(height: 10),
                  HavenButton(
                    label: 'Leave for now',
                    muted: true,
                    expand: true,
                    trailing: null,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _GlowIcon({required this.icon, required this.color, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.07),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}
