import 'dart:math';

import 'package:activatory/src/value_generator.dart';

class ActivationContext implements ValueGenerator{
  final ValueGenerator _valueGenerator;
  final Object _key;
  final Random _random;
  final List<Type> _stackTrace = new List<Type>();
  final Settings _settings = Settings.defaults();

  ActivationContext(this._valueGenerator, this._random, this._key);

  Object get key => _key;
  Random get random => _random;

  @override
  T createTyped<T>(ActivationContext context) => create(T, context);

  @override
  Object create(Type type, ActivationContext context) => _valueGenerator.create(type, context);

  int countVisits(Type type) => _stackTrace.where((t)=>t==type).length;

  bool isVisitLimitReached(Type type) => countVisits(type)>=_settings.maxStackSizePerType;

  void notifyVisiting(Type type) => _stackTrace.add(type);

  void notifyVisited(Type type) => _stackTrace.removeAt(_stackTrace.lastIndexOf(type));
}

class Settings{
  final int maxStackSizePerType;

  Settings(this.maxStackSizePerType);

  const Settings.defaults():this(3);
}