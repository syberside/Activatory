enum BackendResolutionStrategy {
  /// Take first available backend. If overrides was provided than first available is latest override.
  /// If no overrides are provided than first backend from created by BackendFactory backends will be used:
  ///  - random for primitive types;
  ///  - random enum value for enums;
  ///  - fist defined ctor for complex type/
  TakeFirstDefined,

  /// Take random named ctor for complex type.
  /// If type doesn't have public named ctor or is not complex type than exception will be thrown.
  TakeRandomNamedCtor,

  /// Take random available backend. If overrides was provided than random backend will be chosen from overrides.
  /// If no overrides are provided than random backend from created by BackendFactory backends will be used:
  ///  - random for primitive types;
  ///  - random enum value for enums;
  ///  - random defined ctor for complex type/
  TakeRandom,

  /// Take default ctor for complex type.
  /// It can be factory method, default ctor or const ctor.
  /// If type doesn't have public const ctor or is not complex type than exception will be thrown.
  TakeDefaultCtor
}
