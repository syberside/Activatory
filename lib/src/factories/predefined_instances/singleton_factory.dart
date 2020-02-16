import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class SingletonFactory<T> implements Factory<T> {
  final T _value;

  SingletonFactory(this._value);

  @override
  T get(InternalActivationContext context) {
    return _value;
  }

  @override
  T getDefaultValue() => _value;
}
