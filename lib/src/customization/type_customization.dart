import 'package:activatory/src/customization/backend_resolution_strategy.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/post_activation/fields_auto_filling_strategy.dart';

/// Defines customization for type.
class TypeCustomization {
  BackendResolutionStrategy resolutionStrategy = BackendResolutionStrategy.TakeFirstDefined;

  int arraySize = 3;

  int maxRecursionLevel = 3;

  DefaultValuesHandlingStrategy defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceNulls;

  FieldsAutoFillingStrategy fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.Fields;

  TypeCustomization clone() {
    return new TypeCustomization()
      ..arraySize = arraySize
      ..maxRecursionLevel = maxRecursionLevel
      ..resolutionStrategy = resolutionStrategy
      ..defaultValuesHandlingStrategy = defaultValuesHandlingStrategy
      ..fieldsAutoFillingStrategy = fieldsAutoFillingStrategy;
  }
}
