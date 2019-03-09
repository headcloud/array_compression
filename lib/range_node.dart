class RangeNode {
  final int _msbIndex;
  final int _capacity;

  RangeNode _lowSubRange;
  RangeNode _highSubRange;
  int _count = 0;

  RangeNode(int msb)
      : this._msbIndex = msb < -1 ? -1 : msb,
        this._capacity = 1 << ((msb < -1 ? -1 : msb) + 1),
        this._lowSubRange = null,
        this._highSubRange = null;

  int get capacity => _capacity;

  int get count => _count;

  RangeNode get highSubRange => _highSubRange;

  bool get isFull => _count == capacity;

  RangeNode get lowSubRange => _lowSubRange;

  int get maxValue {
    if (_msbIndex == -1 || _count == 0) {
      return 0;
    }

    if (_highSubRange != null) {
      return (1 << _msbIndex) + _highSubRange.maxValue;
    }

    return _lowSubRange.maxValue;
  }

  int get minValue {
    if (_msbIndex == -1 || _count == 0) {
      return 0;
    }

    if (_lowSubRange != null) {
      return _lowSubRange.minValue;
    }

    return (1 << _msbIndex) + _highSubRange.minValue;
  }

  int get msbIndex => _msbIndex;

  bool attach(RangeNode other) {
    if (other.msbIndex >= _msbIndex) {
      throw ArgumentError.value(other, 'other', 'It is possible to attach lower ranges only');
    }

    if (other.count > _capacity - _count) {
      throw ArgumentError.value(other, 'other', 'Impossible to attach range wich overflows capacity');
    }

    if (isFull) {
      return false;
    }

    _count += other.count;
    if (_lowSubRange != null) {
      if (_lowSubRange.msbIndex > other.msbIndex) {
        return _lowSubRange.attach(other);
      }

      return false; // can not attach other instead of existing low sub range
    }

    if (_msbIndex - 1 > other.msbIndex) {
      final RangeNode lowSubRange = _getLowSubRangeLazy();
      return lowSubRange.attach(other);
    }

    _lowSubRange = other; // other is new low sub range
    return true;
  }

  bool put(int rawValue) {
    if (rawValue > _capacity - 1) {
      throw ArgumentError.value(rawValue, 'rawValue', 'trying to put value wich MSB higher than range accepts');
    }

    if (isFull) {
      return false;
    }

    _count++;
    if (_msbIndex != -1) {
      final bool isLowSubRange = rawValue == 0 || rawValue & (1 << _msbIndex) == 0;
      final int subRangeValue = rawValue & (~(~0 << _msbIndex));

      final RangeNode subRangeNode = isLowSubRange ? _getLowSubRangeLazy() : _getHighSubRangeLazy();

      return subRangeNode.put(subRangeValue);
    }

    return true;
  }

  bool hasValue(int rawValue) {
    if (rawValue > _capacity - 1 || _count == 0) {
      return false;
    }

    if (_msbIndex == -1) {
      return true;
    }

    final bool searchLow = rawValue == 0 || rawValue & (1 << _msbIndex) == 0;
    final int subRangeValue = rawValue & (~(~0 << _msbIndex));
    final RangeNode subRange = searchLow ? _lowSubRange : _highSubRange;

    return subRange != null && subRange.hasValue(subRangeValue);
  }

  @override
  String toString() {
    return 'range for $capacity elements contains $_count';
  }

  RangeNode _getHighSubRangeLazy() {
    if (_msbIndex == -1) {
      throw UnsupportedError('could not have sub range in deepest possible RangeNode');
    }

    if (_highSubRange == null) {
      _highSubRange = new RangeNode(_msbIndex - 1);
    }

    return _highSubRange;
  }

  RangeNode _getLowSubRangeLazy() {
    if (_msbIndex == -1) {
      throw UnsupportedError('could not have sub range in deepest possible RangeNode');
    }

    if (_lowSubRange == null) {
      _lowSubRange = new RangeNode(_msbIndex - 1);
    }

    return _lowSubRange;
  }

  String stringify() {
    if (_count == 0) {
      return '';
    }

    final StringBuffer dumpBuffer = new StringBuffer();
    final _ValueRange finalRange = this._dumpRanges(dumpBuffer, _ValueRange.undefined(), 0);

    if (finalRange.isDefined) {
      if (finalRange.isZeroWidth) {
        dumpBuffer.write('${finalRange.max}');
      } else {
        dumpBuffer.write('${finalRange.min}-${finalRange.max}');
      }
    }

    return dumpBuffer.toString();
  }

  _ValueRange _dumpRanges(StringBuffer buffer, _ValueRange prevRange, int sum) {
    if (_msbIndex == -1) {

      if (prevRange.isDefined) {
        final bool isExpansion = sum - prevRange.max == 1;
        if (isExpansion) {
          return new _ValueRange(prevRange.min, sum);
        }

        final bool isJumpOver = sum - prevRange.max > 1;
        if (isJumpOver) {
          buffer.write('${prevRange.isZeroWidth ? '' : '${prevRange.min}-'}${prevRange.max},');
        }
      }

      return new _ValueRange(sum, sum);
    }

    if (isFull) {
      final int rangeMin = _lowSubRange.minValue + sum;
      final int rangeMax = (1 << _msbIndex) + _highSubRange.maxValue + sum;

      if (prevRange.isDefined) {
        final bool isExpansion = rangeMin - prevRange.max == 1;
        if (isExpansion) {
          return new _ValueRange(prevRange.min, rangeMax);
        }

        final bool isJumpOver = rangeMin - prevRange.max > 1;
        if (isJumpOver) {
          buffer.write('${prevRange.isZeroWidth ? '' : '${prevRange.min}-'}${prevRange.max},');
        }
      }

      return new _ValueRange(rangeMin, rangeMax);
    }

    var lowBorders = _lowSubRange?._dumpRanges(buffer, prevRange, sum) ?? prevRange;
    return _highSubRange?._dumpRanges(buffer, lowBorders,  (1 << _msbIndex) + sum) ?? lowBorders;
  }
}

class _ValueRange {
  final int min;
  final int max;

  bool get isDefined => min != null && max != null;

  bool get isZeroWidth => max == min;

  _ValueRange(this.min, this.max);
  _ValueRange.undefined(): this.min = null, this.max = null;
}
