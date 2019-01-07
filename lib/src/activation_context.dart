import 'dart:math';

import 'package:activatory/src/value_generator.dart';

class ActivationCtx implements ValueGenerator{
  final ValueGenerator _valueGenerator;
  final Object _key;
  final Random _random;

  ActivationCtx(this._valueGenerator, this._random, this._key);

  Object get key => _key;
  Random get random => _random;

  @override
  T createTyped<T>(ActivationCtx context) => _valueGenerator.createTyped<T>(context);

  @override
  Object create(Type type, ActivationCtx context) => _valueGenerator.create(type, context);
}