import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class ArrayBackend<T> extends GeneratorBackend<List<T>> {
  @override
  List<T> get(ActivationContext context) {
    if(context.isVisitLimitReached(T)){
      return empty();
    }
    var result = List<T>.generate(context.arraySize(T), (_) => context.createTyped<T>(context));
    return result;
  }

  List<T> empty () => new List<T>();
}
