import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../game/models.dart';
import 'environment_stub.dart' if (dart.library.io) 'environment_io.dart';

const String ambientTrack = 'audio/moonlit_hush.wav';
const String ambientName = 'Moonlit Hush';

String defaultSoundtrackFor(PuzzleKind kind) {
  return switch (kind) {
    PuzzleKind.echo => 'audio/moonlit_hush.wav',
    PuzzleKind.lumen => 'audio/golden_ember.wav',
    PuzzleKind.flow => 'audio/tidal_calm.wav',
    PuzzleKind.cipher => 'audio/aurora_drift.wav',
  };
}

String soundtrackFor(PuzzleDef puzzle) {
  return puzzle.soundtrack ??
      puzzle.skin?.soundtrack ??
      defaultSoundtrackFor(puzzle.kind);
}

String soundtrackNameFor(PuzzleDef puzzle) {
  return puzzle.soundtrackName ??
      puzzle.skin?.name ??
      switch (puzzle.kind) {
        PuzzleKind.echo => 'Moonlit Hush',
        PuzzleKind.lumen => 'Golden Ember',
        PuzzleKind.flow => 'Tidal Calm',
        PuzzleKind.cipher => 'Aurora Drift',
      };
}

class SoundtrackPlayer extends ChangeNotifier {
  SoundtrackPlayer._();

  static final SoundtrackPlayer instance = SoundtrackPlayer._();

  AudioPlayer? _player;
  String? _track;
  String? _loaded;
  String _name = ambientName;
  bool _muted = false;
  bool _ready = false;
  bool _disposed = false;

  bool get muted => _muted;
  String get currentName => _name;

  Future<void> playAmbient() async {
    _name = ambientName;
    await _play(ambientTrack);
  }

  Future<void> playFor(PuzzleDef puzzle) async {
    _name = soundtrackNameFor(puzzle);
    await _play(soundtrackFor(puzzle));
  }

  Future<void> leavePuzzle(PuzzleDef puzzle) async {
    if (_track != soundtrackFor(puzzle)) return;
    await playAmbient();
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    _notify();
    if (isAutomatedTest) return;
    if (_muted) {
      try {
        await _player?.pause();
      } catch (_) {
        _ready = false;
      }
      return;
    }
    final track = _track ?? ambientTrack;
    await _start(track);
  }

  Future<void> _play(String track) async {
    _track = track;
    if (isAutomatedTest || _muted) return;
    await _start(track);
  }

  Future<void> _start(String track) async {
    try {
      final player = _player ??= AudioPlayer();
      if (_ready && _loaded == track) {
        await player.resume();
        return;
      }
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0.8);
      await player.play(AssetSource(track));
      _loaded = track;
      _ready = true;
      _notify();
    } catch (_) {
      _ready = false;
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _player?.dispose();
    super.dispose();
  }
}
