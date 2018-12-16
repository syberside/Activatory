/// Support for doing something awesome.
///
/// More dartdocs go here.
import 'dart:core';
import 'package:activatory/src/activation_context_factory.dart';
import 'package:activatory/src/activation_context.dart';

class Activatory {
  ActivationContext _context;
  Activatory() {
    _context = ActivationContextFactory.createDefault();
  }

  T getTyped<T>() {
    return get(T);
  }

  Object get(Type type) {
    var backend = _context.find(type);
    if (backend == null) {
      throw new Exception('Backend for type ${type} not found');
    }
    var value = backend.get(_context);
    return value;
  }
}
