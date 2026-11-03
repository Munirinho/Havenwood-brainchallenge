import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/models.dart';
import '../theme/haven_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/haven_widgets.dart';
import '../widgets/room_illustration.dart';
import 'puzzle_launcher.dart';

class RoomScreen extends StatelessWidget {
  final RoomDef room;
  final GameController controller;

  const RoomScreen({super.key, required this.room, required this.controller});

  static const _roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HavenBackdrop(
        accent: room.accent,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return _RoomContent(
                room: room,
                controller: controller,
                roman: _roman[room.index],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoomContent extends StatelessWidget {
  final RoomDef room;
  final GameController controller;
  final String roman;

  const _RoomContent({
    required this.room,
    required this.controller,
    required this.roman,
  });

  @override
  Widget build(BuildContext context) {
    final solved = controller.solvedInRoom(room);
    final complete = controller.isRoomComplete(room);
    final stars = room.puzzles.fold<int>(
      0,
      (total, puzzle) => total + controller.starsFor(puzzle.id),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, solved: solved),
              const SizedBox(height: 18),
              _buildHero(
                context,
                solved: solved,
                complete: complete,
                stars: stars,
              ),
              if (solved > 0) ...[
                const SizedBox(height: 13),
                _buildRestorationNote(context, solved),
              ],
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CHALLENGES',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: HavenColors.mist.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '$solved OF ${room.puzzles.length} COMPLETE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: room.accent, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              ...room.puzzles.asMap().entries.map((entry) {
                final index = entry.key;
                final puzzle = entry.value;
                final puzzleStars = controller.starsFor(puzzle.id);
                final unlocked = controller.isPuzzleUnlocked(room, index);
                final isNext =
                    puzzleStars == 0 && controller.nextPuzzle?.id == puzzle.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PuzzleCard(
                    puzzle: puzzle,
                    number: index + 1,
                    stars: puzzleStars,
                    unlocked: unlocked,
                    isNext: isNext,
                    onTap: () => _handlePuzzleTap(
                      context,
                      puzzle,
                      unlocked: unlocked,
                      previous: index == 0 ? null : room.puzzles[index - 1],
                    ),
                  ),
                );
              }),
              if (complete) ...[
                const SizedBox(height: 8),
                GlassPanel(
                  tint: room.accent,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: room.accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: room.accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          color: room.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This chamber is restored',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Replay any challenge to deepen your mastery.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle_rounded,
                        color: room.accent,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Center(
                child: HavenButton(
                  label: 'Return to the manor',
                  icon: Icons.arrow_back_rounded,
                  trailing: null,
                  muted: true,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required int solved}) {
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
                'CHAMBER $roman',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: room.accent, letterSpacing: 1.8),
              ),
              const SizedBox(height: 3),
              Text(
                room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: room.accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: room.accent.withValues(alpha: 0.18)),
          ),
          child: Text(
            '$solved/${room.puzzles.length}',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: room.accent, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(
    BuildContext context, {
    required int solved,
    required bool complete,
    required int stars,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: HavenColors.night,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: room.accent.withValues(alpha: 0.06),
            blurRadius: 55,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 218,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 360,
                      height: 220,
                      child: RoomIllustration(
                        room: room,
                        progress: solved / room.puzzles.length,
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        HavenColors.night.withValues(alpha: 0.12),
                        HavenColors.night.withValues(alpha: 0.92),
                      ],
                      stops: const [0.4, 0.66, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: PillTag(
                    label: complete ? 'Restored' : 'Restoring',
                    icon: complete
                        ? Icons.check_circle_rounded
                        : Icons.auto_awesome_rounded,
                    color: room.accent,
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HavenColors.ink.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: HavenColors.gold,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$stars/${room.puzzles.length * 3}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: HavenColors.cream,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room.caption,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HavenColors.cream.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HavenColors.night.withValues(alpha: 0.96),
                  HavenColors.deep.withValues(alpha: 0.94),
                ],
              ),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.description,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'RESTORATION',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HavenColors.mist.withValues(alpha: 0.72),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(solved / room.puzzles.length * 100).round()}%',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: room.accent, letterSpacing: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                HavenProgressBar(
                  value: solved / room.puzzles.length,
                  color: room.accent,
                  height: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestorationNote(BuildContext context, int solved) {
    final note = room.restorationNotes[solved - 1];
    return GlassPanel(
      tint: room.accent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: room.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: room.accent,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE HOUSE REMEMBERS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: room.accent,
                    fontSize: 8,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  child: Text(
                    note,
                    key: ValueKey(note),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: HavenColors.cream.withValues(alpha: 0.8),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePuzzleTap(
    BuildContext context,
    PuzzleDef puzzle, {
    required bool unlocked,
    required PuzzleDef? previous,
  }) async {
    if (!unlocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              previous == null
                  ? 'This challenge is still sealed.'
                  : 'Solve ${previous.title} to reveal this challenge.',
            ),
          ),
        );
      return;
    }
    await openPuzzle(context, puzzle: puzzle, controller: controller);
  }
}

class _PuzzleCard extends StatelessWidget {
  final PuzzleDef puzzle;
  final int number;
  final int stars;
  final bool unlocked;
  final bool isNext;
  final VoidCallback onTap;

  const _PuzzleCard({
    required this.puzzle,
    required this.number,
    required this.stars,
    required this.unlocked,
    required this.isNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final complete = stars > 0;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: unlocked ? 1 : 0.48,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: panelGradient(tint: puzzle.accent),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isNext
                  ? puzzle.accent.withValues(alpha: 0.36)
                  : complete
                  ? puzzle.accent.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.075),
              width: isNext ? 1.3 : 1,
            ),
            boxShadow: isNext
                ? [
                    BoxShadow(
                      color: puzzle.accent.withValues(alpha: 0.09),
                      blurRadius: 30,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      puzzle.accent.withValues(alpha: 0.24),
                      puzzle.accent.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: puzzle.accent.withValues(alpha: 0.24),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      unlocked ? puzzle.kind.icon : Icons.lock_outline_rounded,
                      color: unlocked
                          ? puzzle.accent
                          : HavenColors.mist.withValues(alpha: 0.7),
                      size: 23,
                    ),
                    Positioned(
                      top: 5,
                      left: 7,
                      child: Text(
                        '$number',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: puzzle.accent.withValues(alpha: 0.7),
                          fontSize: 7.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  puzzle.kind.label.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: puzzle.accent,
                                        fontSize: 8,
                                        letterSpacing: 1.15,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ...List.generate(3, (index) {
                                return Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.only(right: 2.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index < puzzle.difficulty
                                        ? puzzle.accent.withValues(alpha: 0.6)
                                        : Colors.white.withValues(alpha: 0.08),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        if (isNext) ...[
                          const SizedBox(width: 6),
                          PillTag(
                            label: 'Next',
                            color: puzzle.accent,
                            dense: true,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      puzzle.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 15.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      puzzle.subtitle,
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
                        StarRow(earned: stars, size: 13, showEmpty: true),
                        const SizedBox(width: 8),
                        Text(
                          complete ? 'REPLAY' : (unlocked ? 'BEGIN' : 'LOCKED'),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: complete
                                    ? HavenColors.dim
                                    : unlocked
                                    ? puzzle.accent
                                    : HavenColors.dim,
                                fontSize: 7.5,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                complete
                    ? Icons.refresh_rounded
                    : unlocked
                    ? Icons.play_arrow_rounded
                    : Icons.lock_outline_rounded,
                color: complete
                    ? HavenColors.mist.withValues(alpha: 0.55)
                    : unlocked
                    ? puzzle.accent
                    : HavenColors.dim,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
