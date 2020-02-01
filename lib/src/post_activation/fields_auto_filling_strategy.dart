/// Defines behavior for fields auto filling.
enum FieldsAutoFillingStrategy {
  /// Ignore fields
  None,

  /// Fill public fields
  Fields,

  /// Fill public fields and setters
  FieldsAndSetters,
}
