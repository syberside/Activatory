import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class NullFactory implements Factory<Null> {
  @override
  Null get(InternalActivationContext context) => null;

  @override
  Null getDefaultValue() => null;
}
