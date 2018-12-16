import 'dart:math';
import 'package:Activatory/src/backends/complex_object_backend.dart';
import 'package:Activatory/src/backends/generator_backend.dart';
import 'package:Activatory/src/backends/primitive_random_backends.dart';

class ActivationContext{

  Map<Type, GeneratorBackend> exactBackends = new Map<Type, GeneratorBackend>();

  GeneratorBackend find(Type type){
    var result = exactBackends[type];
    if(result!=null){
      return result;
    }
    var complexObjectBackend = new ComplexObjectBackend(type);
    exactBackends[type] = complexObjectBackend;
    return complexObjectBackend;
  }

  void register(Type type, GeneratorBackend backend){
   exactBackends[type] = backend;
  }
  void registerAll(Map<Type, GeneratorBackend> backends){
    backends.forEach((type,backend)=>register(type, backend));
  }

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
