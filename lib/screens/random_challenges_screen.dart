import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/models.dart';
import '../game/random_challenges.dart';
import '../theme/haven_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/aurora_card.dart';
import '../widgets/haven_widgets.dart';
import 'puzzle_launcher.dart';

class RandomChallengesScreen extends StatefulWidget {
  final GameController controller;

  const RandomChallengesScreen({super.key, required this.controller});

  @override
  State<RandomChallengesScreen> createState() => _RandomChallengesScreenState();
}

class _RandomChallengesScreenState extends State<RandomChallengesScreen> {
  late List<GeneratedChallenge> _trials;
  PuzzleKind? _filter;
  int _deals = 0;
  int _trialsPlayed = 0;

  @override
  void initState() {
    super.initState();
    _trials = _createSet();
  }

  List<GeneratedChallenge> _createSet() {
    _deals++;
    final seed = DateTime.now().microsecondsSinceEpoch ^ (_deals * 0x9E3779B9);
    return RandomChallengeFactory(seed: seed).generate(count: 9);
  }

  List<GeneratedChallenge> get _visible {
    final filter = _filter;
    if (filter == null) return _trials;
    return _trials.where((trial) => trial.puzzle.kind == filter).toList();
  }

  Color get _accent {
    final visible = _visible;
    if (visible.isEmpty) return HavenColors.gold;
    return visible.first.accent;
  }

  void _deal() {
    setState(() => _trials = _createSet());
  }

  Future<void> _play(GeneratedChallenge trial) async {
    await openPuzzle(
      context,
      puzzle: trial.puzzle,
      controller: widget.controller,
    );
    if (!mounted) return;
    setState(() => _trialsPlayed++);
  }

  Future<void> _surprise() async {
    final visible = _visible;
    if (visible.isEmpty) return;
    final trial = visible[math.Random().nextInt(visible.length)];
    await _play(trial);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      body: HavenBackdrop(
        accent: _accent,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 18),
                    _buildHero(context),
                    const SizedBox(height: 22),
                    _buildFilters(context),
                    const SizedBox(height: 22),
                    _buildListHeader(context, visible.length),
                    const SizedBox(height: 11),
                    ...visible.asMap().entries.map((entry) {
                      return _Reveal(
                        key: ValueKey(entry.value.puzzle.id),
                        duration: 500 + entry.key * 70,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ChallengeCard(
                            trial: entry.value,
                            onTap: () => _play(entry.value),
                          ),
                        ),
                      );
                    }),
                    if (visible.isEmpty)
                      _EmptyTrials(color: _accent, onDeal: _deal),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Chance trials are just for the joy of thinking.\nYour manor progress is safe.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.6,
                          color: HavenColors.mist.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
                'CHANCE TRIALS',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: _accent, letterSpacing: 1.8),
              ),
              const SizedBox(height: 3),
              Text(
                'Random brain games',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        PillTag(
          label: _trialsPlayed == 0
              ? '${_trials.length} trials'
              : '$_trialsPlayed played',
          icon: Icons.casino_rounded,
          color: _accent,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return AuroraCard(
      radius: 30,
      glow: true,
      colors: const [
        HavenColors.gold,
        HavenColors.lilac,
        HavenColors.mint,
        HavenColors.sky,
      ],
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(child: _HeroAura(colors: _themeColors)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [HavenColors.gold, HavenColors.lilac],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: HavenColors.gold.withValues(alpha: 0.32),
                            blurRadius: 26,
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.casino_rounded,
                        color: HavenColors.ink,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Six moods. Six soundscapes.\nEndless variations.',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontSize: 21, height: 1.15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Shuffle a fresh set of memory, logic, weaving and deduction trials, each with its own relaxing soundtrack.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: HavenColors.mist.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: HavenButton(
                        label: 'Surprise me',
                        icon: Icons.auto_awesome_rounded,
                        trailing: null,
                        height: 48,
                        color: _accent,
                        expand: true,
                        onPressed: _surprise,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HavenButton(
                        label: 'Deal new',
                        icon: Icons.refresh_rounded,
                        trailing: null,
                        height: 48,
                        muted: true,
                        expand: true,
                        onPressed: _deal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: challengeStyles.map((style) {
                    return _MoodDot(style: style);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.all_inclusive_rounded,
            color: _accent,
            selected: _filter == null,
            onTap: () => setState(() => _filter = null),
          ),
          ...PuzzleKind.values.map((kind) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: kind.shortLabel,
                icon: kind.icon,
                color: kind.accent,
                selected: _filter == kind,
                onTap: () => setState(() => _filter = kind),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'TRIALS FOR YOU',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: HavenColors.mist.withValues(alpha: 0.8)),
          ),
        ),
        Text(
          '$count READY',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: _accent, letterSpacing: 0.8),
        ),
      ],
    );
  }
}

