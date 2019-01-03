import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/primitive_random_backends.dart';

class ActivationContextFactory {
  ActivationContext createDefault() {
    var random = new Random(DateTime.now().millisecondsSinceEpoch);
    Map<Type, GeneratorBackend> backends = {
      String: new RandomStringBackent(),
      int: new RandomIntBackend(random),
      double: new RandomDoubleBackent(random),
      bool: new RandomBoolBackent(random),
      DateTime: new RandomDateTimeBackent(random),
    };
    var result = new ActivationContext();
    for(var type in backends.keys){
      result.register(backends[type], type);
    }
    return result;
  }
}
