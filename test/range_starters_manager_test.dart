import 'dart:math';

import 'package:array_compression/range_starters_manager.dart';
import 'package:test/test.dart';

import 'random_generator.dart';

void main() {
  group('RangeStartersManager', () {
    final RandomGenerator rnd = new RandomGenerator(new Random());
    RangeStarterManager rsManager;

    group('length', () {
      setUp(() {
        rsManager = RangeStarterManager();
      });

      test('should be 0 after creation', () {
        expect(rsManager.length, isZero);
      });

      test('should be 1 after adding first element', () {
        rsManager.add(rnd.getRandomInt(100));

        expect(rsManager.length, equals(1));
      });

      test('should be 5 after adding 5 elements', () {
        Iterable.generate(5, (_) => _).forEach(rsManager.add);

        expect(rsManager.length, equals(5));
      });
    });

    group('getOrderedStarters', () {
      setUp(() {
        rsManager = RangeStarterManager();
      });

      test('should return items in ascending order', () {
        final List<int> shuffled = [2, 8, 0, 16, 10];
        final List<int> ordered = [0, 2, 8, 10, 16];

        shuffled.forEach(rsManager.add);

        expect(rsManager.getOrderedStarters(), orderedEquals(ordered));
      });

      test('should return items in ascending order after remove', () {
        final List<int> shuffled = [2, 8, 0, 16, 10];
        final List<int> ordered = [0, 2, 10, 16];

        shuffled.forEach(rsManager.add);
        rsManager.remove(8);

        expect(rsManager.getOrderedStarters(), orderedEquals(ordered));
      });

      test('should return items in ascending order after remove', () {
        final List<int> shuffled = [2, 8, 0, 16, 10];
        final List<int> ordered = [0, 2, 5, 10, 16];

        shuffled.forEach(rsManager.add);
        rsManager.remove(8);
        rsManager.add(5);

        expect(rsManager.getOrderedStarters(), orderedEquals(ordered));
      });
    });
  });
}
