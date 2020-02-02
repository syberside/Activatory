import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomArrayItemFactory<T> implements Factory<T> {
  final List<T> _values;

  RandomArrayItemFactory(this._values);

  @override
  T get(InternalActivationContext context) {
    var index = context.random.nextInt(_values.length);
    return _values[index];
  }

  @override
  T getDefaultValue() => null;
}
