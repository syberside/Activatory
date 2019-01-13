import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/ctor_info.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';

class DefaultCtorResolver implements BackendResolver {
  @override
  GeneratorBackend resolve(List<GeneratorBackend> ctors, ActivationContext context) {
    var filtered = ctors
        .map((c) => unwrap(c))
        .where((c) => c is ComplexObjectBackend && c.ctorType == CtorType.Default)
        .toList();
    assertBackendsNotEmpty(filtered);
    return filtered[0];
  }
}
