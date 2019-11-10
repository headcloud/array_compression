import 'dart:collection';

import 'package:array_compression/range_starter.dart';

class RangeStarterManager {
  Set<RangeStarter> _existing = {};
  LinkedList<RangeStarter> _starters = new LinkedList<RangeStarter>();
  RangeStarter _lastAddedStarter;

  int get length => _starters.length;

  void add(int rangeStart) {
    final RangeStarter newStarter = new RangeStarter(rangeStart);

    if (_existing.contains(newStarter)) {
      throw ArgumentError.value(rangeStart, 'rangeStart', 'Value already exists');
    }

    if (_lastAddedStarter == null) {
      _starters.addFirst(newStarter);
    } else {
      if (newStarter < _lastAddedStarter) {
        RangeStarter successiveRangeStarter = _lastAddedStarter;
        while (successiveRangeStarter.previous != null && newStarter < successiveRangeStarter.previous) {
          successiveRangeStarter = successiveRangeStarter.previous;
        }

        successiveRangeStarter.insertBefore(newStarter);
      } else {
        RangeStarter precedingRangeStarter = _lastAddedStarter;
        while (precedingRangeStarter.next != null && newStarter > precedingRangeStarter.next) {
          precedingRangeStarter = precedingRangeStarter.next;
        }

        precedingRangeStarter.insertAfter(newStarter);
      }
    }

    _existing.add(newStarter);
    _lastAddedStarter = newStarter;
  }

  bool remove(int rangeStart) {
    RangeStarter toRemove = _existing.firstWhere((x) => x.value == rangeStart, orElse: () => null);

    if (toRemove == _lastAddedStarter) {
      _lastAddedStarter = _lastAddedStarter.previous ?? _lastAddedStarter.next;
    }

    return toRemove != null && _starters.remove(toRemove) && _existing.remove(toRemove);
  }

  Iterable<int> getOrderedStarters() => _starters.toList().map((x) => x.value);

  List<int> lookupNeighbours(int value) {
    final RangeStarter candidate = new RangeStarter(value);

    if (_existing.contains(candidate)) {
      throw ArgumentError.value(value, 'value', 'There is range starting from same value');
    }

    if (_lastAddedStarter == null) {
      return [null, null];
    }

    if (candidate < _lastAddedStarter) {
      RangeStarter successiveRangeStarter = _lastAddedStarter;
      while (successiveRangeStarter.previous != null && candidate < successiveRangeStarter.previous) {
        successiveRangeStarter = successiveRangeStarter.previous;
      }

      return [successiveRangeStarter?.previous?.value, successiveRangeStarter.value];
    }

    RangeStarter precedingRangeStarter = _lastAddedStarter;
    while (precedingRangeStarter.next != null && candidate > precedingRangeStarter.next) {
      precedingRangeStarter = precedingRangeStarter.next;
    }

    return [precedingRangeStarter.value, precedingRangeStarter?.next?.value];
  }
}
