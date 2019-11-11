import 'dart:math';

RandomGenerator _randomGenerator;

RandomGenerator getRandomGenerator() {
  if (_randomGenerator == null) {
    final seed = new DateTime.now().millisecond;
    print('random seed: $seed');
    _randomGenerator = new RandomGenerator(new Random(seed));
  }

  return _randomGenerator;
}

class RandomGenerator {
  static const int _charOffset = 97;
  static const int _alphabetLength = 26;
  static const int _maxUnixTimestamp = 2147385600;

  static const int _printableCharsLength = 94;
  static const int _printableCharsOffset = 33;
  static const String _punctuationAlphabet = r'^!"#$%&()+,./:;<=>?@[\]`{|}-' "'";

  final Random _random;

  RandomGenerator(this._random);

  bool getRandomBool() => _random.nextBool();

  DateTime getRandomDate() {
    final randomDateTime = _getRandomDateTime();
    return new DateTime(randomDateTime.year, randomDateTime.month, randomDateTime.day, 0, 0, 0);
  }

  DateTime getRandomDateTime() => _getRandomDateTime();

  Duration getRandomDaysDuration(int maxDays) => new Duration(days: _getRandomInt(maxDays));

  double getRandomDouble() => _random.nextDouble();

  T getRandomElementOf<T>(List<T> elements) => elements.elementAt(_getRandomInt(elements.length));

  Duration getRandomHoursDuration(int maxHours) => new Duration(hours: _getRandomInt(maxHours));

  int getRandomInt(int maxExclusive, [int minInclusive = 0]) {
    var correctMax = max(minInclusive.abs(), maxExclusive.abs());
    final correctMin = min(minInclusive.abs(), maxExclusive.abs());

    correctMax = correctMax == correctMin ? correctMax + 1 : correctMax;
    return _getRandomInt(correctMax, minInclusive);
  }

  String getRandomString(int length) {
    final buffer = new StringBuffer();

    for (var i = 0; i < length; i++) {
      buffer.writeCharCode(_random.nextInt(_alphabetLength) + _charOffset);
    }

    return buffer.toString();
  }

  List<String> getRandomStrings({int maxWords = 20, int minWords = 2, int wordLength = 5}) {
    final wordsCount = getRandomGenerator().getRandomInt(maxWords, minWords);
    final result = <String>[];
    for (var i = 0; i < wordsCount; i++) {
      result.add(getRandomString(wordLength));
    }

    return result;
  }

  String getRandomExtendedString(int length) {
    final buffer = new StringBuffer();

    for (var i = 0; i < length; i += 1) {
      buffer.writeCharCode(_random.nextInt(_printableCharsLength) + _printableCharsOffset);
    }

    return buffer.toString();
  }

  String getRandomPunctuationCharacters(int length) {
    final buffer = new StringBuffer();
    const alphabetLength = _punctuationAlphabet.length;

    for (var i = 0; i < length; i += 1) {
      buffer.writeCharCode(_punctuationAlphabet.codeUnitAt(_random.nextInt(alphabetLength)));
    }

    return buffer.toString();
  }

  int getRandomTimestamp() => _getRandomTimestamp();

  Iterable<int> getRandomNumbers(int minInclusive, int maxExclusive, int requiredLength) sync* {
    int correctMax = max(minInclusive.abs(), maxExclusive.abs());
    final int correctMin = min(minInclusive.abs(), maxExclusive.abs());

    correctMax = correctMax == correctMin ? correctMax + 1 : correctMax;

    for(int i = 0; i < requiredLength; ++i) {
      yield _getRandomInt(correctMax, minInclusive);
    }
  }

  DateTime _getRandomDateTime() => new DateTime.fromMicrosecondsSinceEpoch(_getRandomTimestamp());

  int _getRandomInt(int max, [int min = 0]) => _random.nextInt(max - min) + min;

  int _getRandomTimestamp() => _random.nextInt(_maxUnixTimestamp);
}
