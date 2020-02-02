import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomDateTimeFactory implements Factory<DateTime> {
  final Random _random;
  static const int _maxDays = 100 * 1000 * 1000;
  static const int _maxMilliseconds = 24 * 60 * 60 * 1000;

  RandomDateTimeFactory(this._random);

  @override
  DateTime get(InternalActivationContext context) {
    var days = _random.nextInt(_maxDays);
    var milliseconds = _random.nextInt(_maxMilliseconds);
    return DateTime.fromMillisecondsSinceEpoch(0).add(new Duration(days: days, milliseconds: milliseconds));
  }

  @override
  DateTime getDefaultValue() => DateTime.fromMillisecondsSinceEpoch(0);
}
