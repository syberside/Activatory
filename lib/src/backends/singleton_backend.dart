import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class SingletonBackend<T> implements GeneratorBackend<T>{
  final T _value;

  SingletonBackend(this._value);

  @override
  T get(ActivationContext context) {
    return _value;
  }
}