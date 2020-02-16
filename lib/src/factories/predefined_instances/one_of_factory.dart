import 'dart:math';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class OneOfFactory<T> implements Factory<T> {
  final Random _random;
  final List<T> values;

  OneOfFactory(this._random, this.values);

  @override
  T get(InternalActivationContext context) {
    final index = _random.nextInt(values.length);
    return values[index];
  }

  @override
  T getDefaultValue() => null;
}