const List<Color> _themeColors = [
  HavenColors.gold,
  HavenColors.lilac,
  HavenColors.mint,
  HavenColors.sky,
  HavenColors.rose,
];

class _ChallengeCard extends StatelessWidget {
  final GeneratedChallenge trial;
  final VoidCallback onTap;

  const _ChallengeCard({required this.trial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final puzzle = trial.puzzle;
    final style = trial.style;
    return AuroraCard(
      radius: 24,
      colors: style.gradient,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        style.accent.withValues(alpha: 0.28),
                        style.accent.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: style.accent.withValues(alpha: 0.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: style.accent.withValues(alpha: 0.14),
                        blurRadius: 20,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Icon(style.icon, color: style.accent, size: 25),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${puzzle.kind.shortLabel.toUpperCase()} · ${style.name.toUpperCase()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: style.accent,
                                    fontSize: 8,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ),
                          ...List.generate(3, (index) {
                            return Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(left: 2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index < puzzle.difficulty
                                    ? style.accent.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        puzzle.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        style.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HavenColors.mist.withValues(alpha: 0.62),
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Icon(
                            Icons.music_note_rounded,
                            size: 12,
                            color: style.accent,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              style.name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: style.accent,
                                    fontSize: 7.5,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'PLAY',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: style.accent,
                                  fontSize: 7.5,
                                  letterSpacing: 1,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.play_arrow_rounded, color: style.accent, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.34)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? color : HavenColors.mist),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? color : HavenColors.mist,
                fontSize: 8,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTrials extends StatelessWidget {
  final Color color;
  final VoidCallback onDeal;

  const _EmptyTrials({required this.color, required this.onDeal});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      tint: color,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Icon(Icons.casino_rounded, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            'No trials in this mood yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          HavenButton(
            label: 'Deal a fresh set',
            icon: Icons.refresh_rounded,
            trailing: null,
            color: color,
            onPressed: onDeal,
          ),
        ],
      ),
    );
  }
}

class _MoodDot extends StatelessWidget {
  final ChallengeStyle style;

  const _MoodDot({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: style.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: style.accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.accent,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            style.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: style.accent,
              fontSize: 7,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAura extends StatefulWidget {
  final List<Color> colors;

  const _HeroAura({required this.colors});

  @override
  State<_HeroAura> createState() => _HeroAuraState();
}

class _HeroAuraState extends State<_HeroAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _AuraPainter(
              time: _controller.value,
              colors: widget.colors,
            ),
          );
        },
      ),
    );
  }
}

class _AuraPainter extends CustomPainter {
  final double time;
  final List<Color> colors;

  _AuraPainter({required this.time, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final phase = time * math.pi * 2 + i * math.pi * 0.66;
      final center = Offset(
        size.width * (0.5 + math.sin(phase) * 0.34),
        size.height * (0.5 + math.cos(phase * 0.8) * 0.4),
      );
      final color = colors[i % colors.length];
      final radius = size.shortestSide * (0.42 + i * 0.08);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuraPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.colors != colors;
  }
}

class _Reveal extends StatelessWidget {
  final Widget child;
  final int duration;

  const _Reveal({super.key, required this.child, this.duration = 600});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
