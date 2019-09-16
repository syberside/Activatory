/// Test data generator for Dart.
/// Create instance of activatory and use get method to gather test object.
/// Any required parameters will be substituted automatically and recursively.
/// For more information see https://github.com/syberside/Activatory/blob/master/README.md
library Activatory;

export 'src/activation_context.dart' show ActivationContext;
export 'src/activation_exception.dart' show ActivationException;
export 'src/activatory.dart' show Activatory;
export 'src/params_object.dart' show Params, Value, NullValue, v;
export 'src/post_activation/fields_auto_fill.dart' show FieldsAutoFill;
