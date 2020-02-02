import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolving_strategy.dart';
import 'package:activatory/src/post-activation/fields_auto_filling_strategy.dart';

/// Defines customization for type.
class TypeCustomization {
  static const int _defaultRecursionLevel = 3;
  static const int _defaultArraySize = 3;

  FactoryResolvingStrategy resolvingStrategy = FactoryResolvingStrategy.TakeFirstDefined;

  int arraySize = _defaultArraySize;

  int maxRecursionLevel = _defaultRecursionLevel;

  DefaultValuesHandlingStrategy defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceNulls;

  FieldsAutoFillingStrategy fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.Fields;

  TypeCustomization clone() {
    return new TypeCustomization()
      ..arraySize = arraySize
      ..maxRecursionLevel = maxRecursionLevel
      ..resolvingStrategy = resolvingStrategy
      ..defaultValuesHandlingStrategy = defaultValuesHandlingStrategy
      ..fieldsAutoFillingStrategy = fieldsAutoFillingStrategy;
  }
}
