import 'package:activatory/src/customization/argument_customization.dart';
import 'package:activatory/src/customization/backend_resolution_strategy.dart';
import 'package:activatory/src/generator_delegate.dart';

class TypeCustomization {
  final Map<Type, ArgumentCustomization> _argumentCustomizations = new Map<Type, ArgumentCustomization>();

  BackendResolutionStrategy resolutionStrategy = BackendResolutionStrategy.TakeFirstDefined;
  int arraySize = 3;
  int maxRecursion = 3;

  ArgumentCustomization<T> whenArgument<T>(){
    var result = _argumentCustomizations[T];
    if(result == null){
      result = new ArgumentCustomization<T>();
      _argumentCustomizations[T] = result;
    }
    return result;
  }

  TypeCustomization clone() {
    return new TypeCustomization()
        ..arraySize = arraySize
        ..maxRecursion = maxRecursion
        ..resolutionStrategy = resolutionStrategy;
  }

  GeneratorDelegate getArgumentOverride(Type type){
    final customization = _argumentCustomizations[type];
    return customization?.than;
  }
}
