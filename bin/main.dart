
import 'package:array_compression/range_node.dart';

List<int> _array = [0, 3, 14, 9, 15, 2, 7, 13, 6, 1, 4, 10, 5, 8, 12, 11];

main(List<String> arguments) {
  final RangeNode collectedRanges = collectRanges(_array);

  print(collectedRanges.stringify());
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