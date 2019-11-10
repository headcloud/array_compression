import 'dart:math';

class Range {
  final int from;
  final int to;

  Range(this.from, this.to);

  Range merge(Range other) {
    return new Range(min(from, other.from), max(to, other.to));
  }

  @override
  String toString() {
    if (from == to) {
      return from.toString();
    }

    return '$from-$to';
  }
}