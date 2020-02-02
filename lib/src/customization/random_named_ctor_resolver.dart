import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/ctor/reflective_object_factory.dart';
import 'package:activatory/src/factories/factory.dart';

// TODO: Remove duplication between strategies
class RandomNamedCtorResolver implements BackendResolver {
  final Random _random;

  RandomNamedCtorResolver(this._random);

  @override
  Factory resolve(List<Factory> ctors, ActivationContext context) {
    ctors = _filterWrappedFactories(ctors).toList();
    assertBackendsNotEmpty(ctors);
    var index = _random.nextInt(ctors.length);
    return ctors[index];
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
