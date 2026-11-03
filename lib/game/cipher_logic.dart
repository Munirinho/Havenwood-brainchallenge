import 'dart:math';

class CipherResult {
  final List<int> guess;
  final int exact;
  final int near;

  const CipherResult({
    required this.guess,
    required this.exact,
    required this.near,
  });

  bool get solved => exact == guess.length;
}

CipherResult evaluateCipher(List<int> guess, List<int> secret) {
  var exact = 0;
  final guessRemainder = <int>[];
  final secretRemainder = <int>[];

  for (var i = 0; i < secret.length; i++) {
    if (guess[i] == secret[i]) {
      exact++;
    } else {
      guessRemainder.add(guess[i]);
      secretRemainder.add(secret[i]);
    }
  }

  final guessCounts = <int, int>{};
  for (final rune in guessRemainder) {
    guessCounts.update(rune, (value) => value + 1, ifAbsent: () => 1);
  }

  var near = 0;
  for (final rune in secretRemainder) {
    final available = guessCounts[rune] ?? 0;
    if (available > 0) {
      near++;
      guessCounts[rune] = available - 1;
    }
  }

  return CipherResult(
    guess: List.unmodifiable(guess),
    exact: exact,
    near: near,
  );
}

List<int> generateCipherSecret({
  required int runeCount,
  required int slots,
  required bool allowDuplicates,
  Random? random,
}) {
  final rng = random ?? Random();
  if (allowDuplicates) {
    return List<int>.generate(slots, (_) => rng.nextInt(runeCount));
  }
  final runes = List<int>.generate(runeCount, (index) => index)..shuffle(rng);
  return runes.take(slots).toList(growable: false);
}
