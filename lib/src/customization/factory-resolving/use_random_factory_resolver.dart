import 'dart:math';

import 'package:activatory/src/customization/factory-resolving/factory_resolve_helper.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolver.dart';
import 'package:activatory/src/factories/factory.dart';

class UseRandomFactoryResolver implements FactoryResolver {
  final Random _random;

  UseRandomFactoryResolver(this._random);

  @override
  Factory resolve(List<Factory> factories) {
    assertAnyFactoryFound(factories);
    final index = _random.nextInt(factories.length);
    return factories[index];
  }
}
