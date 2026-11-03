import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'levels.dart';
import 'models.dart';

class GameController extends ChangeNotifier {
  static const _storageKey = 'havenwood.progress.v1';

  final bool _persistEnabled;
  final Map<String, int> _bestStars = {};
  SharedPreferences? _preferences;
  bool _loaded = false;

  GameController({bool persist = true}) : _persistEnabled = persist;

  bool get loaded => _loaded;

  int starsFor(String puzzleId) => _bestStars[puzzleId] ?? 0;

  int get totalStars =>
      _bestStars.values.fold(0, (total, stars) => total + stars);

  int get totalCompleted =>
      allPuzzles.where((puzzle) => starsFor(puzzle.id) > 0).length;

  int get maximumStars => allPuzzles.length * 3;

  double get restorationProgress => totalCompleted / allPuzzles.length;

  int get cognitiveIndex {
    final scores = PuzzleKind.values
        .map((kind) => skillScore(kind))
        .toList(growable: false);
    final average = scores.reduce((a, b) => a + b) / scores.length;
    return (average * 100).round();
  }

  double skillScore(PuzzleKind kind) {
    final puzzles = allPuzzles.where((puzzle) => puzzle.kind == kind).toList();
    if (puzzles.isEmpty) return 0;
    final earned = puzzles.fold<int>(
      0,
      (total, puzzle) => total + starsFor(puzzle.id),
    );
    return earned / (puzzles.length * 3);
  }

  int solvedInRoom(RoomDef room) {
    return room.puzzles.where((puzzle) => starsFor(puzzle.id) > 0).length;
  }

  bool isRoomComplete(RoomDef room) =>
      solvedInRoom(room) == room.puzzles.length;

  bool isRoomUnlocked(RoomDef room) {
    if (room.index == 0) return true;
    for (var i = 0; i < room.index; i++) {
      if (!isRoomComplete(rooms[i])) return false;
    }
    return true;
  }

  bool isPuzzleUnlocked(RoomDef room, int puzzleIndex) {
    if (!isRoomUnlocked(room)) return false;
    for (var i = 0; i < puzzleIndex; i++) {
      if (starsFor(room.puzzles[i].id) == 0) return false;
    }
    return true;
  }

  RoomDef? get nextRoom {
    if (totalCompleted == allPuzzles.length) return null;
    for (final room in rooms) {
      if (isRoomUnlocked(room) && !isRoomComplete(room)) return room;
    }
    return null;
  }

  PuzzleDef? get nextPuzzle {
    for (final room in rooms) {
      if (!isRoomUnlocked(room)) continue;
      for (final puzzle in room.puzzles) {
        if (starsFor(puzzle.id) == 0) return puzzle;
      }
    }
    return null;
  }

  Future<void> load() async {
    if (_loaded) return;
    if (_persistEnabled) {
      try {
        _preferences = await SharedPreferences.getInstance();
        final raw = _preferences?.getString(_storageKey);
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            final storedStars = decoded['stars'];
            if (storedStars is Map<String, dynamic>) {
              for (final entry in storedStars.entries) {
                final value = entry.value;
                if (value is int) {
                  _bestStars[entry.key] = value.clamp(0, 3).toInt();
                }
              }
            }
          }
        }
      } catch (_) {
        _preferences = null;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> recordResult(String puzzleId, int stars) async {
    if (puzzleById(puzzleId) == null) return;
    final normalized = stars.clamp(0, 3).toInt();
    if (normalized <= starsFor(puzzleId)) return;
    _bestStars[puzzleId] = normalized;
    notifyListeners();
    await _save();
  }

  Future<void> resetProgress() async {
    _bestStars.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    if (!_persistEnabled) return;
    try {
      _preferences ??= await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'stars': _bestStars,
        'savedAt': DateTime.now().toIso8601String(),
      });
      await _preferences?.setString(_storageKey, payload);
    } catch (_) {
      _preferences = null;
    }
  }
}
