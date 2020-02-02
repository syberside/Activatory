import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class NullFactory implements Factory<Null> {
  @override
  Null get(ActivationContext context) => null;

  @override
  Null getDefaultValue() => null;
}
