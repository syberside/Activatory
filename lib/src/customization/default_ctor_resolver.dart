import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/ctor/reflective_object_factory.dart';
import 'package:activatory/src/factories/factory.dart';

class DefaultCtorResolver implements BackendResolver {
  @override
  Factory resolve(List<Factory> ctors, ActivationContext context) {
    final filtered = _filterWrappedCtors(ctors).toList();
    assertBackendsNotEmpty(filtered);
    return filtered[0];
  }

  Iterable<Factory> _filterWrappedCtors(List<Factory> ctors) sync* {
    for (final ctor in ctors) {
      final unwrapped = unwrap(ctor);
      if (unwrapped is ReflectiveObjectFactory && unwrapped.ctorType == CtorType.Default) {
        yield ctor;
      }
    }
  }
}
