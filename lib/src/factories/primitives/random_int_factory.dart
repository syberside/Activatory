import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class RandomIntFactory implements Factory<int> {
  final Random _random;
  static const int _maxValue = 2 ^ 53;

  RandomIntFactory(this._random);

  @override
  int get(ActivationContext context) => _random.nextInt(_maxValue);

  @override
  int getDefaultValue() => 0;
}
