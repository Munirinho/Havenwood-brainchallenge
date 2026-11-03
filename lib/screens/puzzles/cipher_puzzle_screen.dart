import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/cipher_logic.dart';
import '../../game/game_controller.dart';
import '../../game/levels.dart';
import '../../game/models.dart';
import '../../theme/haven_theme.dart';
import '../../widgets/haven_widgets.dart';
import 'puzzle_chrome.dart';

class CipherPuzzleScreen extends StatefulWidget {
  final PuzzleDef puzzle;
  final GameController controller;

  const CipherPuzzleScreen({
    super.key,
    required this.puzzle,
    required this.controller,
  });

  @override
  State<CipherPuzzleScreen> createState() => _CipherPuzzleScreenState();
}

class _CipherPuzzleScreenState extends State<CipherPuzzleScreen> {
  late final CipherSpec _spec;
  final Random _random = Random();
  late List<int> _secret;
  late List<int?> _current;
  final List<CipherResult> _history = [];
  int _attempts = 0;
  int _selectedSlot = 0;
  bool _solved = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _spec = widget.puzzle.spec as CipherSpec;
    _prepareRound();
  }

  void _prepareRound() {
    _secret = generateCipherSecret(
      runeCount: _spec.runeCount,
      slots: _spec.slots,
      allowDuplicates: _spec.allowDuplicates,
      random: _random,
    );
    _current = List<int?>.filled(_spec.slots, null);
    _history.clear();
    _attempts = 0;
    _selectedSlot = 0;
    _solved = false;
    _completing = false;
  }

  bool get _canSubmit => _current.every((slot) => slot != null);

  bool _isRuneAvailable(int rune) {
    if (_spec.allowDuplicates) return true;
    return !_current.contains(rune);
  }

  void _selectSlot(int index) {
    if (_solved) return;
    setState(() => _selectedSlot = index);
    unawaited(HapticFeedback.selectionClick());
  }

  void _chooseRune(int rune) {
    if (_solved || !_isRuneAvailable(rune)) return;
    setState(() {
      _current[_selectedSlot] = rune;
      var next = _selectedSlot + 1;
      while (next < _spec.slots && _current[next] != null) {
        next++;
      }
      if (next < _spec.slots) {
        _selectedSlot = next;
      } else {
        final empty = _current.indexOf(null);
        if (empty >= 0) _selectedSlot = empty;
      }
    });
    unawaited(HapticFeedback.selectionClick());
    unawaited(SystemSound.play(SystemSoundType.click));
  }

  void _eraseSlot() {
    if (_solved) return;
    setState(() {
      _current[_selectedSlot] = null;
    });
    unawaited(HapticFeedback.lightImpact());
  }

  void _submit() {
    if (_solved || !_canSubmit) return;
    final guess = _current.cast<int>();
    final result = evaluateCipher(guess, _secret);
    _attempts++;
    setState(() {
      _history.insert(0, result);
    });
    unawaited(HapticFeedback.mediumImpact());
    unawaited(SystemSound.play(SystemSoundType.click));

    if (result.solved) {
      _handleSuccess();
      return;
    }

    if (_attempts >= _spec.maxAttempts) {
      _handleFailure();
      return;
    }

    setState(() {
      _current = List<int?>.filled(_spec.slots, null);
      _selectedSlot = 0;
    });
  }

  int _starRating() {
    if (_attempts <= _spec.parAttempts) return 3;
    if (_attempts <= _spec.parAttempts + 2) return 2;
    return 1;
  }

  Future<void> _handleSuccess() async {
    if (_completing) return;
    _completing = true;
    setState(() => _solved = true);
    unawaited(HapticFeedback.heavyImpact());
    final stars = _starRating();
    await Future<void>.delayed(const Duration(milliseconds: 700));
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

  Future<void> _handleFailure() async {
    final retry = await showPuzzleFailure(
      context,
      puzzle: widget.puzzle,
      message: 'The final tumbler will not turn. Every clue you uncovered is still in your mind - begin again with a new sequence.',
    );
    if (!mounted) return;
    if (retry) {
      setState(_prepareRound);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PuzzleShell(
      puzzle: widget.puzzle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PuzzleStatChip(
                        icon: Icons.lock_outline_rounded,
                        label: 'Tries',
                        value: '$_attempts/${_spec.maxAttempts}',
                        accent: widget.puzzle.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PuzzleStatChip(
                        icon: Icons.grid_view_rounded,
                        label: 'Slots',
                        value: '${_spec.slots}',
                        accent: widget.puzzle.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PuzzleStatChip(
                        icon: Icons.bolt_rounded,
                        label: 'Par',
                        value: '${_spec.parAttempts}',
                        accent: widget.puzzle.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Deduce the hidden sequence',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _spec.allowDuplicates
                      ? 'Runes may repeat. Gold is exact; mint belongs elsewhere.'
                      : 'No rune repeats. Gold is exact; mint belongs elsewhere.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'YOUR SEQUENCE',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: HavenColors.dim),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _eraseSlot,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.backspace_outlined,
                            size: 13,
                            color: HavenColors.mist,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'ERASE',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: HavenColors.mist),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _buildCurrentRow(context),
                const SizedBox(height: 16),
                _buildPalette(context),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'CLUES',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: HavenColors.dim),
                    ),
                    const Spacer(),
                    const _LegendDot(color: HavenColors.gold, label: 'exact'),
                    const SizedBox(width: 12),
                    const _LegendDot(color: HavenColors.mint, label: 'near'),
                  ],
                ),
                const SizedBox(height: 5),
                _buildHistory(context),
                const SizedBox(height: 10),
                HavenButton(
                  label: _canSubmit ? 'Open the lock' : 'Fill every slot',
                  icon: _canSubmit
                      ? Icons.lock_open_rounded
                      : Icons.lock_clock_rounded,
                  trailing: null,
                  color: widget.puzzle.accent,
                  expand: true,
                  onPressed: _canSubmit ? _submit : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_spec.slots, (index) {
        final rune = _current[index];
        final style = rune == null ? null : runeStyles[rune];
        final selected = _selectedSlot == index;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: GestureDetector(
            onTap: () => _selectSlot(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (style?.color ?? widget.puzzle.accent).withValues(
                      alpha: selected ? 0.18 : 0.06,
                    ),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? widget.puzzle.accent.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.08),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: widget.puzzle.accent.withValues(alpha: 0.15),
                          blurRadius: 18,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: style == null
                      ? Icon(
                          Icons.circle_outlined,
                          key: ValueKey('empty-$index'),
                          size: 17,
                          color: Colors.white.withValues(alpha: 0.18),
                        )
                      : Icon(
                          style.icon,
                          key: ValueKey('rune-$index-$rune'),
                          size: 28,
                          color: style.color,
                        ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPalette(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_spec.runeCount, (index) {
        final style = runeStyles[index];
        final available = _isRuneAvailable(index);
        return Semantics(
          button: true,
          label: style.name,
          child: GestureDetector(
            onTap: available ? () => _chooseRune(index) : null,
            child: AnimatedOpacity(
              opacity: available ? 1 : 0.24,
              duration: const Duration(milliseconds: 180),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: style.color.withValues(alpha: 0.3)),
                ),
                child: Icon(style.icon, color: style.color, size: 21),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHistory(BuildContext context) {
    if (_history.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: widget.puzzle.accent.withValues(alpha: 0.7),
                size: 19,
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  'Your clues will gather here',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 6),
      itemCount: _history.length,
      separatorBuilder: (_, _) => const SizedBox(height: 7),
      itemBuilder: (context, index) {
        final result = _history[index];
        final attemptNumber = _attempts - index;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: result.solved
                ? widget.puzzle.accent.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: result.solved
                  ? widget.puzzle.accent.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$attemptNumber',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: HavenColors.dim),
                ),
              ),
              ...result.guess.map((rune) {
                final style = runeStyles[rune];
                return Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: style.color.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(style.icon, size: 15, color: style.color),
                );
              }),
              const Spacer(),
              _FeedbackPegs(exact: result.exact, near: result.near),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: HavenColors.dim, letterSpacing: 0.4),
        ),
      ],
    );
  }
}

class _FeedbackPegs extends StatelessWidget {
  final int exact;
  final int near;

  const _FeedbackPegs({required this.exact, required this.near});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (exact == 0 && near == 0)
          Text(
            'no match',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: HavenColors.dim, letterSpacing: 0),
          ),
        for (var i = 0; i < exact; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 3),
            decoration: const BoxDecoration(
              color: HavenColors.gold,
              shape: BoxShape.circle,
            ),
          ),
        for (var i = 0; i < near; i++)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: HavenColors.mint.withValues(alpha: 0.85),
                width: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
