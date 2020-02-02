import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class RandomDoubleFactory implements Factory<double> {
  final Random _random;

  RandomDoubleFactory(this._random);

  @override
  double get(ActivationContext context) {
    return _random.nextDouble();
  }

  @override
  double getDefaultValue() => 0;
}
