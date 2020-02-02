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

typedef _GeneratorBackendFactory = Factory Function();

class FactoriesFactory {
  static const _emptySymbol = const Symbol('');
  final Random _random;
  final Map<Type, _GeneratorBackendFactory> _predefinedFactories = <Type, _GeneratorBackendFactory>{};

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
    final predefinedFactory = _predefinedFactories[type];
    if (predefinedFactory != null) {
      return [predefinedFactory()];
    }
    final classMirror = reflectType(type) as ClassMirror;
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
      final typeArg = classMirror.typeArguments.first.reflectedType;
      return [new ReflectiveArrayFactory(typeArg)];
    }
    if (originalClassMirror.isSubclassOf(_mapMirror)) {
      final typeArg1 = classMirror.typeArguments[0].reflectedType;
      final typeArg2 = classMirror.typeArguments[1].reflectedType;
      return [new ReflectiveMapFactory(typeArg1, typeArg2)];
    }
    if (classMirror.isAbstract) {
      throw new ActivationException('Cant create instance of abstract class (${classMirror})');
    }

    final constructors = _extractConstructors(classMirror, type).toList();
    if (constructors.isEmpty) {
      throw new ActivationException('Cant find constructor for type ${classMirror}');
    }

    return constructors.map((ctorInfo) => new ReflectiveObjectFactory(ctorInfo)).toList();
  }

  Factory _createEnumBackend(ClassMirror classMirror) {
    final declaration = classMirror.declarations.values
        .whereType<VariableMirror>()
        .where((d) => d.isStatic && d.simpleName == #values)
        .first;
    if (declaration == null) {
      throw new ActivationException('Declaration of values for enum ${classMirror} not found');
    }

    final allValues = classMirror.getField(declaration.simpleName).reflectee as List;
    if (allValues.isEmpty) {
      throw new ActivationException('Enum ${classMirror} values found but empty');
    }

    return new RandomArrayItemFactory(allValues);
  }

  Iterable<CtorInfo> _extractConstructors(ClassMirror classMirror, Type type) sync* {
    final constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        final arguments = method.parameters.map(constructArgumentInfo).toList();
        final name = method.constructorName;
        final ctorType = method.constructorName != _emptySymbol ? CtorType.Named : CtorType.Default;
        yield new CtorInfo(classMirror, name, arguments, ctorType, type);
      }
    }
  }

  ArgumentInfo constructArgumentInfo(ParameterMirror parameter) {
    final argType = parameter.type.reflectedType;
    final Object defaultValue = parameter.defaultValue?.reflectee;
    final isNamed = parameter.isNamed;
    return new ArgumentInfo(defaultValue, isNamed, parameter.simpleName, argType);
  }
}
