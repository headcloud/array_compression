import 'dart:math';

class RandomGenerator {
  static const int _CharOffset = 97;
  static const int _AlphabetLength = 26;
  static const int _MaxUnixTimestamp = 2147385600;

  final Random _random;

  RandomGenerator(this._random);

  bool getRandomBool() => _random.nextBool();

  DateTime getRandomDate() {
    final DateTime randomDateTime = _getRandomDateTime();
    return new DateTime(randomDateTime.year, randomDateTime.month, randomDateTime.day, 0, 0, 0);
  }

  Duration getRandomDaysDuration(int maxDays) => new Duration(days: _getRandomInt(maxDays));

  Duration getRandomHoursDuration(int maxHours) => new Duration(hours: _getRandomInt(maxHours));

  DateTime getRandomDateTime() => _getRandomDateTime();

  double getRandomDouble() => _random.nextDouble();

  int getRandomInt(int max) => _getRandomInt(max);

  String getRandomString(int length) {
    final StringBuffer buffer = new StringBuffer();

    for (int i = 0; i < length; i += 1) {
      buffer.writeCharCode(_random.nextInt(_AlphabetLength) + _CharOffset);
    }

    return buffer.toString();
  }

  DateTime _getRandomDateTime() =>  new DateTime.fromMicrosecondsSinceEpoch(_getRandomTimestamp());

  int getRandomTimestamp() => _getRandomTimestamp();

  int _getRandomTimestamp() => _random.nextInt(_MaxUnixTimestamp);

  int _getRandomInt(int max) => _random.nextInt(max);
}
