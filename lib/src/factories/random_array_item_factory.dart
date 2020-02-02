import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RandomArrayItemFactory implements Factory<Object> {
  final List<Object> _values;

  RandomArrayItemFactory(this._values);

  @override
  Object get(InternalActivationContext context) {
    final index = context.random.nextInt(_values.length);
    return _values[index];
  }

  @override
  Object getDefaultValue() => null;
}
