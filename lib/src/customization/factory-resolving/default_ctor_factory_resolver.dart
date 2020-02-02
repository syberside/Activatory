import 'package:activatory/src/customization/factory-resolving/factory_resolve_helper.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolver.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/ctor/reflective_object_factory.dart';
import 'package:activatory/src/factories/factory.dart';

class DefaultCtorFactoryResolver implements FactoryResolver {
  @override
  Factory resolve(List<Factory> factories) {
    final filtered = _filterWrappedFactories(factories).toList();
    assertAnyFactoryFound(filtered);
    return filtered[0];
  }

  Iterable<Factory> _filterWrappedFactories(List<Factory> factories) sync* {
    for (final ctor in factories) {
      final unwrapped = unwrap(ctor);
      if (unwrapped is ReflectiveObjectFactory && unwrapped.ctorType == CtorType.Default) {
        yield ctor;
      }
    }
  }
}
