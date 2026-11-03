import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/game_controller.dart';
import '../../game/levels.dart';
import '../../game/models.dart';
import '../../theme/haven_theme.dart';
import 'puzzle_chrome.dart';

enum _EchoPhase { preparing, watching, input, waiting, failed }

class EchoPuzzleScreen extends StatefulWidget {
  final PuzzleDef puzzle;
  final GameController controller;

  const EchoPuzzleScreen({
    super.key,
    required this.puzzle,
    required this.controller,
  });

  @override
  State<EchoPuzzleScreen> createState() => _EchoPuzzleScreenState();
}

class _EchoPuzzleScreenState extends State<EchoPuzzleScreen> {
  late final EchoSpec _spec;
  final Random _random = Random();
  final List<int> _sequence = [];
  int _round = 0;
  int _inputIndex = 0;
  int _lives = 3;
  int _activePad = -1;
  int _wrongPad = -1;
  int _runToken = 0;
  bool _completing = false;
  _EchoPhase _phase = _EchoPhase.preparing;

  @override
  void initState() {
    super.initState();
    _spec = widget.puzzle.spec as EchoSpec;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _beginSession();
    });
  }

  @override
  void dispose() {
    _runToken++;
    super.dispose();
  }

  Future<void> _beginSession() async {
    final token = ++_runToken;
    _completing = false;
    setState(() {
      _round = 0;
      _inputIndex = 0;
      _lives = _spec.lives;
      _activePad = -1;
      _wrongPad = -1;
      _phase = _EchoPhase.preparing;
      _sequence
        ..clear()
        ..addAll(
          List.generate(
            _spec.baseLength,
            (_) => _random.nextInt(_spec.padCount),
          ),
        );
    });
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted || token != _runToken) return;
    await _playSequence(token);
  }

  Future<void> _playSequence(int token) async {
    setState(() {
      _phase = _EchoPhase.watching;
      _activePad = -1;
      _wrongPad = -1;
      _inputIndex = 0;
    });
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted || token != _runToken) return;

    for (final pad in _sequence) {
      if (!mounted || token != _runToken) return;
      setState(() => _activePad = pad);
      unawaited(HapticFeedback.selectionClick());
      unawaited(SystemSound.play(SystemSoundType.click));
      await Future<void>.delayed(const Duration(milliseconds: 390));
      if (!mounted || token != _runToken) return;
      setState(() => _activePad = -1);
      await Future<void>.delayed(const Duration(milliseconds: 140));
    }

    if (!mounted || token != _runToken) return;
    setState(() {
      _phase = _EchoPhase.input;
      _inputIndex = 0;
    });
  }

  Future<void> _handlePadTap(int pad) async {
    if (_phase != _EchoPhase.input) return;
    final token = _runToken;
    final expected = _sequence[_inputIndex];
    final correct = pad == expected;

    setState(() {
      _phase = _EchoPhase.waiting;
      _activePad = pad;
      if (!correct) _wrongPad = pad;
    });
    unawaited(HapticFeedback.lightImpact());
    unawaited(SystemSound.play(SystemSoundType.click));

    await Future<void>.delayed(const Duration(milliseconds: 170));
    if (!mounted || token != _runToken) return;

    if (!correct) {
      setState(() {
        _activePad = -1;
        _lives--;
      });
      unawaited(HapticFeedback.heavyImpact());
      unawaited(SystemSound.play(SystemSoundType.alert));

      if (_lives <= 0) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (!mounted || token != _runToken) return;
        await _handleFailure();
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted || token != _runToken) return;
      await _playSequence(token);
      return;
    }

    setState(() {
      _activePad = -1;
      _inputIndex++;
    });

    if (_inputIndex < _sequence.length) {
      setState(() => _phase = _EchoPhase.input);
      return;
    }

    setState(() => _phase = _EchoPhase.waiting);
    unawaited(HapticFeedback.mediumImpact());
    await Future<void>.delayed(const Duration(milliseconds: 680));
    if (!mounted || token != _runToken) return;

    if (_round + 1 >= _spec.rounds) {
      await _complete();
      return;
    }

    setState(() {
      _round++;
      _wrongPad = -1;
      _inputIndex = 0;
      _phase = _EchoPhase.watching;
      _sequence.add(_random.nextInt(_spec.padCount));
    });
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted || token != _runToken) return;
    await _playSequence(token);
  }

  Future<void> _complete() async {
    if (_completing) return;
    _completing = true;
    final stars = _lives.clamp(1, 3);
    setState(() => _phase = _EchoPhase.waiting);
    await widget.controller.recordResult(widget.puzzle.id, stars);
    if (!mounted) return;
    final room = widget.puzzle.isRandom ? null : roomForPuzzle(widget.puzzle);
    await celebratePuzzle(
      context,
      puzzle: widget.puzzle,
      stars: stars,
      totalStars: widget.controller.totalStars,
      roomComplete: room != null && widget.controller.isRoomComplete(room),
      allComplete:
          room != null && widget.controller.totalCompleted == allPuzzles.length,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleFailure() async {
    setState(() {
      _phase = _EchoPhase.failed;
      _activePad = -1;
    });
    final retry = await showPuzzleFailure(
      context,
      puzzle: widget.puzzle,
      message: 'The runes slip away. Breathe, watch closely, and try the pattern again.',
    );
    if (!mounted) return;
    if (retry) {
      await _beginSession();
    } else {
      Navigator.of(context).pop();
    }
  }

  String get _status {
    return switch (_phase) {
      _EchoPhase.preparing => 'Settle your mind...',
      _EchoPhase.watching => 'Watch the chandelier',
      _EchoPhase.input => 'Now repeat the pattern',
      _EchoPhase.waiting => 'Hold the thought...',
      _EchoPhase.failed => 'The pattern fades',
    };
  }

  IconData get _statusIcon {
    return switch (_phase) {
      _EchoPhase.preparing => Icons.self_improvement_rounded,
      _EchoPhase.watching => Icons.visibility_rounded,
      _EchoPhase.input => Icons.touch_app_rounded,
      _EchoPhase.waiting => Icons.hourglass_top_rounded,
      _EchoPhase.failed => Icons.nights_stay_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final columns = _spec.padCount == 4 ? 2 : 3;
    final rows = (_spec.padCount / columns).ceil();
    return PuzzleShell(
      puzzle: widget.puzzle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    _buildHud(context),
                    const SizedBox(height: 18),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: _phase == _EchoPhase.input
                            ? widget.puzzle.accent.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _phase == _EchoPhase.input
                              ? widget.puzzle.accent.withValues(alpha: 0.22)
                              : Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _statusIcon,
                            color: widget.puzzle.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Text(
                              _status,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: HavenColors.cream,
                                    fontSize: 12.5,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: columns / rows,
                      child: Column(
                        children: List.generate(rows, (row) {
                          return Expanded(
                            child: Row(
                              children: List.generate(columns, (column) {
                                final index = row * columns + column;
                                if (index >= _spec.padCount) {
                                  return const Expanded(
                                    child: SizedBox.shrink(),
                                  );
                                }
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: _EchoPad(
                                      index: index,
                                      glyph: runeStyles[index],
                                      active: _activePad == index,
                                      wrong: _wrongPad == index,
                                      enabled: _phase == _EchoPhase.input,
                                      onTap: () => _handlePadTap(index),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Round ${_round + 1} of ${_spec.rounds}  ·  the pattern grows each round',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _buildLives(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHud(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PuzzleStatChip(
            icon: Icons.layers_rounded,
            label: 'Round',
            value: '${_round + 1}/${_spec.rounds}',
            accent: widget.puzzle.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PuzzleStatChip(
            icon: Icons.straighten_rounded,
            label: 'Runes',
            value: '${_sequence.length}',
            accent: widget.puzzle.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PuzzleStatChip(
            icon: Icons.favorite_rounded,
            label: 'Lanterns',
            value: '$_lives/${_spec.lives}',
            accent: _lives <= 1 ? HavenColors.coral : widget.puzzle.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildLives(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_spec.lives, (index) {
        final alive = index < _lives;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: alive ? 34 : 24,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: alive
                ? widget.puzzle.accent
                : Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10),
            boxShadow: alive
                ? [
                    BoxShadow(
                      color: widget.puzzle.accent.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _EchoPad extends StatelessWidget {
  final int index;
  final RuneStyle glyph;
  final bool active;
  final bool wrong;
  final bool enabled;
  final VoidCallback onTap;

  const _EchoPad({
    required this.index,
    required this.glyph,
    required this.active,
    required this.wrong,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = wrong ? HavenColors.coral : glyph.color;
    final lit = active || wrong;
    return Semantics(
      button: true,
      label: glyph.name,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: lit
                  ? [
                      color.withValues(alpha: 0.34),
                      color.withValues(alpha: 0.12),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.055),
                      Colors.white.withValues(alpha: 0.022),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: lit
                  ? color.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.075),
              width: lit ? 1.5 : 1,
            ),
            boxShadow: lit
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: AnimatedScale(
            scale: lit ? 1.025 : 1,
            duration: const Duration(milliseconds: 160),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: lit ? 1 : 0.74,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    glyph.icon,
                    size: 38,
                    color: lit ? color : glyph.color.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  glyph.name.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 8.5,
                    letterSpacing: 1.3,
                    color: lit
                        ? color
                        : HavenColors.mist.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
