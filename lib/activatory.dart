/// Test data generator for Dart.
/// Create instance of [Activatory] and use [Activatory.get] method to gather test object.
/// Any required parameters will be substituted automatically and recursively.
/// For more information see https://github.com/syberside/Activatory/blob/master/README.md

export 'src/activation_context.dart' show ActivationContext;
export 'src/activation_exception.dart' show ActivationException;
export 'src/activatory.dart' show Activatory;
export 'src/customization/backend_resolution_strategy.dart' show BackendResolutionStrategy;
export 'src/customization/default_values_handling_strategy.dart' show DefaultValuesHandlingStrategy;
export 'src/customization/type_customization.dart' show TypeCustomization;
export 'src/generator_delegate.dart' show GeneratorDelegate;
export 'src/post_activation/fields_auto_filling_strategy.dart' show FieldsAutoFillingStrategy;
