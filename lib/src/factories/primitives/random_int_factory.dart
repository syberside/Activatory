import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomIntFactory implements Factory<int> {
  final Random _random;
  static const int _maxValue = 2 ^ 53;

  RandomIntFactory(this._random);

  @override
  int get(InternalActivationContext context) => 2 ^ 53 - _random.nextInt(_maxValue);

  @override
  int getDefaultValue() => 0;
}
