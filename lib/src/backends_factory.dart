import 'dart:math';
import 'dart:mirrors';

import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/argument_info.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/map_backend.dart';
import 'package:activatory/src/backends/primitive_random_backends.dart';
import 'package:activatory/src/backends/random_array_item_backend.dart';
import 'package:activatory/src/ctor_info.dart';
import 'package:activatory/src/type_helper.dart';

typedef GeneratorBackend _GeneratorBackendFactory();

class BackendsFactory {
  Random _random;
  final Map<Type, _GeneratorBackendFactory> _predefinedFactories = new Map<Type, _GeneratorBackendFactory>();
  final _listMirror = reflectClass(List);


  BackendsFactory(this._random) {
    _predefinedFactories[bool] = () => new RandomBoolBackend(_random);
    _predefinedFactories[int] = () => new RandomIntBackend(_random);
    _predefinedFactories[double] = () => new RandomDoubleBackend(_random);
    _predefinedFactories[String] = () => new RandomStringBackend();
    _predefinedFactories[DateTime] = () => new RandomDateTimeBackend(_random);
    _predefinedFactories[Null] = () => new NullBackend();

    _predefinedFactories[getType<List<bool>>()] = () => new ArrayBackend<bool>();
    _predefinedFactories[getType<List<int>>()] = () => new ArrayBackend<int>();
    _predefinedFactories[getType<List<double>>()] = () => new ArrayBackend<double>();
    _predefinedFactories[getType<List<String>>()] = () => new ArrayBackend<String>();
    _predefinedFactories[getType<List<DateTime>>()] = () => new ArrayBackend<DateTime>();
    _predefinedFactories[getType<List<Null>>()] = () => new ArrayBackend<Null>();
  }

  List<GeneratorBackend> create(Type type) {
    var predefinedFactory = _predefinedFactories[type];
    if (predefinedFactory != null) {
      return [predefinedFactory()];
    }

    var classMirror = reflectClass(type);
    if (classMirror.isEnum) {
      return [_createEnumBackend(classMirror)];
    } else {
      return _createComplexObjectBackend(classMirror, type);
    }
  }

  List<GeneratorBackend> _createComplexObjectBackend(ClassMirror classMirror, Type type) {
    if(classMirror.isSubtypeOf(_listMirror)){
      throw new ActivationException('Arrays should be registrered explicitly');
    }
    if (classMirror.isAbstract) {
      throw new ActivationException("Cant create instance of abstract class ${classMirror}");
    }

    var ctors = _extractCtors(classMirror).toList();
    if (ctors.isEmpty) {
      throw new ActivationException("Cant find constructor for type ${classMirror}");
    }

    return ctors.map((ctorInfo) => new ComplexObjectBackend(ctorInfo)).toList();
  }

  GeneratorBackend _createEnumBackend(ClassMirror classMirror) {
    var declaration = classMirror.declarations.values
        .where((d) => d is VariableMirror)
        .cast<VariableMirror>()
        .where((d) => d.isStatic && d.simpleName == #values)
        .first;
    if (declaration == null) {
      throw new ActivationException('Declaration of values for enum ${classMirror} not found');
    }

    final allValues = classMirror.getField(declaration.simpleName).reflectee as List;
    if (allValues.length == 0) {
      throw new ActivationException('Enum ${classMirror} values found but empty');
    }

    return new RandomArrayItemBackend(_random, allValues);
  }

  Iterable<CtorInfo> _extractCtors(ClassMirror classMirror) sync* {
    var constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        var arguments = method.parameters
            .map((p) => new ArgumentInfo(p.type.reflectedType, p.defaultValue?.reflectee, p.isNamed, p.simpleName))
            .toList();
        var name = method.constructorName;
        CtorType type = _getCtorType(method);
        yield new CtorInfo(classMirror, name, arguments, type);
      }
    }
  }

  static const _emptySymbol = const Symbol('');

  CtorType _getCtorType(MethodMirror method){
    var name = method.constructorName;
    if(name != _emptySymbol){
      return CtorType.Named;
    }
    return CtorType.Default;
  }
}
