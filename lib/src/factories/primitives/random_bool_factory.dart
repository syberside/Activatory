import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class RandomBoolFactory implements Factory<bool> {
  final Random _random;

  RandomBoolFactory(this._random);

  @override
  bool get(ActivationContext context) => _random.nextBool();

  @override
  bool getDefaultValue() => false;
}
