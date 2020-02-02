import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/wrappers/factory_wrapper.dart';
import 'package:activatory/src/internal_activation_context.dart';

class RecursionLimiter implements Factory<Object>, FactoryWrapper<Object> {
  final Type _type;
  @override
  final Factory<Object> wrapped;

  RecursionLimiter(
    this._type,
    this.wrapped,
  );

  @override
  Object get(InternalActivationContext context) {
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
