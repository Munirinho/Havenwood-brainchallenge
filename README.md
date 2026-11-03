# Havenwood

A cerebral restoration puzzle adventure built with Flutter. Six forgotten chambers hold eighteen
handcrafted challenges. Every solved puzzle brings Havenwood Manor back to life and deepens one of
four mental skills, with later chambers pushing memory, logic, weaving, and deduction much harder.

## The game

- **Echo Memory** - watch and repeat growing patterns of runes.
- **Lumen Logic** - a lights-out puzzle with a generated, always-solvable board.
- **Flow Weaving** - connect matching runes and fill every tile on the board.
- **Cipher Deduction** - break hidden rune sequences with exact and misplaced clues.
- **Chance Trials** - shuffle an endless list of randomized challenges in six moods, each with its
  own relaxing soundtrack.

Each chamber contains three challenges. Solving them restores illustrated rooms, unlocks the next
chamber, awards up to three stars, and raises your Memory, Logic, Spatial, and Deduction scores.
The Clocktower and The Sanctum extend the campaign with six master-level challenges, including
nine-rune memory trails, a coiled final loom, and a nine-rune repeated cipher. Progress is saved
locally with `shared_preferences`. Chance Trials are purely for fun and never change manor
progress.

## Soundscapes

Every chamber challenge has its own gentle looping ambient track, so all twelve levels sound
different. Chance trials add six mood-based soundtracks on top of those. Music starts softly on the
home screen, follows you into each puzzle, and resumes after you leave. The music button in the home
and puzzle headers toggles the soundtrack.

## Run it

```bash
flutter pub get
flutter run
```

For a web release:

```bash
flutter build web
```

## Tests

```bash
flutter analyze
flutter test
```

The suite covers the lights-out solver, cipher feedback, campaign progression, drag-to-weave flow
puzzles, persistence-free game logic, and responsive layouts at small and large phone sizes.

## Visual system

Havenwood uses a custom dark forest-and-candlelight palette, Cormorant Garamond and Manrope type,
procedural `CustomPainter` illustrations for the manor and chambers, animated fireflies, completion
confetti, and a branded launcher icon set.
