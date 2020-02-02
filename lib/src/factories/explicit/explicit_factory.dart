import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/explicit/factory_delegate.dart';
import 'package:activatory/src/factories/factory.dart';

class ExplicitFactory<T> implements Factory<T> {
  final FactoryDelegate<T> _generator;

  ExplicitFactory(this._generator);

  @override
  T get(ActivationContext context) {
    return _generator(context);
  }

  @override
  T getDefaultValue() => null;
}
