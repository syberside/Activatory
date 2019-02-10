import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class RandomArrayItemBackend implements GeneratorBackend<Object> {
  final List _values;

  RandomArrayItemBackend(this._values);

  @override
  Object get(ActivationContext context) {
    var index = context.random.nextInt(_values.length);
    return _values[index];
  }
}
