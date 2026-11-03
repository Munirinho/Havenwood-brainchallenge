import 'package:flutter/material.dart';

enum PuzzleKind { echo, lumen, flow, cipher }

extension PuzzleKindDetails on PuzzleKind {
  String get label {
    return switch (this) {
      PuzzleKind.echo => 'Echo Memory',
      PuzzleKind.lumen => 'Lumen Logic',
      PuzzleKind.flow => 'Flow Weaving',
      PuzzleKind.cipher => 'Cipher Deduction',
    };
  }

  String get shortLabel {
    return switch (this) {
      PuzzleKind.echo => 'Memory',
      PuzzleKind.lumen => 'Logic',
      PuzzleKind.flow => 'Spatial',
      PuzzleKind.cipher => 'Deduction',
    };
  }

  IconData get icon {
    return switch (this) {
      PuzzleKind.echo => Icons.graphic_eq_rounded,
      PuzzleKind.lumen => Icons.lightbulb_outline_rounded,
      PuzzleKind.flow => Icons.route_rounded,
      PuzzleKind.cipher => Icons.key_rounded,
    };
  }

  Color get accent {
    return switch (this) {
      PuzzleKind.echo => const Color(0xFFB8A4FF),
      PuzzleKind.lumen => const Color(0xFFF3C86B),
      PuzzleKind.flow => const Color(0xFF67E4C4),
      PuzzleKind.cipher => const Color(0xFF78C8FF),
    };
  }

  List<String> get howTo {
    return switch (this) {
      PuzzleKind.echo => const [
        'Watch the runes glow in sequence.',
        'Repeat the sequence by tapping the same runes in order.',
        'Each round adds one more rune. You have three lanterns - a mistake dims one.',
      ],
      PuzzleKind.lumen => const [
        'Every lantern you touch toggles itself and its four neighbours.',
        'Your goal is to wake every lantern on the board.',
        'Use as few touches as possible. A hint shows one useful lantern.',
      ],
      PuzzleKind.flow => const [
        'Drag from a coloured rune to its twin.',
        'Paths may turn but not cross other colours.',
        'Fill every square of the board to complete the weave.',
      ],
      PuzzleKind.cipher => const [
        'Deduce the hidden sequence of runes.',
        'Gold marks a rune in the right place. Mint marks a rune that belongs elsewhere.',
        'Solve it before your attempts run out. Fewer attempts earn more stars.',
      ],
    };
  }

  String get celebration {
    return switch (this) {
      PuzzleKind.echo =>
        'Your memory holds the pattern like candlelight in glass.',
      PuzzleKind.lumen => 'Every dark corner surrenders to a thoughtful touch.',
      PuzzleKind.flow => 'The scattered threads find their way home.',
      PuzzleKind.cipher =>
        'The lock yields, and another secret belongs to you.',
    };
  }
}

class ChallengeStyle {
  final String id;
  final String name;
  final String tagline;
  final String soundtrack;
  final Color accent;
  final List<Color> gradient;
  final IconData icon;

  const ChallengeStyle({
    required this.id,
    required this.name,
    required this.tagline,
    required this.soundtrack,
    required this.accent,
    required this.gradient,
    required this.icon,
  });
}

class RuneStyle {
  final IconData icon;
  final Color color;
  final String name;

  const RuneStyle(this.icon, this.color, this.name);
}

const List<RuneStyle> runeStyles = [
  RuneStyle(Icons.nightlight_round, Color(0xFFB8A4FF), 'Moon'),
  RuneStyle(Icons.eco_rounded, Color(0xFF67E4C4), 'Leaf'),
  RuneStyle(Icons.local_fire_department_rounded, Color(0xFFFF8F8F), 'Flame'),
  RuneStyle(Icons.auto_awesome_rounded, Color(0xFFF3C86B), 'Star'),
  RuneStyle(Icons.water_drop_rounded, Color(0xFF78C8FF), 'Rain'),
  RuneStyle(Icons.local_florist_rounded, Color(0xFFFF9DD3), 'Bloom'),
  RuneStyle(Icons.bolt_rounded, Color(0xFFFFB36B), 'Spark'),
  RuneStyle(Icons.visibility_rounded, Color(0xFF8BE6A9), 'Eye'),
  RuneStyle(Icons.key_rounded, Color(0xFF91B4FF), 'Key'),
];

const List<Color> flowPalette = [
  Color(0xFF63E3C4),
  Color(0xFFFF8E8E),
  Color(0xFFF5C96C),
  Color(0xFFB7A2FF),
  Color(0xFF73CBFF),
  Color(0xFFFF9FD4),
];

class GridPos {
  final int row;
  final int col;

  const GridPos(this.row, this.col);

  @override
  bool operator ==(Object other) {
    return other is GridPos && other.row == row && other.col == col;
  }

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}

class FlowPairSpec {
  final GridPos a;
  final GridPos b;

  const FlowPairSpec(this.a, this.b);
}

sealed class PuzzleSpec {
  const PuzzleSpec();
}

class EchoSpec extends PuzzleSpec {
  final int padCount;
  final int rounds;
  final int baseLength;
  final int lengthStep;
  final int lives;

  const EchoSpec({
    required this.padCount,
    required this.rounds,
    required this.baseLength,
    this.lengthStep = 1,
    this.lives = 3,
  });
}

class LumenSpec extends PuzzleSpec {
  final int size;
  final int scrambles;

  const LumenSpec({required this.size, required this.scrambles});
}

class FlowSpec extends PuzzleSpec {
  final int size;
  final List<FlowPairSpec> pairs;
  final int parSeconds;

  const FlowSpec({
    required this.size,
    required this.pairs,
    required this.parSeconds,
  });
}

class CipherSpec extends PuzzleSpec {
  final int runeCount;
  final int slots;
  final bool allowDuplicates;
  final int maxAttempts;
  final int parAttempts;

  const CipherSpec({
    required this.runeCount,
    required this.slots,
    this.allowDuplicates = false,
    required this.maxAttempts,
    required this.parAttempts,
  });
}

class PuzzleDef {
  final String id;
  final PuzzleKind kind;
  final String title;
  final String subtitle;
  final String brief;
  final int difficulty;
  final PuzzleSpec spec;
  final ChallengeStyle? skin;
  final bool isRandom;
  final String? soundtrack;
  final String? soundtrackName;

  const PuzzleDef({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.brief,
    required this.difficulty,
    required this.spec,
    this.skin,
    this.isRandom = false,
    this.soundtrack,
    this.soundtrackName,
  });

  Color get accent => skin?.accent ?? kind.accent;
}

class RoomDef {
  final int index;
  final String name;
  final String caption;
  final String description;
  final IconData icon;
  final Color accent;
  final Color glow;
  final List<PuzzleDef> puzzles;
  final List<String> restorationNotes;

  const RoomDef({
    required this.index,
    required this.name,
    required this.caption,
    required this.description,
    required this.icon,
    required this.accent,
    required this.glow,
    required this.puzzles,
    required this.restorationNotes,
  });
}
