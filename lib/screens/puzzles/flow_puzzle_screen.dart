import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/game_controller.dart';
import '../../game/levels.dart';
import '../../game/models.dart';
import '../../widgets/haven_widgets.dart';
import 'puzzle_chrome.dart';

class FlowPuzzleScreen extends StatefulWidget {
  final PuzzleDef puzzle;
  final GameController controller;

  const FlowPuzzleScreen({
    super.key,
    required this.puzzle,
    required this.controller,
  });

  @override
  State<FlowPuzzleScreen> createState() => _FlowPuzzleScreenState();
}

class _FlowPuzzleScreenState extends State<FlowPuzzleScreen> {
  late final FlowSpec _spec;
  late final Map<GridPos, int> _endpoints;
  final Map<int, List<GridPos>> _paths = {};
  int? _activeColor;
  GridPos? _activeOther;
  late DateTime _startedAt;
  Timer? _ticker;
  bool _solved = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _spec = widget.puzzle.spec as FlowSpec;
    _endpoints = {};
    for (var i = 0; i < _spec.pairs.length; i++) {
      _endpoints[_spec.pairs[i].a] = i;
      _endpoints[_spec.pairs[i].b] = i;
    }
    _startedAt = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_solved) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _elapsedSeconds => DateTime.now().difference(_startedAt).inSeconds;

  String get _formattedTime {
    final seconds = _elapsedSeconds;
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  bool _isPairComplete(int color) {
    final path = _paths[color];
    if (path == null || path.length < 2) return false;
    final first = path.first;
    final last = path.last;
    if (first == last) return false;
    final pair = _spec.pairs[color];
    final endpoints = {pair.a, pair.b};
    return endpoints.contains(first) && endpoints.contains(last);
  }

  int get _completedPairs =>
      List.generate(_spec.pairs.length, _isPairComplete).where((e) => e).length;

  int get _filledCells =>
      _paths.values.fold(0, (total, path) => total + path.length);

  void _startDrag(Offset position, double side) {
    if (_solved) return;
    final cell = _cellAt(position, side);
    if (cell == null) return;
    final color = _endpoints[cell];
    if (color == null) return;
    final pair = _spec.pairs[color];
    final other = pair.a == cell ? pair.b : pair.a;
    setState(() {
      _paths[color] = [cell];
      _activeColor = color;
      _activeOther = other;
    });
    unawaited(HapticFeedback.selectionClick());
  }

  void _updateDrag(Offset position, double side) {
    final color = _activeColor;
    if (color == null || _solved) return;
    final target = _cellAt(position, side);
    if (target == null) return;
    final path = _paths[color];
    if (path == null || path.isEmpty) return;

    var guard = 0;
    while (_activeColor == color && path.isNotEmpty && path.last != target) {
      guard++;
      if (guard > _spec.size * _spec.size + 2) break;
      final last = path.last;
      final rowDelta = target.row - last.row;
      final colDelta = target.col - last.col;
      if (rowDelta == 0 && colDelta == 0) break;

      GridPos step;
      if (rowDelta.abs() >= colDelta.abs() && rowDelta != 0) {
        step = GridPos(last.row + rowDelta.sign, last.col);
      } else if (colDelta != 0) {
        step = GridPos(last.row, last.col + colDelta.sign);
      } else {
        break;
      }

      final progressed = _attemptStep(color, step);
      if (!progressed) break;
    }
  }

  bool _attemptStep(int color, GridPos next) {
    final path = _paths[color];
    if (path == null || path.isEmpty) return false;
    final last = path.last;
    if (next == last) return false;
    if (next.row < 0 ||
        next.col < 0 ||
        next.row >= _spec.size ||
        next.col >= _spec.size) {
      return false;
    }
    if ((next.row - last.row).abs() + (next.col - last.col).abs() != 1) {
      return false;
    }

    final ownIndex = path.indexOf(next);
    if (ownIndex >= 0) {
      if (ownIndex < path.length - 1) {
        setState(() {
          path.removeRange(ownIndex + 1, path.length);
        });
      }
      return true;
    }

    final endpointColor = _endpoints[next];
    if (endpointColor != null) {
      if (endpointColor != color) return false;
      if (next != _activeOther) return false;
      setState(() {
        path.add(next);
        _activeColor = null;
        _activeOther = null;
      });
      unawaited(HapticFeedback.mediumImpact());
      _checkSolved();
      return true;
    }

    if (_occupiedByOther(color, next)) return false;

    setState(() {
      path.add(next);
    });
    return true;
  }

  bool _occupiedByOther(int color, GridPos cell) {
    for (final entry in _paths.entries) {
      if (entry.key == color) continue;
      if (entry.value.contains(cell)) return true;
    }
    final endpointColor = _endpoints[cell];
    return endpointColor != null && endpointColor != color;
  }

  void _endDrag() {
    final color = _activeColor;
    if (color != null) {
      final path = _paths[color];
      setState(() {
        if (path != null && path.length < 2) {
          _paths.remove(color);
        }
        _activeColor = null;
        _activeOther = null;
      });
    }
    _checkSolved();
  }

  GridPos? _cellAt(Offset position, double side) {
    if (side <= 0) return null;
    final cellSize = side / _spec.size;
    final col = (position.dx / cellSize).floor().clamp(0, _spec.size - 1);
    final row = (position.dy / cellSize).floor().clamp(0, _spec.size - 1);
    return GridPos(row, col);
  }

  void _reset() {
    if (_solved) return;
    setState(() {
      _paths.clear();
      _activeColor = null;
      _activeOther = null;
      _startedAt = DateTime.now();
    });
    unawaited(HapticFeedback.lightImpact());
  }

  void _checkSolved() {
    if (_solved) return;
    if (_completedPairs != _spec.pairs.length) return;
    if (_filledCells != _spec.size * _spec.size) return;
    unawaited(_finish());
  }

  Future<void> _finish() async {
    if (_completing || _solved) return;
    _completing = true;
    _ticker?.cancel();
    setState(() => _solved = true);
    unawaited(HapticFeedback.heavyImpact());
    final elapsed = _elapsedSeconds;
    final stars = elapsed <= _spec.parSeconds
        ? 3
        : elapsed <= _spec.parSeconds * 2
        ? 2
        : 1;
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    await widget.controller.recordResult(widget.puzzle.id, stars);
    if (!mounted) return;
    final room = widget.puzzle.isRandom ? null : roomForPuzzle(widget.puzzle);
    await celebratePuzzle(
      context,
      puzzle: widget.puzzle,
      stars: stars,
      totalStars: widget.controller.totalStars,
      roomComplete: room != null && widget.controller.isRoomComplete(room),
      allComplete:
          room != null && widget.controller.totalCompleted == allPuzzles.length,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PuzzleShell(
      puzzle: widget.puzzle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PuzzleStatChip(
                            icon: Icons.timer_outlined,
                            label: 'Time',
                            value: _formattedTime,
                            accent: widget.puzzle.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PuzzleStatChip(
                            icon: Icons.hub_rounded,
                            label: 'Links',
                            value: '$_completedPairs/${_spec.pairs.length}',
                            accent: widget.puzzle.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PuzzleStatChip(
                            icon: Icons.grid_view_rounded,
                            label: 'Filled',
                            value: '$_filledCells/${_spec.size * _spec.size}',
                            accent: widget.puzzle.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Weave every pair together',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Drag between matching runes. Leave no square untouched.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.075),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.puzzle.accent.withValues(
                                      alpha: 0.09,
                                    ),
                                    blurRadius: 50,
                                    spreadRadius: -6,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: LayoutBuilder(
                                  builder: (context, boardConstraints) {
                                    final side = math.min(
                                      boardConstraints.maxWidth,
                                      boardConstraints.maxHeight,
                                    );
                                    return GestureDetector(
                                      key: const ValueKey('flow-board'),
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: (details) => _startDrag(
                                        details.localPosition,
                                        side,
                                      ),
                                      onPanUpdate: (details) => _updateDrag(
                                        details.localPosition,
                                        side,
                                      ),
                                      onPanEnd: (_) => _endDrag(),
                                      onPanCancel: _endDrag,
                                      child: SizedBox(
                                        width: side,
                                        height: side,
                                        child: CustomPaint(
                                          painter: _FlowBoardPainter(
                                            paths: _paths,
                                            endpoints: _endpoints,
                                            pairs: _spec.pairs,
                                            size: _spec.size,
                                            activeColor: _activeColor,
                                            completedColors: {
                                              for (
                                                var i = 0;
                                                i < _spec.pairs.length;
                                                i++
                                              )
                                                if (_isPairComplete(i)) i,
                                            },
                                            accent: widget.puzzle.accent,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 16,
                          color: widget.puzzle.accent,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Par ${_spec.parSeconds ~/ 60}:${(_spec.parSeconds % 60).toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        HavenButton(
                          label: 'Reset weave',
                          icon: Icons.restart_alt_rounded,
                          trailing: null,
                          height: 40,
                          muted: true,
                          onPressed: _reset,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlowBoardPainter extends CustomPainter {
  final Map<int, List<GridPos>> paths;
  final Map<GridPos, int> endpoints;
  final List<FlowPairSpec> pairs;
  final int size;
  final int? activeColor;
  final Set<int> completedColors;
  final Color accent;

  _FlowBoardPainter({
    required this.paths,
    required this.endpoints,
    required this.pairs,
    required this.size,
    required this.activeColor,
    required this.completedColors,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final side = math.min(canvasSize.width, canvasSize.height);
    final cellSize = side / size;
    final rect = Rect.fromLTWH(0, 0, side, side);
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF122034), const Color(0xFF080F1A)],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final cellFill = Paint()..color = Colors.white.withValues(alpha: 0.018);
    for (var row = 0; row < size; row++) {
      for (var col = 0; col < size; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              col * cellSize + 1.5,
              row * cellSize + 1.5,
              cellSize - 3,
              cellSize - 3,
            ),
            const Radius.circular(7),
          ),
          cellFill,
        );
      }
    }

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.8;
    for (var i = 1; i < size; i++) {
      final offset = i * cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, side), grid);
      canvas.drawLine(Offset(0, offset), Offset(side, offset), grid);
    }

    for (var color = 0; color < pairs.length; color++) {
      final path = paths[color];
      if (path == null || path.isEmpty) continue;
      _drawPath(canvas, color, path, cellSize);
    }

    for (final entry in endpoints.entries) {
      _drawEndpoint(
        canvas,
        entry.key,
        entry.value,
        cellSize,
        completedColors.contains(entry.value),
      );
    }

    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(22)),
      border,
    );
  }

  Offset _center(GridPos cell, double cellSize) {
    return Offset((cell.col + 0.5) * cellSize, (cell.row + 0.5) * cellSize);
  }

  void _drawPath(
    Canvas canvas,
    int color,
    List<GridPos> path,
    double cellSize,
  ) {
    if (path.length < 2) {
      if (activeColor == color) {
        _drawDragHalo(canvas, _center(path.first, cellSize), color, cellSize);
      }
      return;
    }
    final paintPath = Path();
    final first = _center(path.first, cellSize);
    paintPath.moveTo(first.dx, first.dy);
    for (var i = 1; i < path.length; i++) {
      final point = _center(path[i], cellSize);
      paintPath.lineTo(point.dx, point.dy);
    }

    final colorValue = flowPalette[color % flowPalette.length];
    final glow = Paint()
      ..color = colorValue.withValues(alpha: activeColor == color ? 0.34 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawPath(paintPath, glow);

    final backing = Paint()
      ..color = const Color(0xFF07101B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.36
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(paintPath, backing);

    final line = Paint()
      ..color = colorValue
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(paintPath, line);

    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(paintPath, shine);

    if (activeColor == color) {
      _drawDragHalo(canvas, _center(path.last, cellSize), color, cellSize);
    }
  }

  void _drawDragHalo(Canvas canvas, Offset center, int color, double cellSize) {
    final colorValue = flowPalette[color % flowPalette.length];
    canvas.drawCircle(
      center,
      cellSize * 0.28,
      Paint()
        ..color = colorValue.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawCircle(
      center,
      cellSize * 0.09,
      Paint()..color = Colors.white.withValues(alpha: 0.74),
    );
  }

  void _drawEndpoint(
    Canvas canvas,
    GridPos cell,
    int color,
    double cellSize,
    bool complete,
  ) {
    final colorValue = flowPalette[color % flowPalette.length];
    final center = _center(cell, cellSize);
    final radius = cellSize * 0.25;

    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()
        ..color = colorValue.withValues(alpha: complete ? 0.26 : 0.13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF0B1522));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colorValue.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cellSize * 0.045,
    );
    if (complete) {
      canvas.drawCircle(
        center,
        radius * 1.18,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    _drawShape(
      canvas,
      center,
      radius * 0.48,
      color,
      colorValue,
      activeColor == color,
    );
  }

  void _drawShape(
    Canvas canvas,
    Offset center,
    double radius,
    int color,
    Color colorValue,
    bool active,
  ) {
    final paint = Paint()
      ..color = colorValue
      ..style = PaintingStyle.fill;
    final path = Path();
    switch (color % 6) {
      case 0:
        canvas.drawCircle(center, radius, paint);
      case 1:
        path
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
      case 2:
        final rect = Rect.fromCenter(
          center: center,
          width: radius * 1.7,
          height: radius * 1.7,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.3)),
          paint,
        );
      case 3:
        path
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius * 0.8)
          ..lineTo(center.dx - radius, center.dy + radius * 0.8)
          ..close();
        canvas.drawPath(path, paint);
      case 4:
        path
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(
          center,
          radius * 0.34,
          Paint()..color = const Color(0xFF0B1522),
        );
      case 5:
        for (var i = 0; i < 10; i++) {
          final angle = -math.pi / 2 + i * math.pi / 5;
          final r = i.isEven ? radius : radius * 0.45;
          final point =
              center + Offset(math.cos(angle) * r, math.sin(angle) * r);
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
    }
    if (active) {
      canvas.drawCircle(
        center,
        radius * 1.75,
        Paint()
          ..color = colorValue.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlowBoardPainter oldDelegate) {
    return true;
  }
}
