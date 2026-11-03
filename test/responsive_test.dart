import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:havenwood/game/game_controller.dart';
import 'package:havenwood/game/levels.dart';
import 'package:havenwood/screens/home_screen.dart';
import 'package:havenwood/screens/puzzles/cipher_puzzle_screen.dart';
import 'package:havenwood/screens/puzzles/echo_puzzle_screen.dart';
import 'package:havenwood/screens/puzzles/flow_puzzle_screen.dart';
import 'package:havenwood/screens/puzzles/lumen_puzzle_screen.dart';
import 'package:havenwood/screens/room_screen.dart';
import 'package:havenwood/theme/haven_theme.dart';

void main() {
  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets(
      'all screens lay out at ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final controller = GameController(persist: false);

        Future<void> check(Widget screen) async {
          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: HavenTheme.dark,
              home: screen,
            ),
          );
          await tester.pump(const Duration(milliseconds: 350));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(seconds: 3));
        }

      await check(HomeScreen(controller: controller));
      await check(RoomScreen(room: rooms[0], controller: controller));
      await check(RoomScreen(room: rooms[4], controller: controller));
      await check(RoomScreen(room: rooms[5], controller: controller));
      await check(
        EchoPuzzleScreen(puzzle: rooms[0].puzzles[0], controller: controller),
      );
      await check(
        CipherPuzzleScreen(
          puzzle: rooms[5].puzzles[2],
          controller: controller,
        ),
      );
      await check(
        FlowPuzzleScreen(
          puzzle: rooms[5].puzzles[0],
          controller: controller,
        ),
      );
        await check(
          LumenPuzzleScreen(
            puzzle: rooms[1].puzzles[2],
            controller: controller,
          ),
        );
        await check(
          FlowPuzzleScreen(puzzle: rooms[2].puzzles[0], controller: controller),
        );
        await check(
          CipherPuzzleScreen(
            puzzle: rooms[2].puzzles[2],
            controller: controller,
          ),
        );
      },
    );
  }
}
