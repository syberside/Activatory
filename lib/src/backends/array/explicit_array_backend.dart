import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/array/array_backend.dart';

class ExplicitArrayBackend<T> extends ArrayBackend<T> {
  @override
  List<T> get(ActivationContext context) {
    List value = empty();
    if (context.isVisitLimitReached(T)) {
      return value;
    }

    for (int i = 0; i < context.arraySize(T); i++) {
      value.add(context.create(T, context));
    }
    return value;
  }

  @override
  List<T> empty() => new List<T>();
}
