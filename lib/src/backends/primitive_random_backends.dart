import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:uuid/uuid.dart';

class RandomBoolBackent implements GeneratorBackend<bool> {
  Random _random;

  RandomBoolBackent(this._random);

  @override
  bool get(ActivationContext context) {
    return _random.nextBool();
  }
}

class RandomDateTimeBackent implements GeneratorBackend<DateTime> {
  Random _random;
  int maxDays = 100 * 1000 * 1000;
  int maxMilliseconds = 24 * 60 * 60 * 1000;

  RandomDateTimeBackent(this._random);

  @override
  DateTime get(ActivationContext context) {
    var days = _random.nextInt(maxDays);
    var milisseconds = _random.nextInt(maxMilliseconds);
    return DateTime.fromMillisecondsSinceEpoch(0).add(new Duration(days: days, milliseconds: milisseconds));
  }
}

class RandomDoubleBackent implements GeneratorBackend<double> {
  Random _random;

  RandomDoubleBackent(this._random);

  @override
  double get(ActivationContext context) {
    return _random.nextDouble();
  }
}

class RandomIntBackend implements GeneratorBackend<int> {
  Random _random;
  int _maxValue = 2 ^ 53;

  RandomIntBackend(this._random);

  @override
  int get(ActivationContext context) {
    return _random.nextInt(_maxValue);
  }
}

class RandomStringBackent implements GeneratorBackend<String> {
  @override
  String get(ActivationContext context) {
    var uuid = new Uuid();
    return uuid.v1();
  }
}
