import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/game_controller.dart';
import '../../game/levels.dart';
import '../../game/lights_out.dart';
import '../../game/models.dart';
import '../../theme/haven_theme.dart';
import '../../widgets/haven_widgets.dart';
import 'puzzle_chrome.dart';

class LumenPuzzleScreen extends StatefulWidget {
  final PuzzleDef puzzle;
  final GameController controller;

  const LumenPuzzleScreen({
    super.key,
    required this.puzzle,
    required this.controller,
  });

  @override
  State<LumenPuzzleScreen> createState() => _LumenPuzzleScreenState();
}

class _LumenPuzzleScreenState extends State<LumenPuzzleScreen> {
  late final LumenSpec _spec;
  late final int _goalMask;
  late int _initialMask;
  late int _litMask;
  int _moves = 0;
  int _hints = 0;
  int? _hintIndex;
  bool _solved = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _spec = widget.puzzle.spec as LumenSpec;
    _goalMask = allLitMask(_spec.size);
    _buildStartingBoard();
  }

  void _buildStartingBoard() {
    final random = Random(widget.puzzle.id.hashCode & 0x7fffffff);
    final cells = _spec.size * _spec.size;
    final candidates = List.generate(cells, (index) => index)..shuffle(random);
    var mask = _goalMask;
    for (var i = 0; i < _spec.scrambles && i < candidates.length; i++) {
      mask = applyPress(mask, _spec.size, candidates[i]);
    }
    if (mask == _goalMask) {
      mask = applyPress(mask, _spec.size, candidates.first);
    }
    _initialMask = mask;
    _litMask = mask;
    _moves = 0;
    _hints = 0;
    _hintIndex = null;
    _solved = false;
    _completing = false;
  }

  void _press(int index) {
    if (_solved) return;
    setState(() {
      _litMask = applyPress(_litMask, _spec.size, index);
      _moves++;
      _hintIndex = null;
    });
    unawaited(HapticFeedback.selectionClick());
    unawaited(SystemSound.play(SystemSoundType.click));

    if (_litMask == _goalMask) {
      unawaited(HapticFeedback.mediumImpact());
      _handleWin();
    }
  }

  void _showHint() {
    if (_solved || _hints >= 3) return;
    final solution = solveLightsOut(
      size: _spec.size,
      litMask: _litMask,
      goalMask: _goalMask,
    );
    if (solution == null || solution == 0) return;
    final variables = _spec.size * _spec.size;
    final options = <int>[];
    for (var index = 0; index < variables; index++) {
      if (((solution >> index) & 1) == 1) options.add(index);
    }
    if (options.isEmpty) return;
    final choice = options[_hints % options.length];
    setState(() {
      _hints++;
      _hintIndex = choice;
    });
    unawaited(HapticFeedback.mediumImpact());
  }

  void _reset() {
    if (_solved) return;
    setState(() {
      _litMask = _initialMask;
      _moves = 0;
      _hints = 0;
      _hintIndex = null;
    });
    unawaited(HapticFeedback.lightImpact());
  }

  int _starRating() {
    final efficient = _moves <= _spec.scrambles + 2;
    final careful = _moves <= _spec.scrambles + 7;
    if (_hints == 0 && efficient) return 3;
    if (_hints <= 1 && careful) return 2;
    return 1;
  }

  Future<void> _handleWin() async {
    if (_completing) return;
    _completing = true;
    setState(() => _solved = true);
    final stars = _starRating();
    await Future<void>.delayed(const Duration(milliseconds: 620));
    if (!mounted) return;
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

  int _countLit() {
    var count = 0;
    for (var i = 0; i < _spec.size * _spec.size; i++) {
      if (((_litMask >> i) & 1) == 1) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final total = _spec.size * _spec.size;
    final lit = _countLit();
    return PuzzleShell(
      puzzle: widget.puzzle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 640;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, compact ? 4 : 10, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PuzzleStatChip(
                            icon: Icons.touch_app_rounded,
                            label: 'Touches',
                            value: '$_moves',
                            accent: widget.puzzle.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PuzzleStatChip(
                            icon: Icons.light_mode_rounded,
                            label: 'Lit',
                            value: '$lit/$total',
                            accent: widget.puzzle.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PuzzleStatChip(
                            icon: Icons.auto_fix_high_rounded,
                            label: 'Hints',
                            value: '${3 - _hints}',
                            accent: _hints > 0
                                ? HavenColors.coral
                                : widget.puzzle.accent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 14 : 20),
                    Text(
                      'Wake every lantern',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'A touch lights its neighbours too. Find the elegant sequence.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: compact ? 14 : 20),
                    _buildBoard(context),
                    SizedBox(height: compact ? 14 : 18),
                    Row(
                      children: [
                        Expanded(
                          child: HavenButton(
                            label: _hints >= 3
                                ? 'No hints left'
                                : 'Reveal a move',
                            icon: Icons.auto_fix_high_rounded,
                            trailing: null,
                            height: 48,
                            color: widget.puzzle.accent,
                            muted: _hints >= 3,
                            onPressed: _hints >= 3 ? null : _showHint,
                          ),
                        ),
                        const SizedBox(width: 10),
                        HavenButton(
                          label: 'Reset',
                          icon: Icons.restart_alt_rounded,
                          trailing: null,
                          height: 48,
                          muted: true,
                          onPressed: _reset,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 260,
                      child: HavenProgressBar(
                        value: lit / total,
                        color: widget.puzzle.accent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Par · ${_spec.scrambles} touches  ·  hints lower your stars',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoard(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: widget.puzzle.accent.withValues(alpha: 0.08),
                blurRadius: 50,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Column(
            children: List.generate(_spec.size, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(_spec.size, (col) {
                    final index = row * _spec.size + col;
                    final on = ((_litMask >> index) & 1) == 1;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3.5),
                        child: _LumenTile(
                          lit: on,
                          hinted: _hintIndex == index,
                          accent: widget.puzzle.accent,
                          onTap: () => _press(index),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _LumenTile extends StatelessWidget {
  final bool lit;
  final bool hinted;
  final Color accent;
  final VoidCallback onTap;

  const _LumenTile({
    required this.lit,
    required this.hinted,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: lit ? 'Lantern lit' : 'Lantern dark',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: lit
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFF2C7),
                      Color.lerp(accent, Colors.white, 0.12)!,
                    ],
                  )
                : null,
            color: lit ? null : Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: hinted
                  ? HavenColors.mint.withValues(alpha: 0.9)
                  : lit
                  ? Colors.white.withValues(alpha: 0.34)
                  : Colors.white.withValues(alpha: 0.07),
              width: hinted ? 2 : 1,
            ),
            boxShadow: lit
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.28),
                      blurRadius: 18,
                      spreadRadius: -2,
                    ),
                  ]
                : hinted
                ? [
                    BoxShadow(
                      color: HavenColors.mint.withValues(alpha: 0.25),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedOpacity(
              opacity: lit ? 1 : 0.25,
              duration: const Duration(milliseconds: 220),
              child: Icon(
                hinted
                    ? Icons.touch_app_rounded
                    : lit
                    ? Icons.auto_awesome_rounded
                    : Icons.circle,
                size: hinted ? 22 : (lit ? 21 : 6),
                color: hinted
                    ? HavenColors.mint
                    : lit
                    ? const Color(0xFF6F4C19)
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
