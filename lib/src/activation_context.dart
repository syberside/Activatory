import 'dart:math';

import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/generator_delegate.dart';
import 'package:activatory/src/value_generator.dart';

class ActivationContext implements ValueGenerator{
  final ValueGenerator _valueGenerator;
  final Object _key;
  final Random _random;
  final List<Type> _stackTrace = new List<Type>();
  final TypeCustomizationRegistry _customizationsRegistry;


  ActivationContext(this._valueGenerator, this._random, this._key, this._customizationsRegistry);

  Object get key => _key;
  Random get random => _random;

  @override
  T createTyped<T>(ActivationContext context) => create(T, context);

  @override
  Object create(Type type, ActivationContext context) => _valueGenerator.create(type, context);

  int countVisits(Type type) => _stackTrace.where((t)=>t==type).length;

  bool isVisitLimitReached(Type type) {
    final customization = _customizationsRegistry.get(type);
    return countVisits(type)>customization.maxRecursion;
  }

  void notifyVisiting(Type type) => _stackTrace.add(type);

  void notifyVisited(Type type) => _stackTrace.removeAt(_stackTrace.lastIndexOf(type));

  int arraySize(Type type) => _customizationsRegistry.get(type).arraySize;

  GeneratorDelegate getArgumentOverride<T>(Type resolveType, Type argumentType){
    var customization = _customizationsRegistry.get(resolveType);
    var delegate = customization.getArgumentOverride(argumentType);
    return delegate;
  }
}