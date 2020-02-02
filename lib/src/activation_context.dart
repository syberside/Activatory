import 'dart:math';

import 'package:activatory/src/value-generator/value_generator.dart';

abstract class ActivationContext implements ValueGenerator {
  Object get key;

  Random get random;
}
