import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

abstract class BackendResolver {
  Factory resolve(List<Factory> ctors, ActivationContext context);
}
