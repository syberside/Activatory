import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class RandomArrayItemFactory<T> implements Factory<T> {
  final List<T> _values;

  RandomArrayItemFactory(this._values);

  @override
  T get(ActivationContext context) {
    var index = context.random.nextInt(_values.length);
    return _values[index];
  }

  @override
  T getDefaultValue() => null;
}
