import 'dart:math';

import 'package:flutter/material.dart';

import 'models.dart';

const List<ChallengeStyle> challengeStyles = [
  ChallengeStyle(
    id: 'moonlit_hush',
    name: 'Moonlit Hush',
    tagline: 'Slow pads and distant silver chimes',
    soundtrack: 'audio/moonlit_hush.wav',
    accent: Color(0xFFB8A4FF),
    gradient: [Color(0xFFA793FF), Color(0xFF6250A8), Color(0xFF2A2350)],
    icon: Icons.nightlight_round,
  ),
  ChallengeStyle(
    id: 'golden_ember',
    name: 'Golden Ember',
    tagline: 'Warm embers and a low humming hush',
    soundtrack: 'audio/golden_ember.wav',
    accent: Color(0xFFF3C86B),
    gradient: [Color(0xFFFFDD96), Color(0xFFE0A544), Color(0xFF6B4A1F)],
    icon: Icons.local_fire_department_rounded,
  ),
  ChallengeStyle(
    id: 'aurora_drift',
    name: 'Aurora Drift',
    tagline: 'Cool northern light over glassy tones',
    soundtrack: 'audio/aurora_drift.wav',
    accent: Color(0xFF78C8FF),
    gradient: [Color(0xFFA9ECFF), Color(0xFF5AA9FF), Color(0xFF3E5BA8)],
    icon: Icons.auto_awesome_rounded,
  ),
  ChallengeStyle(
    id: 'sakura_breeze',
    name: 'Sakura Breeze',
    tagline: 'Petal-soft bells in a gentle breeze',
    soundtrack: 'audio/sakura_breeze.wav',
    accent: Color(0xFFFF9DD3),
    gradient: [Color(0xFFFFC7E4), Color(0xFFF58EC2), Color(0xFF8F4A72)],
    icon: Icons.local_florist_rounded,
  ),
  ChallengeStyle(
    id: 'tidal_calm',
    name: 'Tidal Calm',
    tagline: 'Deep water, slow waves, quiet breath',
    soundtrack: 'audio/tidal_calm.wav',
    accent: Color(0xFF67E4C4),
    gradient: [Color(0xFFA4F7E1), Color(0xFF4BC9C0), Color(0xFF1F5E66)],
    icon: Icons.water_drop_rounded,
  ),
  ChallengeStyle(
    id: 'meadow_dawn',
    name: 'Meadow Dawn',
    tagline: 'Morning air with a green-gold shimmer',
    soundtrack: 'audio/meadow_dawn.wav',
    accent: Color(0xFF8BE6A9),
    gradient: [Color(0xFFD8F9AE), Color(0xFF8BE6A9), Color(0xFF3D7A56)],
    icon: Icons.eco_rounded,
  ),
];

class GeneratedChallenge {
  final PuzzleDef puzzle;
  final ChallengeStyle style;

  const GeneratedChallenge({required this.puzzle, required this.style});

  Color get accent => style.accent;
}

class RandomChallengeFactory {
  final int seed;
  final Random _random;

  RandomChallengeFactory({int? seed})
    : this._(seed ?? DateTime.now().microsecondsSinceEpoch);

  RandomChallengeFactory._(this.seed) : _random = Random(seed);

  List<GeneratedChallenge> generate({int count = 9}) {
    final kinds = <PuzzleKind>[];
    while (kinds.length < count) {
      kinds.addAll(PuzzleKind.values);
    }
    kinds.shuffle(_random);

    final styles = List<ChallengeStyle>.of(challengeStyles)..shuffle(_random);

    return List.generate(count, (index) {
      final kind = kinds[index];
      final style = styles[index % styles.length];
      final difficulty = 1 + _random.nextInt(3);
      final title = _titleFor(kind);
      return GeneratedChallenge(
        style: style,
        puzzle: PuzzleDef(
          id: 'random-$seed-$index',
          kind: kind,
          title: title,
          subtitle: style.name,
          brief: _briefFor(kind),
          difficulty: difficulty,
          spec: _specFor(kind, difficulty),
          skin: style,
          isRandom: true,
        ),
      );
    });
  }

