import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/ctor_info.dart';
import 'package:activatory/src/customization/backend_resolve_helper.dart';
import 'package:activatory/src/customization/backend_resolver.dart';

class RandomNamedCtorResolver implements BackendResolver{
  final Random _random;

  RandomNamedCtorResolver(this._random);

  @override
  GeneratorBackend resolve(List<GeneratorBackend> ctors, ActivationContext context) {
    ctors = ctors
        .map((c)=>unwrap(c))
        .where((c)=>c is ComplexObjectBackend && c.ctorType == CtorType.Named)
        .toList();
    assertBackendsNotEmpty(ctors);
    var index = _random.nextInt(ctors.length);
    return ctors[index];
  }
}
