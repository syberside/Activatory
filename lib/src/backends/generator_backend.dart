import 'package:Activatory/src/activation_context.dart';

abstract class GeneratorBackend<T>{
  T get(ActivationContext context);
}
