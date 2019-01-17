import 'package:activatory/src/customization/backend_resolution_strategy.dart';

class TypeCustomization {
  BackendResolutionStrategy resolutionStrategy = BackendResolutionStrategy.TakeFirstDefined;
  int arraySize = 3;
  int maxRecursion = 3;

  TypeCustomization clone() {
    return new TypeCustomization()
        ..arraySize = arraySize
        ..maxRecursion = maxRecursion
        ..resolutionStrategy = resolutionStrategy;
  }
}
