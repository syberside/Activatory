import 'dart:math';
import 'dart:mirrors';

import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/factories/collections/explicit_array_factory.dart';
import 'package:activatory/src/factories/collections/reflective_array_factory.dart';
import 'package:activatory/src/factories/collections/reflective_map_factory.dart';
import 'package:activatory/src/factories/ctor/argument_info.dart';
import 'package:activatory/src/factories/ctor/ctor_info.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/ctor/reflective_object_factory.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/primitives/null_factory.dart';
import 'package:activatory/src/factories/primitives/random_bool_factory.dart';
import 'package:activatory/src/factories/primitives/random_date_time_factory.dart';
import 'package:activatory/src/factories/primitives/random_double_factory.dart';
import 'package:activatory/src/factories/primitives/random_int_factory.dart';
import 'package:activatory/src/factories/primitives/random_string_factory.dart';
import 'package:activatory/src/factories/random_array_item_factory.dart';
import 'package:activatory/src/helpers/type_helper.dart';

typedef Factory _GeneratorBackendFactory();

class FactoriesFactory {
  static const _emptySymbol = const Symbol('');
  final Random _random;
  final Map<Type, _GeneratorBackendFactory> _predefinedFactories = new Map<Type, _GeneratorBackendFactory>();

  final _listMirror = reflectClass(List);
  final _mapMirror = reflectClass(Map);

  FactoriesFactory(this._random) {
    _predefinedFactories[bool] = () => new RandomBoolFactory(_random);
    _predefinedFactories[int] = () => new RandomIntFactory(_random);
    _predefinedFactories[double] = () => new RandomDoubleFactory(_random);
    _predefinedFactories[String] = () => new RandomStringFactory();
    _predefinedFactories[DateTime] = () => new RandomDateTimeFactory(_random);
    _predefinedFactories[Null] = () => new NullFactory();

    //TODO: Explicit factories are not required here. Reflective will works fine.
    _predefinedFactories[getType<List<bool>>()] = () => new ExplicitArrayFactory<bool>();
    _predefinedFactories[getType<List<int>>()] = () => new ExplicitArrayFactory<int>();
    _predefinedFactories[getType<List<double>>()] = () => new ExplicitArrayFactory<double>();
    _predefinedFactories[getType<List<String>>()] = () => new ExplicitArrayFactory<String>();
    _predefinedFactories[getType<List<DateTime>>()] = () => new ExplicitArrayFactory<DateTime>();
    _predefinedFactories[getType<List<Null>>()] = () => new ExplicitArrayFactory<Null>();
  }

  List<Factory> create(Type type) {
    var predefinedFactory = _predefinedFactories[type];
    if (predefinedFactory != null) {
      return [predefinedFactory()];
    }
    var classMirror = reflectType(type) as ClassMirror;
    if (classMirror.isEnum) {
      return [_createEnumBackend(classMirror)];
    } else {
      return _createObjectReflectiveFactories(classMirror, type);
    }
  }

  List<Factory> _createObjectReflectiveFactories(ClassMirror classMirror, Type type) {
    // We need to make sure that we are using original class mirror, not generic subtype
    // Otherwise subtype check will return false
    final originalClassMirror = reflectClass(type);
    if (originalClassMirror.isSubtypeOf(_listMirror)) {
      var typeArg = classMirror.typeArguments.first.reflectedType;
      return [new ReflectiveArrayFactory(typeArg)];
    }
    if (originalClassMirror.isSubclassOf(_mapMirror)) {
      var typeArg1 = classMirror.typeArguments[0].reflectedType;
      var typeArg2 = classMirror.typeArguments[1].reflectedType;
      return [new ReflectiveMapFactory(typeArg1, typeArg2)];
    }
    if (classMirror.isAbstract) {
      throw new ActivationException("Cant create instance of abstract class (${classMirror})");
    }

    var ctors = _extractCtors(classMirror, type).toList();
    if (ctors.isEmpty) {
      throw new ActivationException("Cant find constructor for type ${classMirror}");
    }

    return ctors.map((ctorInfo) => new ReflectiveObjectFactory(ctorInfo)).toList();
  }

  Factory _createEnumBackend(ClassMirror classMirror) {
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

    return new RandomArrayItemFactory(allValues);
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
    return new ArgumentInfo(defaultValue, isNamed, p.simpleName, argType);
  }

  CtorType _getCtorType(MethodMirror method) {
    var name = method.constructorName;
    if (name != _emptySymbol) {
      return CtorType.Named;
    }
    return CtorType.Default;
  }
}
