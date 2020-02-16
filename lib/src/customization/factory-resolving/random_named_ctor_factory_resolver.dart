import 'dart:math';

import 'package:activatory/src/customization/factory-resolving/factory_resolve_helper.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolver.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/ctor/reflective_object_factory.dart';
import 'package:activatory/src/factories/factory.dart';

class RandomNamedCtorFactoryResolver implements FactoryResolver {
  final Random _random;

  RandomNamedCtorFactoryResolver(this._random);

  @override
  Factory resolve(List<Factory> factories) {
    final filteredFactories = _filterWrappedFactories(factories).toList(growable: false);
    assertAnyFactoryFound(filteredFactories);
    final index = _random.nextInt(filteredFactories.length);
    return filteredFactories[index];
  }

  Iterable<Factory> _filterWrappedFactories(List<Factory> factories) sync* {
    for (final ctor in factories) {
      final unwrapped = unwrap(ctor);
      if (unwrapped is ReflectiveObjectFactory && unwrapped.ctorType == CtorType.Named) {
        yield ctor;
      }
    }
  }
}