  PuzzleSpec _specFor(PuzzleKind kind, int difficulty) {
    return switch (kind) {
      PuzzleKind.echo => EchoSpec(
        padCount: switch (difficulty) {
          1 => 4,
          2 => 6,
          _ => 9,
        },
        rounds: 2 + difficulty,
        baseLength: difficulty == 3 ? 4 : 3,
      ),
      PuzzleKind.lumen => LumenSpec(
        size: 3 + difficulty,
        scrambles: 3 + difficulty + _random.nextInt(2),
      ),
      PuzzleKind.flow => FlowSpec(
        size: 3 + difficulty,
        pairs: _flowPairs(3 + difficulty),
        parSeconds: switch (difficulty) {
          1 => 95,
          2 => 140,
          _ => 190,
        },
      ),
      PuzzleKind.cipher => CipherSpec(
        runeCount: difficulty == 1 ? 5 : 6,
        slots: difficulty == 3 ? 4 : 3,
        allowDuplicates: difficulty == 3,
        maxAttempts: 5 + difficulty,
        parAttempts: 3 + difficulty,
      ),
    };
  }

  List<FlowPairSpec> _flowPairs(int size) {
    final cells = <GridPos>[];
    final startLeft = _random.nextBool();
    for (var row = 0; row < size; row++) {
      final leftToRight = row.isEven == startLeft;
      for (var step = 0; step < size; step++) {
        final col = leftToRight ? step : size - 1 - step;
        cells.add(GridPos(row, col));
      }
    }
    if (_random.nextBool()) {
      cells.setAll(0, cells.reversed.toList());
    }

    final pairCount = min(size, flowPalette.length);
    final lengths = List<int>.filled(pairCount, 2);
    var remaining = cells.length - pairCount * 2;
    while (remaining > 0) {
      lengths[_random.nextInt(pairCount)]++;
      remaining--;
    }

    final pairs = <FlowPairSpec>[];
    var cursor = 0;
    for (final length in lengths) {
      final start = cells[cursor];
      final end = cells[cursor + length - 1];
      pairs.add(FlowPairSpec(start, end));
      cursor += length;
    }
    pairs.shuffle(_random);
    return pairs;
  }

  String _titleFor(PuzzleKind kind) {
    final titles = _titleParts[kind]!;
    final first = titles.$1[_random.nextInt(titles.$1.length)];
    final second = titles.$2[_random.nextInt(titles.$2.length)];
    return '$first $second';
  }

  String _briefFor(PuzzleKind kind) {
    return switch (kind) {
      PuzzleKind.echo => 'Follow the drifting pattern and answer it in kind.',
      PuzzleKind.lumen =>
        'Touch the quiet lanterns until the whole board glows.',
      PuzzleKind.flow =>
        'Weave every matching pair and leave no tile untouched.',
      PuzzleKind.cipher =>
        'Read the clues and uncover the hidden rune sequence.',
    };
  }

  static const Map<PuzzleKind, (List<String>, List<String>)> _titleParts = {
    PuzzleKind.echo: (
      ['Moonlit', 'Velvet', 'Candlelit', 'Silver', 'Whispering', 'Drifting'],
      ['Echo', 'Pattern', 'Chorus', 'Reverie', 'Refrain', 'Lullaby'],
    ),
    PuzzleKind.lumen: (
      ['Ember', 'Golden', 'Dawn', 'Candle', 'Lantern', 'Sunlit'],
      ['Bloom', 'Circuit', 'Constellation', 'Glow', 'Awakening', 'Mosaic'],
    ),
    PuzzleKind.flow: (
      ['Winding', 'Tidal', 'Ivy', 'Riversong', 'Serpent', 'Amber'],
      ['Weave', 'Current', 'Path', 'Garden', 'Thread', 'Voyage'],
    ),
    PuzzleKind.cipher: (
      ['Hidden', 'Gilded', 'Secret', 'Starlit', 'Silent', 'Runic'],
      ['Cipher', 'Key', 'Lock', 'Code', 'Whisper', 'Riddle'],
    ),
  };
}
