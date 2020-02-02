import 'package:activatory/src/customization/factory-resolving/factory_resolve_helper.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolver.dart';
import 'package:activatory/src/factories/factory.dart';

class UseFirstFactoryResolver implements FactoryResolver {
  @override
  Factory resolve(List<Factory> factories) {
    assertAnyFactoryFound(factories);
    return factories[0];
  }
}
