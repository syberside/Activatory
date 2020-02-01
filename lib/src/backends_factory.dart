import 'dart:math';
import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/argument_info.dart';
import 'package:activatory/src/backends/array/explicit_array_backend.dart';
import 'package:activatory/src/backends/array/reflective_array_backend.dart';
import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/map_backend.dart';
import 'package:activatory/src/backends/primitive_random_backends.dart';
import 'package:activatory/src/backends/random_array_item_backend.dart';
import 'package:activatory/src/ctor_info.dart';
import 'package:activatory/src/type_helper.dart';

typedef GeneratorBackend _GeneratorBackendFactory();

class BackendsFactory {
  static const _emptySymbol = const Symbol('');
  Random _random;
  final Map<Type, _GeneratorBackendFactory> _predefinedFactories = new Map<Type, _GeneratorBackendFactory>();

  final _listMirror = reflectClass(List);
  final _mapMirror = reflectClass(Map);

  BackendsFactory(this._random) {
    _predefinedFactories[bool] = () => new RandomBoolBackend(_random);
    _predefinedFactories[int] = () => new RandomIntBackend(_random);
    _predefinedFactories[double] = () => new RandomDoubleBackend(_random);
    _predefinedFactories[String] = () => new RandomStringBackend();
    _predefinedFactories[DateTime] = () => new RandomDateTimeBackend(_random);
    _predefinedFactories[Null] = () => new NullBackend();

    _predefinedFactories[getType<List<bool>>()] = () => new ExplicitArrayBackend<bool>();
    _predefinedFactories[getType<List<int>>()] = () => new ExplicitArrayBackend<int>();
    _predefinedFactories[getType<List<double>>()] = () => new ExplicitArrayBackend<double>();
    _predefinedFactories[getType<List<String>>()] = () => new ExplicitArrayBackend<String>();
    _predefinedFactories[getType<List<DateTime>>()] = () => new ExplicitArrayBackend<DateTime>();
    _predefinedFactories[getType<List<Null>>()] = () => new ExplicitArrayBackend<Null>();
  }

  List<GeneratorBackend> create(Type type, ActivationContext context) {
    var predefinedFactory = _predefinedFactories[type];
    if (predefinedFactory != null) {
      return [predefinedFactory()];
    }
    var classMirror = reflectType(type) as ClassMirror;
    if (classMirror.isEnum) {
      return [_createEnumBackend(classMirror)];
    } else {
      return _createComplexObjectBackend(classMirror, type);
    }
  }

  List<GeneratorBackend> _createComplexObjectBackend(ClassMirror classMirror, Type type) {
    // We need to make sure that we are using original class mirror, not generic subtype
    // Otherwise subtype check will return false
    final originalClassMirror = reflectClass(type);
    if (originalClassMirror.isSubtypeOf(_listMirror)) {
      var typeArg = classMirror.typeArguments.first.reflectedType;
      return [new ReflectiveArrayBackend(typeArg)];
    }
    if (originalClassMirror.isSubclassOf(_mapMirror)) {
      var typeArg1 = classMirror.typeArguments[0].reflectedType;
      var typeArg2 = classMirror.typeArguments[1].reflectedType;
      return [new MapBackend(typeArg1, typeArg2)];
    }
    if (classMirror.isAbstract) {
      throw new ActivationException("Cant create instance of abstract class (${classMirror})");
    }

    var ctors = _extractCtors(classMirror, type).toList();
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

    return new RandomArrayItemBackend(allValues);
  }

  Iterable<CtorInfo> _extractCtors(ClassMirror classMirror, Type type) sync* {
    var constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        var arguments = method.parameters.map(constructArgumentInfo).toList();
        var name = method.constructorName;
        CtorType ctorType = _getCtorType(method);
        yield new CtorInfo(classMirror, name, arguments, ctorType, type);
      }
    }
  }

  ArgumentInfo constructArgumentInfo(ParameterMirror p) {
    var argType = p.type.reflectedType;
    var defaultValue = p.defaultValue?.reflectee;
    var isNamed = p.isNamed;
    var name = MirrorSystem.getName(p.simpleName);
    return new ArgumentInfo(argType, defaultValue, isNamed, name);
  }

  CtorType _getCtorType(MethodMirror method) {
    var name = method.constructorName;
    if (name != _emptySymbol) {
      return CtorType.Named;
    }
    return CtorType.Default;
  }
}
