import 'package:activatory/src/activation_exception.dart';

/// Defines strategy of selecting backend for activation.
enum BackendResolutionStrategy {
  /// Take first available backend. If overrides was provided latest one will be used.
  /// If no overrides are provided will be used:
  ///  - random value generator for primitive types;
  ///  - random value generator enums;
  ///  - fist defined ctor for complex type.
  TakeFirstDefined,

  /// Take random named ctor for complex type.
  /// If type doesn't have public named ctor or type is not complex [ActivationException] will be thrown.
  TakeRandomNamedCtor,

  /// Take random available backend. If overrides was provided random backend will be chosen from overrides.
  /// If no overrides are provided will be used:
  ///  - random value generator for primitive types;
  ///  - random value generator enums;
  ///  - random defined ctor for complex type.
  TakeRandom,

  /// Take default ctor for complex type.
  /// Default ctor is the one called during evaluating `new T()` expression. This can be factory, const or usual ctor.
  /// If type doesn't have public default ctor or type is not complex [ActivationException] will be thrown.
  TakeDefaultCtor
}
