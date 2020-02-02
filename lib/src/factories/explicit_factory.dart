import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/generator_delegate.dart';

class ExplicitFactory<T> implements Factory<T> {
  final GeneratorDelegate<T> _generator;

  ExplicitFactory(this._generator);

  @override
  T get(ActivationContext context) {
    return _generator(context);
  }

  @override
  T getDefaultValue() => null;
}
