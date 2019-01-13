import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

abstract class BackendResolver {
  GeneratorBackend resolve(List<GeneratorBackend> ctors, ActivationContext context);
}
