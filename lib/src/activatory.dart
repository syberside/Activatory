import 'dart:core';
import 'package:activatory/src/activation_context_factory.dart';
import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/explicit_backend.dart';

typedef T Generator<T>(ActivationContext activatory);

class Activatory {
  ActivationContext _context;
  Activatory() {
    _context = ActivationContextFactory.createDefault();
  }

  T getTyped<T>() {
    return get(T);
  }

  Object get(Type type) {
    var backend = _context.get(type);
    var value = backend.get(_context);
    return value;
  }

  void override<T>(Generator<T> generator){
    var backend = new ExplicitBackend(generator);
    _context.register(T, backend);
  }
}
