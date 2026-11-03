int allLitMask(int size) => (1 << (size * size)) - 1;

int toggleMaskFor(int size, int index) {
  final row = index ~/ size;
  final col = index % size;
  var mask = 0;
  for (var dr = -1; dr <= 1; dr++) {
    for (var dc = -1; dc <= 1; dc++) {
      if ((dr.abs() + dc.abs()) != 1 && (dr != 0 || dc != 0)) continue;
      final r = row + dr;
      final c = col + dc;
      if (r < 0 || c < 0 || r >= size || c >= size) continue;
      mask |= 1 << (r * size + c);
    }
  }
  mask |= 1 << index;
  return mask;
}

int applyPress(int litMask, int size, int index) {
  return litMask ^ toggleMaskFor(size, index);
}

int? solveLightsOut({required int size, required int litMask, int? goalMask}) {
  final goal = goalMask ?? allLitMask(size);
  final variables = size * size;
  final rows = List<int>.generate(variables, (index) {
    var row = 0;
    for (var press = 0; press < variables; press++) {
      if ((toggleMaskFor(size, press) & (1 << index)) != 0) {
        row |= 1 << press;
      }
    }
    final lit = (litMask >> index) & 1;
    final wanted = (goal >> index) & 1;
    if (lit != wanted) row |= 1 << variables;
    return row;
  });

  var pivotRow = 0;
  final pivotColumns = <int>[];

  for (var col = 0; col < variables && pivotRow < variables; col++) {
    var found = -1;
    for (var row = pivotRow; row < variables; row++) {
      if (((rows[row] >> col) & 1) == 1) {
        found = row;
        break;
      }
    }
    if (found == -1) continue;

    final temp = rows[pivotRow];
    rows[pivotRow] = rows[found];
    rows[found] = temp;

    for (var row = 0; row < variables; row++) {
      if (row != pivotRow && ((rows[row] >> col) & 1) == 1) {
        rows[row] ^= rows[pivotRow];
      }
    }

    pivotColumns.add(col);
    pivotRow++;
  }

  final variableMask = (1 << variables) - 1;
  for (var row = pivotRow; row < variables; row++) {
    if ((rows[row] & variableMask) == 0 &&
        ((rows[row] >> variables) & 1) == 1) {
      return null;
    }
  }

  var solution = 0;
  for (var i = 0; i < pivotColumns.length; i++) {
    if (((rows[i] >> variables) & 1) == 1) {
      solution |= 1 << pivotColumns[i];
    }
  }
  return solution;
}
