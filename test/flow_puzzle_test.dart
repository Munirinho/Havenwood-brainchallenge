import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:havenwood/game/game_controller.dart';
import 'package:havenwood/game/levels.dart';
import 'package:havenwood/game/models.dart';
import 'package:havenwood/screens/puzzles/flow_puzzle_screen.dart';
import 'package:havenwood/theme/haven_theme.dart';

void main() {
  testWidgets('drag-weaves a flow level and records completion', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = GameController(persist: false);
    final puzzle = rooms[0].puzzles[2];
    final spec = puzzle.spec as FlowSpec;

    await tester.pumpWidget(
      MaterialApp(
        theme: HavenTheme.dark,
        home: FlowPuzzleScreen(puzzle: puzzle, controller: controller),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final board = tester.getRect(find.byKey(const ValueKey('flow-board')));
    final cell = board.width / spec.size;
    Offset center(GridPos point) {
      return board.topLeft +
          Offset((point.col + 0.5) * cell, (point.row + 0.5) * cell);
    }

    final solutions = <List<GridPos>>[
      const [
        GridPos(0, 2),
        GridPos(0, 1),
        GridPos(0, 0),
        GridPos(1, 0),
        GridPos(2, 0),
        GridPos(3, 0),
      ],
      const [GridPos(0, 3), GridPos(1, 3), GridPos(2, 3), GridPos(3, 3)],
      const [GridPos(1, 2), GridPos(1, 1), GridPos(2, 1), GridPos(3, 1)],
      const [GridPos(2, 2), GridPos(3, 2)],
    ];

    for (final path in solutions) {
      final gesture = await tester.startGesture(center(path.first));
      await tester.pump(const Duration(milliseconds: 40));
      for (final point in path.skip(1)) {
        await gesture.moveTo(center(point));
        await tester.pump(const Duration(milliseconds: 40));
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 120));
    }

    await tester.pump(const Duration(milliseconds: 900));
    expect(controller.starsFor(puzzle.id), greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('resolves the six-stream observatory weave', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = GameController(persist: false);
    final puzzle = rooms[3].puzzles[1];
    final spec = puzzle.spec as FlowSpec;

    await tester.pumpWidget(
      MaterialApp(
        theme: HavenTheme.dark,
        home: FlowPuzzleScreen(puzzle: puzzle, controller: controller),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final board = tester.getRect(find.byKey(const ValueKey('flow-board')));
    final cell = board.width / spec.size;
    Offset center(GridPos point) {
      return board.topLeft +
          Offset((point.col + 0.5) * cell, (point.row + 0.5) * cell);
    }

    const solutions = <List<GridPos>>[
      [
        GridPos(0, 4),
        GridPos(0, 3),
        GridPos(0, 2),
        GridPos(0, 1),
        GridPos(0, 0),
        GridPos(1, 0),
        GridPos(2, 0),
        GridPos(3, 0),
        GridPos(4, 0),
        GridPos(5, 0),
      ],
      [
        GridPos(0, 5),
        GridPos(1, 5),
        GridPos(2, 5),
        GridPos(3, 5),
        GridPos(4, 5),
        GridPos(5, 5),
      ],
      [
        GridPos(1, 4),
        GridPos(1, 3),
        GridPos(1, 2),
        GridPos(1, 1),
        GridPos(2, 1),
        GridPos(3, 1),
        GridPos(4, 1),
        GridPos(5, 1),
      ],
      [
        GridPos(2, 4),
        GridPos(2, 3),
        GridPos(2, 2),
        GridPos(3, 2),
        GridPos(4, 2),
        GridPos(5, 2),
      ],
      [GridPos(3, 4), GridPos(3, 3), GridPos(4, 3), GridPos(5, 3)],
      [GridPos(4, 4), GridPos(5, 4)],
    ];

    for (final path in solutions) {
      final gesture = await tester.startGesture(center(path.first));
      await tester.pump(const Duration(milliseconds: 35));
      for (final point in path.skip(1)) {
        await gesture.moveTo(center(point));
        await tester.pump(const Duration(milliseconds: 35));
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 90));
    }

    await tester.pump(const Duration(milliseconds: 900));
    expect(controller.starsFor(puzzle.id), greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
