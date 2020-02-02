import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';
import 'package:activatory/src/factories/factory.dart';

class RandomResolver implements BackendResolver {
  final Random _random;

  RandomResolver(this._random);

  @override
  Factory resolve(List<Factory> ctors, ActivationContext context) {
    assertBackendsNotEmpty(ctors);
    var index = _random.nextInt(ctors.length);
    return ctors[index];
  }
}
