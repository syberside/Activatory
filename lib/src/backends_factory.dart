import 'dart:math';
import 'dart:mirrors';

import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/primitive_random_backends.dart';
import 'package:activatory/src/backends/random_array_item_backend.dart';
import 'package:activatory/src/backends/recurrency_limiter.dart';

typedef GeneratorBackend Factory();

class BackendsFactory{
  Random _random;
  final Map<Type, Factory> _predefinedFactories = new Map<Type, Factory>();

  BackendsFactory(this._random){
    _predefinedFactories[bool]= () => new RandomBoolBackend(_random);
    _predefinedFactories[int]= () => new RandomIntBackend(_random);
    _predefinedFactories[double]= () => new RandomDoubleBackend(_random);
    _predefinedFactories[String]= () => new RandomStringBackend();
    _predefinedFactories[DateTime]= () => new RandomDateTimeBackend(_random);

    _predefinedFactories[_getType<List<bool>>()]= () => new ArrayBackend<bool>();
    _predefinedFactories[_getType<List<int>>()]= () => new ArrayBackend<int>();
    _predefinedFactories[_getType<List<double>>()]= () => new ArrayBackend<double>();
    _predefinedFactories[_getType<List<String>>()]= () => new ArrayBackend<String>();
    _predefinedFactories[_getType<List<DateTime>>()]= () => new ArrayBackend<DateTime>();
  }

  GeneratorBackend create(Type type){
    var predefinedFactory = _predefinedFactories[type];
    if(predefinedFactory!=null) {
      return predefinedFactory();
    }

    var classMirror = reflectClass(type);
    if(classMirror.isEnum){
      return _createEnumBackend(classMirror);
    }
    else{
      return _createComplexObjectBackend(classMirror, type);
    }
  }

  Type _getType<T>() => T;

  GeneratorBackend _createEnumBackend(ClassMirror classMirror) {
    var declaration = classMirror.declarations.values
      .where((d)=>d is VariableMirror)
      .cast<VariableMirror>()
      .where((d)=> d.isStatic && d.simpleName == #values)
      .first;
    if(declaration==null){
      throw new ActivationException('Declaration of values for enum ${classMirror} not found');
    }

    final allValues = classMirror.getField(declaration.simpleName).reflectee as List;
    if(allValues.length==0){
      throw new ActivationException('Enum ${classMirror} values found but empty');
    }

    return new RandomArrayItemBackend(_random, allValues);
  }

  GeneratorBackend _createComplexObjectBackend(ClassMirror classMirror, Type type) {
    var ctorInfo = _resolveByCtor(classMirror);
    return new RecurrencyLimiter(type, new ComplexObjectBackend(ctorInfo), null);
  }

  Iterable<CtorInfo> _extractCtors(ClassMirror classMirror) sync* {
    var constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        var arguments = method.parameters
            .map((p) => new ArgumentInfo(p.type.reflectedType, p.defaultValue?.reflectee, p.isNamed, p.simpleName))
            .toList();
        yield new CtorInfo(classMirror, method.constructorName, arguments);
      }
    }
  }

  CtorInfo _resolveByCtor(ClassMirror classMirror) {
    if (classMirror.isAbstract) {
      throw new ActivationException("Cant create instance of abstract class ${classMirror}");
    }

    var ctors = _extractCtors(classMirror).toList();
    if (ctors.isEmpty) {
      throw new ActivationException("Cant find constructor for type ${classMirror}");
    }

    return ctors[0];
  }
}

class ArgumentInfo {
  Type _type;
  Object _defaultValue;

  bool _isNamed;
  Symbol _name;

  ArgumentInfo(this._type, this._defaultValue, this._isNamed, this._name);
  Object get defaultValue => _defaultValue;

  bool get isNamed => _isNamed;
  Symbol get name => _name;

  Type get type => _type;
}

class CtorInfo {
  final ClassMirror _classMirror;
  final Symbol _ctor;
  final List<ArgumentInfo> _args;

  CtorInfo(this._classMirror, this._ctor, this._args);

  ClassMirror get classMirror => _classMirror;
  Symbol get ctor => _ctor;
  List<ArgumentInfo> get args => _args;
}
