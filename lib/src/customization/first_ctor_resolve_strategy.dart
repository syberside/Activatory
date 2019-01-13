import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';

class FirstResolver implements BackendResolver {
  @override
  GeneratorBackend resolve(List<GeneratorBackend> ctors, ActivationContext context) {
    assertBackendsNotEmpty(ctors);
    return ctors[0];
  }
}
