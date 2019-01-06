import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/primitive_random_backends.dart';

class ActivationContextFactory {
  ActivationContext createDefault() {
    var random = new Random(DateTime.now().millisecondsSinceEpoch);
    var result = new ActivationContext(random);

    result.registerTyped(new RandomBoolBackend(random));
    result.registerTyped(new RandomIntBackend(random));
    result.registerTyped(new RandomDoubleBackend(random));
    result.registerTyped(new RandomStringBackend());
    result.registerTyped(new RandomDateTimeBackend(random));

    result.registerArray<bool>();
    result.registerArray<int>();
    result.registerArray<double>();
    result.registerArray<String>();
    result.registerArray<DateTime>();

    return result;
  }
}
