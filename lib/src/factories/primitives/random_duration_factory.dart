import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomDurationFactory implements Factory<Duration> {
  final Random _random;

  RandomDurationFactory(this._random);

  @override
  Duration get(InternalActivationContext context) => createRandom(_random);

  static Duration createRandom(Random random) => Duration(
        days: random.nextInt(100000000),
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
        seconds: random.nextInt(60),
        milliseconds: random.nextInt(1000),
        microseconds: random.nextInt(1000),
      );

  @override
  Duration getDefaultValue() => Duration.zero;
}
