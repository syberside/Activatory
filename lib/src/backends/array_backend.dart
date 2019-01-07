import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class ArrayBackend<T> extends GeneratorBackend<List<T>> {
  ArrayBackend();

  @override
  List<T> get(ActivationCtx context) {
    var result = List<T>.generate(3, (_) => context.createTyped<T>(context));
    return result;
  }
}
