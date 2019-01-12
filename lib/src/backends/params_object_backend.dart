import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/params_object.dart';

class ParamsObjectBackend<TValue> implements GeneratorBackend<TValue>{
  TValue get(ActivationContext context) {
    var key = context.key as Params<TValue>;
    return key.resolve(context);
  }
}