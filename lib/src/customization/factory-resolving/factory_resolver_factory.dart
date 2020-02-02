import 'dart:math';

import 'package:activatory/src/customization/factory-resolving/default_ctor_factory_resolver.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolver.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolving_strategy.dart';
import 'package:activatory/src/customization/factory-resolving/random_named_ctor_factory_resolver.dart';
import 'package:activatory/src/customization/factory-resolving/use_first_factory_resolver.dart';
import 'package:activatory/src/customization/factory-resolving/use_random_factory_resolver.dart';

class FactoryResolverFactory {
  final Random _random;
  final Map<FactoryResolvingStrategy, FactoryResolver> _cache = <FactoryResolvingStrategy, FactoryResolver>{};

  FactoryResolverFactory(
    this._random,
  );

  FactoryResolver getResolver(FactoryResolvingStrategy strategy) {
    var cached = _cache[strategy];
    if (cached == null) {
      cached = _create(strategy);
      _cache[strategy] = cached;
    }
    return cached;
  }

  FactoryResolver _create(FactoryResolvingStrategy strategy) {
    switch (strategy) {
      case FactoryResolvingStrategy.TakeFirstDefined:
        return new UseFirstFactoryResolver();
      case FactoryResolvingStrategy.TakeRandomNamedCtor:
        return new RandomNamedCtorFactoryResolver(_random);
      case FactoryResolvingStrategy.TakeRandom:
        return new UseRandomFactoryResolver(_random);
      case FactoryResolvingStrategy.TakeDefaultCtor:
        return new DefaultCtorFactoryResolver();
      default:
        throw ArgumentError.value(strategy);
    }
  }
}
