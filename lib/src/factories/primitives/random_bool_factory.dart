import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomBoolFactory implements Factory<bool> {
  final Random _random;

  RandomBoolFactory(this._random);

  @override
  bool get(InternalActivationContext context) => _random.nextBool();

  @override
  bool getDefaultValue() => false;
}
