import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';
import 'package:activatory/src/factories/factory.dart';

class FirstResolver implements BackendResolver {
  @override
  Factory resolve(List<Factory> ctors, ActivationContext context) {
    assertBackendsNotEmpty(ctors);
    return ctors[0];
  }
}
