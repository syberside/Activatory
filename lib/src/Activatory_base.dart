import 'dart:math';

import 'package:uuid/uuid.dart';
import 'dart:mirrors';

class ActivationContext{

  Map<Type, GeneratorBackend> _backends = new Map<Type, GeneratorBackend>();

  GeneratorBackend find(Type type){
    assert(type!=null);
    return _backends[type];
  }

  void register(Type type, GeneratorBackend backend){
    assert(type!=null);
    assert(backend!=null);
   _backends[type] = backend;
  }
  void registerAll(Map<Type, GeneratorBackend> backends){
    backends.forEach((type,backend)=>register(type, backend));
  }

  static ActivationContext createDefault(){
    var random = new Random(DateTime.now().millisecondsSinceEpoch);
    Map<Type, GeneratorBackend> backends = {
      String: new RandomStringBackent(),
      int: new RandomIntBackent(random),
      double: new RandomDoubleBackent(random),
      bool: new RandomBoolBackent(random),
      DateTime: new RandomDateTimeBackent(random),
    };
    return new ActivationContext()
      ..registerAll(backends);
  }
}

abstract class GeneratorBackend<T>{
  T get();
}

class RandomIntBackent implements GeneratorBackend<int>{
  Random _random;
  //TODO: define better max values (int.Max?!)
  int _maxValue = 100;

  RandomIntBackent(this._random);

  @override
  int get() {
    return _random.nextInt(_maxValue);
  }
}

class RandomStringBackent implements GeneratorBackend<String>{
  @override
  String get() {
    var uuid = new Uuid();
    return uuid.toString();
  }
}

class RandomBoolBackent implements GeneratorBackend<bool>{
  Random _random;

  RandomBoolBackent(this._random);

  @override
  bool get() {
    return _random.nextBool();
  }
}

class RandomDoubleBackent implements GeneratorBackend<double>{
  Random _random;

  RandomDoubleBackent(this._random);

  @override
  double get() {
    return _random.nextDouble();
  }
}

class RandomDateTimeBackent implements GeneratorBackend<DateTime>{
  Random _random;
  //TODO: define better max values (DateTime.Max?!)
  int maxDays = 100*1000*1000;
  int maxMilliseconds = 24*60*60*1000;

  RandomDateTimeBackent(this._random);

  @override
  DateTime get() {
    var days = _random.nextInt(maxDays);
    var milisseconds = _random.nextInt(maxMilliseconds);
    return DateTime.fromMillisecondsSinceEpoch(0).add(new Duration(days: days, milliseconds: milisseconds));
  }
}
