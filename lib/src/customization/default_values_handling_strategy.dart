/// Defines strategy for default values handling.
enum DefaultValuesHandlingStrategy {
  /// All [null] values will be replaced with generated data.
  ReplaceNulls,

  /// All default argument values will be ignore.
  ReplaceAll,

  /// All default values will be used, even if value is [null]
  UseAll
}
