import 'package:activatory/src/activation_context.dart';

abstract class GeneratorBackend<T> {
  T get(ActivationCtx context);
}
