import 'dart:io';

bool get isAutomatedTest => Platform.environment.containsKey('FLUTTER_TEST');
