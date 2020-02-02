import 'dart:math';

import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/post-activation/fields_auto_filling_strategy.dart';
import 'package:activatory/src/value-generator/value_generator.dart';

class ActivationContext implements ValueGenerator {
  final ValueGenerator _valueGenerator;
  final Object _key;
  final Random _random;
  final List<Type> _stackTrace = new List<Type>();
  final TypeCustomizationRegistry _customizationsRegistry;

  ActivationContext(
    this._valueGenerator,
    this._random,
    this._key,
    this._customizationsRegistry,
  );

  Object get key => _key;

  Random get random => _random;

  int arraySize(Type type) => _customizationsRegistry.getCustomization(type, key: key).arraySize;

  DefaultValuesHandlingStrategy defaultValuesHandlingStrategy(Type type) =>
      _customizationsRegistry.getCustomization(type, key: key).defaultValuesHandlingStrategy;

  int _countVisits(Type type) => _stackTrace.where((t) => t == type).length;

  @override
  Object createUntyped(Type type, ActivationContext context) => _valueGenerator.createUntyped(type, this);

  @override
  T create<T>(ActivationContext context) => createUntyped(T, context);

  bool isVisitLimitReached(Type type) {
    final customization = _customizationsRegistry.getCustomization(type, key: key);
    return _countVisits(type) >= customization.maxRecursionLevel;
  }

  void notifyVisited(Type type) => _stackTrace.removeAt(_stackTrace.lastIndexOf(type));

  void notifyVisiting(Type type) => _stackTrace.add(type);

  FieldsAutoFillingStrategy fieldsAutoFill(Type type) =>
      _customizationsRegistry.getCustomization(type, key: key).fieldsAutoFillingStrategy;
}
