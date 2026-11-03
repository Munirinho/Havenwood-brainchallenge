import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:havenwood/game/cipher_logic.dart';
import 'package:havenwood/game/game_controller.dart';
import 'package:havenwood/game/levels.dart';
import 'package:havenwood/game/lights_out.dart';
import 'package:havenwood/game/models.dart';

void main() {
  group('Lights Out', () {
    test('solves generated boards for every chamber size', () {
      for (final size in [4, 5, 6]) {
        final random = Random(size);
        final goal = allLitMask(size);
        var board = goal;
        for (var i = 0; i < size * 2; i++) {
          board = applyPress(board, size, random.nextInt(size * size));
        }
        final solution = solveLightsOut(
          size: size,
          litMask: board,
          goalMask: goal,
        );
        expect(solution, isNotNull, reason: 'size $size should be solvable');
        var solved = board;
        for (var index = 0; index < size * size; index++) {
          if (((solution! >> index) & 1) == 1) {
            solved = applyPress(solved, size, index);
          }
        }
        expect(solved, goal);
      }
    });

    test('returns zero for an already solved board', () {
      expect(solveLightsOut(size: 5, litMask: allLitMask(5)), 0);
    });
  });

  group('Cipher feedback', () {
    test('reports exact matches', () {
      final result = evaluateCipher([0, 1, 2], [0, 1, 2]);
      expect(result.exact, 3);
      expect(result.near, 0);
      expect(result.solved, isTrue);
    });

    test('handles repeated runes without double counting', () {
      final result = evaluateCipher([1, 1, 2, 4], [1, 2, 1, 3]);
      expect(result.exact, 1);
      expect(result.near, 2);
    });

    test('generates unique secrets when duplicates are disabled', () {
      for (var i = 0; i < 50; i++) {
        final secret = generateCipherSecret(
          runeCount: 6,
          slots: 4,
          allowDuplicates: false,
        );
        expect(secret.toSet().length, 4);
        expect(secret.every((rune) => rune >= 0 && rune < 6), isTrue);
      }
    });
  });

  group('Level data', () {
    test('contains six chambers of three unique challenges', () {
      expect(rooms, hasLength(6));
      expect(allPuzzles, hasLength(18));
      expect(allPuzzles.map((puzzle) => puzzle.id).toSet().length, 18);
      for (final room in rooms) {
        expect(room.puzzles, hasLength(3));
        expect(room.restorationNotes, hasLength(3));
      }
    });

    test('every challenge has its own soundtrack', () {
      final tracks = allPuzzles.map((puzzle) => puzzle.soundtrack).toList();
      expect(tracks.every((track) => track != null), isTrue);
      expect(tracks.toSet(), hasLength(allPuzzles.length));
      expect(
        allPuzzles.every((puzzle) => puzzle.soundtrackName != null),
        isTrue,
      );
    });

    test('flow levels have valid, unique endpoints', () {
      for (final puzzle in allPuzzles.where((p) => p.kind == PuzzleKind.flow)) {
        final spec = puzzle.spec as FlowSpec;
        final endpoints = <GridPos>{};
        for (final pair in spec.pairs) {
          for (final point in [pair.a, pair.b]) {
            expect(point.row, inInclusiveRange(0, spec.size - 1));
            expect(point.col, inInclusiveRange(0, spec.size - 1));
            expect(endpoints.add(point), isTrue);
          }
        }
        expect(spec.pairs.length, lessThanOrEqualTo(flowPalette.length));
      }
    });
  });

  group('Game progression', () {
    test('completing a chamber unlocks the next one', () async {
      final controller = GameController(persist: false);
      expect(controller.isRoomUnlocked(rooms[1]), isFalse);
      expect(controller.nextPuzzle?.id, rooms[0].puzzles[0].id);

      for (final puzzle in rooms[0].puzzles) {
        await controller.recordResult(puzzle.id, 3);
      }

      expect(controller.isRoomComplete(rooms[0]), isTrue);
      expect(controller.isRoomUnlocked(rooms[1]), isTrue);
      expect(controller.totalStars, 9);
      expect(controller.totalCompleted, 3);
      expect(controller.isPuzzleUnlocked(rooms[1], 0), isTrue);
      expect(controller.isPuzzleUnlocked(rooms[1], 1), isFalse);
      expect(controller.skillScore(PuzzleKind.echo), closeTo(1 / 5, 0.0001));
    });

    test('keeps only the best star score', () async {
      final controller = GameController(persist: false);
      final id = rooms[0].puzzles[0].id;
      await controller.recordResult(id, 2);
      await controller.recordResult(id, 1);
      expect(controller.starsFor(id), 2);
      await controller.recordResult(id, 3);
      expect(controller.starsFor(id), 3);
    });
  });
}
