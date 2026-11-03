import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/soundtrack.dart';
import 'game/game_controller.dart';
import 'screens/home_screen.dart';
import 'theme/haven_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: HavenColors.ink,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final controller = GameController();
  await controller.load();
  runApp(HavenwoodApp(controller: controller));
}

class HavenwoodApp extends StatefulWidget {
  final GameController controller;

  const HavenwoodApp({super.key, required this.controller});

  @override
  State<HavenwoodApp> createState() => _HavenwoodAppState();
}

class _HavenwoodAppState extends State<HavenwoodApp> {
  @override
  void initState() {
    super.initState();
    SoundtrackPlayer.instance.playAmbient();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Havenwood',
      debugShowCheckedModeBanner: false,
      theme: HavenTheme.dark,
      home: HomeScreen(controller: widget.controller),
    );
  }
}
