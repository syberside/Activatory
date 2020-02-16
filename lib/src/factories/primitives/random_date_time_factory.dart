import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/primitives/random_duration_factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomDateTimeFactory implements Factory<DateTime> {
  final Random _random;

  RandomDateTimeFactory(this._random);

  @override
  DateTime get(InternalActivationContext context) {
    final duration = RandomDurationFactory.createRandom(_random);
    return DateTime.fromMillisecondsSinceEpoch(0).add(duration);
  }

  @override
  DateTime getDefaultValue() => DateTime.fromMillisecondsSinceEpoch(0);
}
