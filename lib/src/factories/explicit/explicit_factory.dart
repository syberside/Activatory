import 'package:activatory/src/factories/explicit/factory_delegate.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class ExplicitFactory<T> implements Factory<T> {
  final FactoryDelegate<T> _generator;

  ExplicitFactory(this._generator);

  @override
  T get(InternalActivationContext context) {
    return _generator(context);
  }

  @override
  T getDefaultValue() => null;
}
