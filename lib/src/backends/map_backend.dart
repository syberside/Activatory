import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class MapBackend<K, V> extends GeneratorBackend<Map<K, V>> {
  @override
  Map<K, V> get(ActivationContext context) {
    final result = new Map<K, V>();
    if (context.isVisitLimitReached(K) || context.isVisitLimitReached(V)) {
      return result;
    }

    for (var i = 0; i < context.arraySize(V); i++) {
      final key = context.createTyped<K>(context);
      final value = context.createTyped<V>(context);
      result[key] = value;
    }
    return result;
  }
}
