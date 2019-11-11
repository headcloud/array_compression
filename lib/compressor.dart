import 'dart:collection';

import 'package:array_compression/range.dart';
import 'package:array_compression/range_starters_manager.dart';

class Compressor {
  HashMap<int, Range> _rangesMap = new HashMap<int, Range>();
  RangeStarterManager _rsManager = new RangeStarterManager();

  //List<int> _array = [3,2,8,17,18,13,12,20,0,5,21,16,4,10,22,19,11];
  bool compress(List<int> rawArray) {
    for(int element in rawArray) {
      final List<int> adjacentRangeStarters = _rsManager.lookupNeighbours(element);
      final int leftRangeKey = adjacentRangeStarters[0];
      final int rightRangeKey = adjacentRangeStarters[1];
      final Range _left = leftRangeKey != null ? _rangesMap[leftRangeKey] : null;
      final Range _right = rightRangeKey != null ? _rangesMap[rightRangeKey] : null;

      final Range elRange = new Range(element, element);

      if (_right != null && _right.from == element + 1) {
        _rangesMap.remove(rightRangeKey);
        _rsManager.remove(rightRangeKey);

        final Range merged = _right.merge(elRange);

        if (_left != null && _left.to == element - 1) {
          _rangesMap.update(leftRangeKey, (old) => old.merge(merged));
        } else {
          _rangesMap[element] = merged;
          _rsManager.add(element);
        }
      } else if (_left != null && _left.to == element -1) {
        _rangesMap.update(leftRangeKey, (old) => old.merge(elRange));
      } else {
        _rangesMap[element] = elRange;
        _rsManager.add(element);
      }
    }

    return _rangesMap.isNotEmpty;
  }

  String stringify() {
    final StringBuffer b = new StringBuffer();
    final List<int> rangeStarts = _rsManager.getOrderedStarters().toList(growable: false);

    for(int i = 0; i < rangeStarts.length; ++i) {
      if (i > 0) {
        b.write(',');
      }
      b.write(_rangesMap[rangeStarts[i]]);
    }

    return b.toString();
  }
}