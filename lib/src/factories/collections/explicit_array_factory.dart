import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class ExplicitArrayFactory<T> extends Factory<List<T>> {
  @override
  List<T> get(ActivationContext context) {
    List<T> value = getDefaultValue();
    // Prevent from creating array of nulls.
    if (context.isVisitLimitReached(T)) {
      return value;
    }

    for (int i = 0; i < context.arraySize(T); i++) {
      value.add(context.createUntyped(T, context));
    }
    return value;
  }

  @override
  List<T> getDefaultValue() => new List<T>();
}
