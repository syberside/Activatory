import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';

class RandomResolver implements BackendResolver {
  final Random _random;

  RandomResolver(this._random);

  @override
  GeneratorBackend resolve(List<GeneratorBackend> ctors, ActivationContext context) {
    assertBackendsNotEmpty(ctors);
    var index = _random.nextInt(ctors.length);
    return ctors[index];
  }
}
