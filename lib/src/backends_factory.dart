import 'dart:math';
import 'dart:mirrors';

import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/argument_info.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/primitive_random_backends.dart';
import 'package:activatory/src/backends/random_array_item_backend.dart';
import 'package:activatory/src/ctor_info.dart';

typedef GeneratorBackend _GeneratorBackendFactory();

class BackendsFactory {
  Random _random;
  final Map<Type, _GeneratorBackendFactory> _predefinedFactories = new Map<Type, _GeneratorBackendFactory>();

  BackendsFactory(this._random) {
    _predefinedFactories[bool] = () => new RandomBoolBackend(_random);
    _predefinedFactories[int] = () => new RandomIntBackend(_random);
    _predefinedFactories[double] = () => new RandomDoubleBackend(_random);
    _predefinedFactories[String] = () => new RandomStringBackend();
    _predefinedFactories[DateTime] = () => new RandomDateTimeBackend(_random);

    _predefinedFactories[_getType<List<bool>>()] = () => new ArrayBackend<bool>();
    _predefinedFactories[_getType<List<int>>()] = () => new ArrayBackend<int>();
    _predefinedFactories[_getType<List<double>>()] = () => new ArrayBackend<double>();
    _predefinedFactories[_getType<List<String>>()] = () => new ArrayBackend<String>();
    _predefinedFactories[_getType<List<DateTime>>()] = () => new ArrayBackend<DateTime>();
  }

  GeneratorBackend create(Type type) {
    var predefinedFactory = _predefinedFactories[type];
    if (predefinedFactory != null) {
      return predefinedFactory();
    }

    var classMirror = reflectClass(type);
    if (classMirror.isEnum) {
      return _createEnumBackend(classMirror);
    } else {
      return _createComplexObjectBackend(classMirror, type);
    }
  }

  GeneratorBackend _createComplexObjectBackend(ClassMirror classMirror, Type type) {
    var ctorInfo = _resolveByCtor(classMirror);
    return new ComplexObjectBackend(ctorInfo);
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
        yield new CtorInfo(classMirror, method.constructorName, arguments);
      }
    }
  }

  Type _getType<T>() => T;

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
