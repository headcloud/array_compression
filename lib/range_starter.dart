import 'dart:collection';

class RangeStarter extends LinkedListEntry<RangeStarter> {
  final int value;

  RangeStarter(this.value);

  bool operator <(RangeStarter other) {
    return other != null ?  value < other.value : false;
  }

  bool operator >(RangeStarter other) {
    return other != null ? value > other.value : true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RangeStarter &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;

}