import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/levels.dart';
import '../game/models.dart';
import '../theme/haven_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/aurora_card.dart';
import '../widgets/haven_widgets.dart';
import '../widgets/manor_art.dart';
import '../widgets/soundtrack_toggle.dart';
import 'random_challenges_screen.dart';
import 'room_screen.dart';

class HomeScreen extends StatelessWidget {
  final GameController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HavenBackdrop(
        accent: HavenColors.gold,
        quiet: true,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return _HomeContent(controller: controller);
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final GameController controller;

  const _HomeContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final progress = controller.restorationProgress;
    final nextRoom = controller.nextRoom;
    final nextPuzzle = controller.nextPuzzle;
    final restoredRooms = rooms
        .where((room) => controller.isRoomComplete(room))
        .length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Reveal(child: _buildHeader(context)),
              const SizedBox(height: 24),
              _Reveal(
                duration: 850,
                child: _buildHero(
                  context,
                  progress: progress,
                  nextRoom: nextRoom,
                  nextPuzzle: nextPuzzle,
                ),
              ),
              const SizedBox(height: 14),
              _Reveal(
                duration: 900,
                child: _ChanceTrialsCard(
                  onTap: () => _openChanceTrials(context),
                ),
              ),
              const SizedBox(height: 14),
              _Reveal(duration: 950, child: _buildStats(context)),
              const SizedBox(height: 14),
              _Reveal(duration: 1050, child: _buildMind(context)),
              const SizedBox(height: 26),
              _Reveal(
                duration: 1150,
                child: _buildChambersHeader(
                  context,
                  restoredRooms: restoredRooms,
                ),
              ),
              const SizedBox(height: 12),
              ...rooms.asMap().entries.map((entry) {
                final room = entry.value;
                return _Reveal(
                  duration: 1100 + entry.key * 90,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RoomCard(
                      room: room,
                      unlocked: controller.isRoomUnlocked(room),
                      complete: controller.isRoomComplete(room),
                      solved: controller.solvedInRoom(room),
                      isNext: nextRoom?.index == room.index,
                      stars: room.puzzles.fold<int>(
                        0,
                        (total, puzzle) =>
                            total + controller.starsFor(puzzle.id),
                      ),
                      onTap: () => _handleRoomTap(context, room),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 22),
              _Reveal(
                duration: 1500,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '"A mind, like a house, is restored one room at a time."',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 20,
                              color: HavenColors.mist.withValues(alpha: 0.72),
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'PROGRESS SAVES AUTOMATICALLY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: HavenColors.dim.withValues(alpha: 0.7),
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HavenColors.gold.withValues(alpha: 0.22),
                HavenColors.gold.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(color: HavenColors.gold.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: HavenColors.gold.withValues(alpha: 0.14),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: HavenColors.gold,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HAVENWOOD',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  letterSpacing: 3.2,
                  color: HavenColors.cream,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'A CEREBRAL RESTORATION',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: HavenColors.mist.withValues(alpha: 0.65),
                  fontSize: 8,
                  letterSpacing: 1.7,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: HavenColors.gold, size: 16),
              const SizedBox(width: 5),
              Text(
                '${controller.totalStars}',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: HavenColors.cream),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const SoundtrackToggleButton(size: 40),
        const SizedBox(width: 8),
        HavenIconButton(
          icon: Icons.tune_rounded,
          size: 40,
          onPressed: () => _showSettings(context),
        ),
      ],
    );
  }

  Widget _buildHero(
    BuildContext context, {
    required double progress,
    required RoomDef? nextRoom,
    required PuzzleDef? nextPuzzle,
  }) {
    final percent = (progress * 100).round();
    final heroTitle = switch (progress) {
      <= 0.001 => 'A house asleep\nin the dark',
      < 0.35 => 'The first light\nreturns',
      < 0.7 => 'The manor\nis waking',
      < 1 => 'Warmth finds\nevery room',
      _ => 'Havenwood\nis awake',
    };

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: HavenColors.night,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: HavenColors.gold.withValues(alpha: 0.07),
            blurRadius: 60,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 246,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, 0.3),
                    child: SizedBox(
                      width: 360,
                      height: 260,
                      child: ManorArt(
                        progress: progress,
                        accent: HavenColors.gold,
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
                        HavenColors.night.withValues(alpha: 0.2),
                        HavenColors.night.withValues(alpha: 0.96),
                      ],
                      stops: const [0.28, 0.64, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: PillTag(
                    label: 'Havenwood Manor',
                    icon: Icons.castle_rounded,
                    color: HavenColors.gold,
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: _PercentBadge(percent: percent),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heroTitle,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontSize: 34, height: 0.98),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        nextPuzzle == null
                            ? 'Every chamber remembers your touch.'
                            : '${controller.totalCompleted} of ${allPuzzles.length} lights restored',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HavenColors.cream.withValues(alpha: 0.62),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
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
              children: [
                Row(
                  children: [
                    Text(
                      'RESTORATION',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HavenColors.mist.withValues(alpha: 0.72),
                        letterSpacing: 1.6,
                      ),
                    ),
                    const Spacer(),
                    if (nextPuzzle != null)
                      Flexible(
                        child: Text(
                          'Next · ${nextPuzzle.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: HavenColors.gold,
                                letterSpacing: 0.2,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                HavenProgressBar(
                  value: progress,
                  color: HavenColors.gold,
                  height: 7,
                ),
                const SizedBox(height: 15),
                HavenButton(
                  label: nextRoom == null
                      ? 'Havenwood is awake'
                      : 'Continue restoring',
                  icon: nextRoom == null
                      ? Icons.auto_awesome_rounded
                      : Icons.play_arrow_rounded,
                  color: HavenColors.gold,
                  expand: true,
                  onPressed: () {
                    if (nextRoom == null) {
                      _showRestoredMessage(context);
                    } else {
                      _openRoom(context, nextRoom);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.star_rounded,
            value: '${controller.totalStars}',
            label: 'STARS',
            color: HavenColors.gold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_outline_rounded,
            value: '${controller.totalCompleted}/${allPuzzles.length}',
            label: 'RESTORED',
            color: HavenColors.mint,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            icon: Icons.psychology_rounded,
            value: '${controller.cognitiveIndex}',
            label: 'MIND INDEX',
            color: HavenColors.lilac,
          ),
        ),
      ],
    );
  }

  Widget _buildMind(BuildContext context) {
    return GlassPanel(
      tint: HavenColors.lilac,
      padding: const EdgeInsets.fromLTRB(20, 19, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: HavenColors.lilac.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: HavenColors.lilac.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: HavenColors.lilac,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MIND IN BLOOM',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HavenColors.lilac,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Four facets of thought',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: HavenColors.lilac.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: HavenColors.lilac.withValues(alpha: 0.16),
                  ),
                ),
                child: Text(
                  '${controller.cognitiveIndex} / 100',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: HavenColors.lilac, letterSpacing: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...PuzzleKind.values.asMap().entries.map((entry) {
            final kind = entry.value;
            final score = controller.skillScore(kind);
            final percentage = (score * 100).round();
            return Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == PuzzleKind.values.length - 1 ? 0 : 14,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(kind.icon, size: 14, color: kind.accent),
                      const SizedBox(width: 8),
                      Text(
                        kind.shortLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HavenColors.cream.withValues(alpha: 0.82),
                          fontSize: 11.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$percentage%',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: kind.accent, letterSpacing: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  HavenProgressBar(value: score, color: kind.accent, height: 5),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChambersHeader(
    BuildContext context, {
    required int restoredRooms,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'THE CHAMBERS',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: HavenColors.mist.withValues(alpha: 0.8)),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            '$restoredRooms OF ${rooms.length} RESTORED',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: HavenColors.gold, letterSpacing: 0.8),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRoomTap(BuildContext context, RoomDef room) async {
    if (controller.isRoomUnlocked(room)) {
      await _openRoom(context, room);
      return;
    }
    final previous = rooms[room.index - 1];
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Restore ${previous.name} before entering ${room.name}.',
          ),
        ),
      );
  }

  Future<void> _openChanceTrials(BuildContext context) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 440),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RandomChallengesScreen(controller: controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.98, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _openRoom(BuildContext context, RoomDef room) async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 480),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RoomScreen(room: room, controller: controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showRestoredMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Havenwood is restored. Revisit any chamber to deepen your mind.',
          ),
        ),
      );
  }

  Future<void> _showSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GlassPanel(
              tint: HavenColors.lilac,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Your journey',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Text(
                        'HAVENWOOD',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: HavenColors.gold,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress is saved automatically on this device. Every chamber can be replayed for a higher rating.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  HavenButton(
                    label: 'How to play',
                    icon: Icons.explore_outlined,
                    color: HavenColors.lilac,
                    expand: true,
                    muted: true,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _showGuide(context);
                    },
                  ),
                  const SizedBox(height: 10),
                  HavenButton(
                    label: 'Reset journey',
                    icon: Icons.restart_alt_rounded,
                    color: HavenColors.coral,
                    expand: true,
                    muted: true,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _confirmReset(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showGuide(BuildContext context) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'How to play',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 300),
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
                tint: HavenColors.gold,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE WAY OF HAVENWOOD',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: HavenColors.gold,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Restore the manor,\nsharpen the mind',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 18),
                    const _GuideStep(
                      icon: Icons.door_sliding_rounded,
                      title: 'Choose a chamber',
                      text: 'Each chamber holds three challenges. Finish one to reveal the next.',
                    ),
                    const _GuideStep(
                      icon: Icons.psychology_rounded,
                      title: 'Four kinds of thought',
                      text: 'Memory, logic, spatial weaving, and deduction each train a different skill.',
                    ),
                    const _GuideStep(
                      icon: Icons.star_rounded,
                      title: 'Stars remember mastery',
                      text: 'Efficiency, patience, and clean solutions earn higher star ratings.',
                    ),
                    const _GuideStep(
                      icon: Icons.casino_rounded,
                      title: 'Wander into chance trials',
                      text: 'Shuffle randomized games, each with its own mood and relaxing soundscape.',
                    ),
                    const _GuideStep(
                      icon: Icons.spa_rounded,
                      title: 'The house responds',
                      text: 'Every solved challenge restores another part of Havenwood.',
                      last: true,
                    ),
                    const SizedBox(height: 10),
                    HavenButton(
                      label: 'Begin',
                      color: HavenColors.gold,
                      trailing: null,
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

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reset journey',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: GlassPanel(
                tint: HavenColors.coral,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.nights_stay_rounded,
                      color: HavenColors.coral,
                      size: 32,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Let the house sleep?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All stars and restored rooms will be lost. This cannot be undone.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    HavenButton(
                      label: 'Keep my progress',
                      color: HavenColors.mint,
                      expand: true,
                      trailing: null,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(height: 10),
                    HavenButton(
                      label: 'Reset everything',
                      color: HavenColors.coral,
                      muted: true,
                      expand: true,
                      trailing: null,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      await controller.resetProgress();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Havenwood sleeps once more.')),
        );
    }
  }
}

class _ChanceTrialsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ChanceTrialsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AuroraCard(
      radius: 24,
      glow: true,
      colors: const [
        HavenColors.gold,
        HavenColors.lilac,
        HavenColors.mint,
        HavenColors.sky,
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [HavenColors.gold, HavenColors.lilac],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HavenColors.gold.withValues(alpha: 0.26),
                        blurRadius: 22,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.casino_rounded,
                    color: HavenColors.ink,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'CHANCE TRIALS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: HavenColors.gold,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PillTag(
                            label: 'New',
                            color: HavenColors.mint,
                            dense: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Random brain games',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Six moods, six soundscapes, endless variations.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HavenColors.mist.withValues(alpha: 0.66),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          ..._challengeDots.map((color) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'SHUFFLE A SET',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: HavenColors.mint,
                                    fontSize: 7.5,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: HavenColors.gold,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const List<Color> _challengeDots = [
  HavenColors.lilac,
  HavenColors.gold,
  HavenColors.sky,
  HavenColors.rose,
  HavenColors.mint,
  Color(0xFF8BE6A9),
];

class _Reveal extends StatelessWidget {
  final Widget child;
  final int duration;

  const _Reveal({required this.child, this.duration = 800});

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
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _PercentBadge extends StatelessWidget {
  final int percent;

  const _PercentBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HavenColors.ink.withValues(alpha: 0.44),
        border: Border.all(color: HavenColors.gold.withValues(alpha: 0.32)),
        boxShadow: [
          BoxShadow(
            color: HavenColors.gold.withValues(alpha: 0.12),
            blurRadius: 22,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontSize: 16, color: HavenColors.cream),
          ),
          const SizedBox(height: 1),
          Text(
            'LIT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 7,
              color: HavenColors.gold,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      tint: color,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cormorant',
                    fontSize: 23,
                    height: 1,
                    color: HavenColors.cream,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HavenColors.dim,
              fontSize: 7.5,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomDef room;
  final bool unlocked;
  final bool complete;
  final int solved;
  final bool isNext;
  final int stars;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.unlocked,
    required this.complete,
    required this.solved,
    required this.isNext,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: unlocked ? 1 : 0.55,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: panelGradient(tint: room.accent),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: complete
                  ? room.accent.withValues(alpha: 0.32)
                  : isNext
                  ? room.accent.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.075),
            ),
            boxShadow: complete || isNext
                ? [
                    BoxShadow(
                      color: room.accent.withValues(alpha: 0.08),
                      blurRadius: 28,
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      room.accent.withValues(alpha: 0.24),
                      room.accent.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: room.accent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  unlocked ? room.icon : Icons.lock_outline_rounded,
                  color: unlocked
                      ? room.accent
                      : HavenColors.mist.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            room.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontSize: 17),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (complete)
                          PillTag(
                            label: 'Restored',
                            color: room.accent,
                            dense: true,
                          )
                        else if (isNext)
                          PillTag(
                            label: 'Next',
                            color: room.accent,
                            dense: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HavenColors.mist.withValues(alpha: 0.66),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ...List.generate(3, (index) {
                          final done = index < solved;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 22,
                            height: 4,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: done
                                  ? room.accent
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: done
                                  ? [
                                      BoxShadow(
                                        color: room.accent.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '$solved/3',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: HavenColors.dim,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const Spacer(),
                        if (unlocked && stars > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: HavenColors.gold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$stars',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: HavenColors.gold),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                unlocked
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.lock_outline_rounded,
                size: unlocked ? 14 : 16,
                color: HavenColors.mist.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final bool last;

  const _GuideStep({
    required this.icon,
    required this.title,
    required this.text,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: HavenColors.gold.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: HavenColors.gold.withValues(alpha: 0.16),
              ),
            ),
            child: Icon(icon, color: HavenColors.gold, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HavenColors.mist.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
