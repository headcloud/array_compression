import 'dart:math';

import 'package:array_compression/range_node.dart';
import 'package:test/test.dart';

import 'random_generator.dart';

void main() {
  group('RangeNode', () {
    final RandomGenerator rnd = new RandomGenerator(new Random());

    group('constructor should create node with', () {
      int currentMSBIndex;
      RangeNode currentNode;

      setUp(() {
        currentMSBIndex = rnd.getRandomInt(11) - 1;
        currentNode = new RangeNode(currentMSBIndex);
      });

      test('empty low sub range', () {
        expect(currentNode.lowSubRange, isNull);
      });

      test('empty high sub range', (){
        expect(currentNode.highSubRange, isNull);
      });

      test('zero elements count', (){
        expect(currentNode.count, isZero);
      });

      test('fullness flag returning false', () {
        expect(currentNode.isFull, isFalse);
      });

      test('correct capacity based on msb index passed', () {
        expect(currentNode.capacity, equals(1 << (currentMSBIndex + 1)));
      });
    });

    group('msbIndex getter should return', () {
      test('same value as passed in constructor, for values greater than -1', () {
        final int correctMSB = rnd.getRandomInt(20) - 1;
        final RangeNode node = new RangeNode(correctMSB);
        expect(node.msbIndex, equals(correctMSB));
      });

      test('-1 if value passed to constructor less than -1', () {
        final int incorrectMSB = rnd.getRandomInt(20) - 20;
        final RangeNode node = new RangeNode(incorrectMSB);
        expect(node.msbIndex, equals(-1));
      });
    });

    group('put() method should', () {
      test('succeed if called on node which is not full', () {
        final RangeNode node = new RangeNode(-1);
        final actualResult = node.put(0);

        expect(actualResult, isTrue);
        expect(node.count, 1);
        expect(node.isFull, isTrue);
      });

      test('not succeed if called on full node', () {
        final RangeNode node = new RangeNode(-1)..put(0);
        final actualResult = node.put(0);

        expect(actualResult, isFalse);
      });

      test('recursively put values in sub range nodes', () {
        final RangeNode node = new RangeNode(0);
        node.put(0);
        node.put(1);

        expect(node.capacity, equals(2));
        expect(node.isFull, isTrue);
        expect(node.lowSubRange.isFull, isTrue);
        expect(node.highSubRange.isFull, isTrue);
      });
    });

    group('minValue getter should', () {
      test('return minimum existent value which was put in range', () {
        final RangeNode node = new RangeNode(2);
        node
          ..put(7)
          ..put(3)
          ..put(6);

        expect(node.minValue, equals(3));
      });
    });

    group('maxValue getter should', () {
      test('return maximum existent value which was put in range', () {
        final RangeNode node = new RangeNode(2);
        node
          ..put(5)
          ..put(3)
          ..put(6);

        expect(node.maxValue, equals(6));
      });
    });

    group('hasValue getter should', () {
      test('return TRUE for values being put in range and FALSE for others', () {
        final RangeNode node = new RangeNode(2);
        node
          ..put(5)
          ..put(3)
          ..put(6);

        expect(node.hasValue(0), isFalse);
        expect(node.hasValue(1), isFalse);
        expect(node.hasValue(2), isFalse);
        expect(node.hasValue(3), isTrue);
        expect(node.hasValue(4), isFalse);
        expect(node.hasValue(5), isTrue);
        expect(node.hasValue(6), isTrue);
        expect(node.hasValue(7), isFalse);
        expect(node.hasValue(8), isFalse);
      });
    });

    group('attach() method should', () {
      test('succeed if attached range is lower and does not overflows capacity', () {
        final RangeNode subRange = new RangeNode(1)..put(0)..put(3)..put(1);
        final RangeNode range = new RangeNode(2)..put(6);

        final actualResult = range.attach(subRange);

        expect(actualResult, isTrue);
        expect(range.count, equals(4));
        expect(range.minValue, isZero);
        expect(range.hasValue(3), isTrue);
        expect(range.hasValue(4), isFalse);
      });
    });

    group('stringify() method should return', () {
      test('0-2,5,8 when constructed in order: 0,5,1,2,8', () {
        final RangeNode range = new RangeNode(3)
          ..put(0)
          ..put(5)
          ..put(1)
          ..put(2)
          ..put(8);

        final String actualResult = range.stringify();
        print(actualResult);

        expect(actualResult, equals('0-2,5,8'));
      });

      test('0-1,3,5,8-9 when constructed in order: 5,1,3,9,0,8', () {
        final RangeNode range = new RangeNode(3)
          ..put(5)
          ..put(1)
          ..put(3)
          ..put(9)
          ..put(0)
          ..put(8);

        final String actualResult = range.stringify();
        print(actualResult);

        expect(actualResult, equals('0-1,3,5,8-9'));
      });

      test('1,3,5 when constructed in order: 3,5,1', () {
        final RangeNode range = new RangeNode(2)
          ..put(3)
          ..put(5)
          ..put(1);

        final String actualResult = range.stringify();
        print(actualResult);

        expect(actualResult, equals('1,3,5'));
      });

      test('0,2,6-8 when constructed in order: 6,0,2,7,8', () {
        final RangeNode range = new RangeNode(3)
          ..put(6)
          ..put(0)
          ..put(2)
          ..put(7)
          ..put(8);

        final String actualResult = range.stringify();
        print(actualResult);

        expect(actualResult, equals('0,2,6-8'));
      });
    });

    group('stringify() method for 4 elements capacity node should return', () {
      RangeNode node;

      setUp(() {
        node = new RangeNode(1);
      });

      test('empty string when constructed no elements in range', () {
        expect(node.stringify(), isEmpty);
      });

      test('correctly for first element in range', () {
        node.put(0);
        expect(node.stringify(), equals('0'));
      });

      test('correctly for second element in range', () {
        node.put(1);
        expect(node.stringify(), equals('1'));
      });

      test('correctly for third element in range', () {
        node.put(2);
        expect(node.stringify(), equals('2'));
      });

      test('correctly for forth element in range', () {
        node.put(3);
        expect(node.stringify(), equals('3'));
      });

      test('correctly for 0,1 elements in range', () {
        node..put(0)..put(1);
        expect(node.stringify(), equals('0-1'));
      });

      test('correctly for 0,2 elements in range', () {
        node..put(0)..put(2);
        expect(node.stringify(), equals('0,2'));
      });

      test('correctly for 0,3 elements in range', () {
        node..put(0)..put(3);
        expect(node.stringify(), equals('0,3'));
      });

      test('correctly for 1,2 elements in range', () {
        node..put(1)..put(2);
        expect(node.stringify(), equals('1-2'));
      });

      test('correctly for 1,3 elements in range', () {
        node..put(1)..put(3);
        expect(node.stringify(), equals('1,3'));
      });

      test('correctly for 2,3 elements in range', () {
        node..put(2)..put(3);
        expect(node.stringify(), equals('2-3'));
      });

      test('correctly for 0,1,2 elements in range', () {
        node..put(0)..put(1)..put(2);
        expect(node.stringify(), equals('0-2'));
      });

      test('correctly for 0,1,3 elements in range', () {
        node..put(0)..put(1)..put(3);
        expect(node.stringify(), equals('0-1,3'));
      });

      test('correctly for 0,2,3 elements in range', () {
        node..put(0)..put(2)..put(3);
        expect(node.stringify(), equals('0,2-3'));
      });

      test('correctly for 1,2,3 elements in range', () {
        node..put(1)..put(2)..put(3);
        expect(node.stringify(), equals('1-3'));
      });

      test('correctly for 0,1,2,3 elements in range', () {
        node..put(1)..put(2)..put(3)..put(0);
        expect(node.stringify(), equals('0-3'));
      });
    });
  });
}
