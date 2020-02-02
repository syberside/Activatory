import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/wrappers/factory_wrapper.dart';

class RecursionLimiter implements Factory<Object>, FactoryWrapper<Object> {
  final Type _type;
  final Factory wrapped;

  RecursionLimiter(
    this._type,
    this.wrapped,
  );

  @override
  Object get(ActivationContext context) {
    if (context.isVisitLimitReached(_type)) {
      return wrapped.getDefaultValue();
    }

    context.notifyVisiting(_type);
    final result = wrapped.get(context);
    context.notifyVisited(_type);
    return result;
  }

  @override
  Object getDefaultValue() => wrapped.getDefaultValue();
}
