import 'dart:math';

import 'package:Activatory/src/activation_context.dart';
import 'package:Activatory/src/backends/generator_backend.dart';
import 'package:Activatory/src/backends/primitive_random_backends.dart';

class ActivationContextFactory{
  static ActivationContext createDefault(){
    var random = new Random(DateTime.now().millisecondsSinceEpoch);
    Map<Type, GeneratorBackend> backends = {
      String: new RandomStringBackent(),
      int: new RandomIntBackend(random),
      double: new RandomDoubleBackent(random),
      bool: new RandomBoolBackent(random),
      DateTime: new RandomDateTimeBackent(random),
    };
    return new ActivationContext()
      ..registerAll(backends);
  }
}