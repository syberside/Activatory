/// Support for doing something awesome.
///
/// More dartdocs go here.
library Activatory;

export 'src/Activatory_base.dart';

import 'dart:core';
import 'dart:math';
import 'package:Activatory/Activatory.dart';
import 'package:uuid/uuid.dart';

class Activatory{
  ActivationContext _context;
  Activatory(){
    _context = ActivationContext.createDefault();
  }

  T getTyped<T>(){
    return get(T);
  }

  Object get(Type type){
    var backend = _context.find(type);
    if(backend == null){
      throw new Exception('Backend for type ${type} not found');
    }
    var value = backend.get(_context);
    return value;
  }
}

