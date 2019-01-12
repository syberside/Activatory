/// Test data generator for Dart.
/// Create instance of activatory and use get method to gather test object.
/// Any required parameters will be substituted automatically and recursively.
/// For more information see https://github.com/syberside/Activatory/blob/master/README.md
library Activatory;

export 'src/activatory.dart' show Activatory;
export 'src/activation_exception.dart' show ActivationException;
export 'src/activation_context.dart' show ActivationContext;
export 'src/params_object.dart' show Params, DelegateParamsObj, ClosureParamsObj, Value, NullValue, v;