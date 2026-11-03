import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/models.dart';
import 'puzzles/cipher_puzzle_screen.dart';
import 'puzzles/echo_puzzle_screen.dart';
import 'puzzles/flow_puzzle_screen.dart';
import 'puzzles/lumen_puzzle_screen.dart';

Future<void> openPuzzle(
  BuildContext context, {
  required PuzzleDef puzzle,
  required GameController controller,
}) async {
  final Widget screen = switch (puzzle.kind) {
    PuzzleKind.echo => EchoPuzzleScreen(puzzle: puzzle, controller: controller),
    PuzzleKind.lumen => LumenPuzzleScreen(
      puzzle: puzzle,
      controller: controller,
    ),
    PuzzleKind.flow => FlowPuzzleScreen(puzzle: puzzle, controller: controller),
    PuzzleKind.cipher => CipherPuzzleScreen(
      puzzle: puzzle,
      controller: controller,
    ),
  };

  await Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 480),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
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
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
