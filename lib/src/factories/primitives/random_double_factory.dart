import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomDoubleFactory implements Factory<double> {
  final Random _random;

  RandomDoubleFactory(this._random);

  @override
  double get(InternalActivationContext context) {
    return _random.nextDouble();
  }

  @override
  double getDefaultValue() => 0;
}
