import 'dart:math';

import 'package:activatory/src/customization/backend_resolution_strategy.dart';
import 'package:activatory/src/customization/backend_resolver.dart';
import 'package:activatory/src/customization/default_ctor_resolver.dart';
import 'package:activatory/src/customization/factory_ctor_resolver.dart';
import 'package:activatory/src/customization/first_ctor_resolve_strategy.dart';
import 'package:activatory/src/customization/random_named_ctor_resolver.dart';
import 'package:activatory/src/customization/random_resolver.dart';

class BackendResolverFactory {
  final Random _random;
  final Map<BackendResolutionStrategy, BackendResolver> _cache = new Map<BackendResolutionStrategy, BackendResolver>();

  BackendResolverFactory(this._random);

  BackendResolver get(BackendResolutionStrategy strategy) {
    var cached = _cache[strategy];
    if (cached == null) {
      cached = _create(strategy);
      _cache[strategy] = cached;
    }
    return cached;
  }

  BackendResolver _create(BackendResolutionStrategy strategy) {
    switch (strategy) {
      case BackendResolutionStrategy.TakeFirstDefined:
        return new FirstResolver();
      case BackendResolutionStrategy.TakeRandomNamedCtor:
        return new RandomNamedCtorResolver(_random);
      case BackendResolutionStrategy.TakeRandom:
        return new RandomResolver(_random);
      case BackendResolutionStrategy.TakeDefaultCtor:
        return new DefaultCtorResolver();
      case BackendResolutionStrategy.TakeFactory:
        return new FactoryCtorResolver();
      default:
        throw ArgumentError.value(strategy);
    }
  }
}
