import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class RandomArrayItemBackend implements GeneratorBackend<Object> {
  final Random _random;
  final List _values;

  RandomArrayItemBackend(this._random, this._values);

  @override
  Object get(ActivationCtx context) {
    var index = _random.nextInt(_values.length);
    return _values[index];
  }
}