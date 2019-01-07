import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/generator.dart';

class ExplicitBackend<T> implements GeneratorBackend<T> {
  final Generator<T> _generator;

  ExplicitBackend(this._generator);

  @override
  T get(ActivationContext context) {
    return _generator(context);
  }
}
