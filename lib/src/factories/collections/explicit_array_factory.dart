import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class ExplicitArrayFactory<T> extends Factory<List<T>> {
  @override
  List<T> get(InternalActivationContext context) {
    final value = getDefaultValue();
    // Prevent from creating array of nulls.
    if (context.isVisitLimitReached(T)) {
      return value;
    }

    for (var i = 0; i < context.arraySize(T); i++) {
      value.add(context.createUntyped(T) as T);
    }
    return value;
  }

  @override
  List<T> getDefaultValue() => <T>[];
}
