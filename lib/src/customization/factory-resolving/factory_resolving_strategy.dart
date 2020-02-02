import 'package:activatory/src/activation_exception.dart';

/// Defines strategy of selecting backend for activation.
enum FactoryResolvingStrategy {
  /// Take first available factory. If overrides was provided latest one will be used.
  /// If no overrides was provided will be used:
  ///  - random value factory for primitive types;
  ///  - random value factory enums;
  ///  - fist defined ctor for complex type.
  TakeFirstDefined,

  /// Take random named ctor for complex type.
  /// If type doesn't have public named ctor or type is not complex [ActivationException] will be thrown.
  TakeRandomNamedCtor,

  /// Take random available factory. If overrides was provided random one will be chosen from overrides.
  /// If no overrides are provided will be used:
  ///  - random value factory for primitive types;
  ///  - random value factory enums;
  ///  - random ctor for complex type.
  TakeRandom,

  /// Take default ctor for complex type.
  /// Default ctor is the one called during evaluating `new T()` expression. This can be factory, const or usual ctor.
  /// If type doesn't have public default ctor or type is not complex [ActivationException] will be thrown.
  TakeDefaultCtor
}
