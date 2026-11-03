import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:havenwood/game/game_controller.dart';
import 'package:havenwood/game/models.dart';
import 'package:havenwood/game/random_challenges.dart';
import 'package:havenwood/screens/random_challenges_screen.dart';
import 'package:havenwood/theme/haven_theme.dart';

void main() {
  final trials = RandomChallengeFactory(seed: 4242).generate();

  group('Random challenge factory', () {
    test('builds a varied set of unique trials', () {
      expect(trials, hasLength(9));
      expect(trials.map((trial) => trial.puzzle.id).toSet(), hasLength(9));
      expect(
        trials.map((trial) => trial.puzzle.kind).toSet(),
        containsAll(PuzzleKind.values),
      );
      expect(
        trials.map((trial) => trial.style.id).toSet().length,
        greaterThan(1),
      );
      for (final trial in trials) {
        expect(trial.puzzle.isRandom, isTrue);
        expect(trial.puzzle.skin, isNotNull);
        expect(trial.puzzle.accent, trial.style.accent);
        expect(challengeStyles, contains(trial.style));
      }
    });

    test('creates playable specs for every kind', () {
      for (final trial in trials) {
        final puzzle = trial.puzzle;
        expect(puzzle.difficulty, inInclusiveRange(1, 3));
        switch (puzzle.kind) {
          case PuzzleKind.echo:
            final spec = puzzle.spec as EchoSpec;
            expect(spec.padCount, anyOf(4, 6, 9));
            expect(spec.rounds, inInclusiveRange(3, 5));
            expect(spec.baseLength, inInclusiveRange(3, 4));
          case PuzzleKind.lumen:
            final spec = puzzle.spec as LumenSpec;
            expect(spec.size, inInclusiveRange(4, 6));
            expect(spec.scrambles, greaterThan(0));
          case PuzzleKind.flow:
            final spec = puzzle.spec as FlowSpec;
            expect(spec.size, inInclusiveRange(4, 6));
            expect(spec.pairs, hasLength(spec.size));
            expect(spec.pairs.length, lessThanOrEqualTo(flowPalette.length));
            final endpoints = <GridPos>{};
            for (final pair in spec.pairs) {
              for (final point in [pair.a, pair.b]) {
                expect(point.row, inInclusiveRange(0, spec.size - 1));
                expect(point.col, inInclusiveRange(0, spec.size - 1));
                expect(endpoints.add(point), isTrue);
              }
            }
          case PuzzleKind.cipher:
            final spec = puzzle.spec as CipherSpec;
            expect(spec.slots, lessThanOrEqualTo(spec.runeCount));
            expect(spec.parAttempts, greaterThan(0));
            expect(spec.maxAttempts, greaterThan(spec.parAttempts));
        }
      }
    });

    test('keeps chance trials out of campaign progress', () async {
      final controller = GameController(persist: false);
      await controller.recordResult(trials.first.puzzle.id, 3);
      expect(controller.totalStars, 0);
      expect(controller.totalCompleted, 0);
    });
  });

  testWidgets('chance trials lay out on a small phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: HavenTheme.dark,
        home: RandomChallengesScreen(
          controller: GameController(persist: false),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.takeException(), isNull);
    expect(find.text('Random brain games'), findsOneWidget);
    expect(find.text('Surprise me'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
