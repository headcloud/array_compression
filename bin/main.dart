
import 'dart:math';

import 'package:array_compression/compressor.dart';
import 'package:array_compression/range_node.dart';
import './../test/random_generator.dart';

List<int> _array = [3,2,8,17,18,13,12,20,0,5,21,16,4,10,22,19,11];

main(List<String> arguments) {
  //_array = {...getRandomGenerator().getRandomNumbers(0, 50, 100)}.toList();
  _array = Iterable.generate(100000, (i) => i).toList()..shuffle(new Random());

  final Stopwatch sw = new Stopwatch()..start();
  final RangeNode collectedRanges = collectRanges(_array);
  sw.stop();

  print('#Tree based compression in: ${sw.elapsed}');
  print(collectedRanges.stringify());

  final Stopwatch sw2 = new Stopwatch()..start();
  final Compressor arrCompressor = new Compressor();
  arrCompressor.compress(_array);
  sw2.stop();

  print('#HashSet and ranges reordering based compression in: ${sw2.elapsed}');
  print(arrCompressor.stringify());
}

RangeNode collectRanges(List<int> array) {
  int currentMax = array[0];
  RangeNode currentRoot = new RangeNode(currentMax.bitLength - 1);
  currentRoot.put(currentMax);

  int el;
  for (int i = 1; i < array.length; i++) {
    el = array[i];
    if (el > currentMax) {
      currentMax = el;
      final int newMSB = el.bitLength - 1;
      if (newMSB > currentRoot.msbIndex) {
        final RangeNode newRoot = new RangeNode(newMSB);
        newRoot.attach(currentRoot);
        currentRoot = newRoot;
      }
    }

    currentRoot.put(el);
  }

  return currentRoot;
}