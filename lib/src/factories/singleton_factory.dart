import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class SingletonFactory<T> implements Factory<T> {
  final T _value;

  SingletonFactory(this._value);

  @override
  T get(ActivationContext context) {
    return _value;
  }

  @override
  T getDefaultValue() => _value;
}
