import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/post-activation/fields_auto_filling_strategy.dart';
import 'package:activatory/src/value-generator/value_generator.dart';

class InternalActivationContext implements ActivationContext {
  final ValueGenerator _valueGenerator;
  final Object _key;
  final Random _random;
  final List<Type> _stackTrace = <Type>[];
  final TypeCustomizationRegistry _customizationsRegistry;

  InternalActivationContext(
    this._valueGenerator,
    this._random,
    this._key,
    this._customizationsRegistry,
  );

  @override
  Object get key => _key;

  @override
  Random get random => _random;

  int arraySize(Type type) => _customizationsRegistry.getCustomization(type, key: key).arraySize;

  DefaultValuesHandlingStrategy defaultValuesHandlingStrategy(Type type) =>
      _customizationsRegistry.getCustomization(type, key: key).defaultValuesHandlingStrategy;

  @override
  Object createUntyped(Type type, InternalActivationContext context) => _valueGenerator.createUntyped(type, this);

  @override
  T create<T>(InternalActivationContext context) => createUntyped(T, context) as T;

  FieldsAutoFillingStrategy fieldsAutoFill(Type type) =>
      _customizationsRegistry.getCustomization(type, key: key).fieldsAutoFillingStrategy;

  bool isVisitLimitReached(Type type) {
    final customization = _customizationsRegistry.getCustomization(type, key: key);
    return _countVisits(type) >= customization.maxRecursionLevel;
  }

  int _countVisits(Type type) => _stackTrace.where((t) => t == type).length;

  void notifyVisited(Type type) => _stackTrace.removeAt(_stackTrace.lastIndexOf(type));

  void notifyVisiting(Type type) => _stackTrace.add(type);
}
