import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:havenwood/game/game_controller.dart';
import 'package:havenwood/main.dart';

void main() {
  testWidgets('opens the manor and its first chamber', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = GameController(persist: false);
    await controller.load();

    await tester.pumpWidget(HavenwoodApp(controller: controller));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('HAVENWOOD'), findsOneWidget);
    expect(find.text('Continue restoring'), findsOneWidget);

    await tester.tap(find.text('Continue restoring'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('The Atrium'), findsWidgets);
    expect(find.text('CHALLENGES'), findsOneWidget);
    expect(find.text('Chandelier Chorus'), findsOneWidget);
    expect(find.text('Windows of Dawn'), findsOneWidget);
  });
}
