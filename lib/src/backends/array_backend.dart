import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class ArrayBackend<T> extends GeneratorBackend<List<T>> {
  ArrayBackend();

  @override
  List<T> get(ActivationContext context) {
    var backend = context.get(T);
    var result = List<T>.generate(3, (_) => backend.get(context));
    return result;
  }
}
