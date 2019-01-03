import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class ComplexObjectBackend implements GeneratorBackend<Object> {
  Type _type;
  List<_CtorResolveResult> _ctors;

  ComplexObjectBackend(this._type);

  activateInstance(ClassMirror classMirror, Symbol ctor, List<_ArgResolveResult> args, ActivationContext context) {
    var positionalArguments = args.where((arg) => !arg.isNamed).map((arg) => generateValues(arg, context)).toList();

    var namedArguments = new Map<Symbol, Object>();
    args.where((args) => args.isNamed).forEach((arg) => namedArguments[arg.name] = generateValues(arg, context));

    var result = classMirror.newInstance(ctor, positionalArguments, namedArguments).reflectee;
    return result;
  }

  Object generateValues(_ArgResolveResult arg, ActivationContext context) {
    if (arg.defaultValue != null) {
      return arg.defaultValue;
    } else {
      var backend = context.get(arg.type);
      return backend.get(context);
    }
  }

  @override
  Object get(ActivationContext context) {
    var ctorResolutionResult = _resolveByCtor(context);
    if (ctorResolutionResult.resolvedSuccessfully) {
      var factory = ctorResolutionResult.result;
      return factory.factory(factory.arguments, context);
    }

    throw new Exception("Cant find constructor for type ${_type}");
  }

  Iterable<_CtorResolveResult> _extractCtors(ClassMirror classMirror, ActivationContext context) sync* {
    var constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        var arguments = method.parameters
            .map((p) => new _ArgResolveResult(p.type.reflectedType, p.defaultValue?.reflectee, p.isNamed, p.simpleName))
            .toList();
        yield new _CtorResolveResult(
            (List<_ArgResolveResult> args, ActivationContext ctx) =>
                activateInstance(classMirror, method.constructorName, args, ctx),
            arguments);
      }
    }
  }

  _ResolveResult _resolveByCtor(ActivationContext context) {
    var classMirror = reflectClass(_type);

    if (classMirror.isAbstract) {
      throw new Exception("Cant create instance of abstract class ${_type}");
    }

    if (_ctors == null) {
      _ctors = _extractCtors(classMirror, context).toList();
    }

    if (_ctors.isEmpty) {
      return _ResolveResult.fail();
    }

    return _ResolveResult.success(_ctors[0]);
  }
}

class _ArgResolveResult {
  Type _type;
  Object _defaultValue;

  bool _isNamed;
  Symbol _name;

  _ArgResolveResult(this._type, this._defaultValue, this._isNamed, this._name);
  Object get defaultValue => _defaultValue;

  bool get isNamed => _isNamed;
  Symbol get name => _name;

  Type get type => _type;
}

class _CtorResolveResult {
  List<_ArgResolveResult> _arguments;
  Function _factory;

  _CtorResolveResult(this._factory, this._arguments);
  List<_ArgResolveResult> get arguments => _arguments;

  Function get factory => _factory;
}

class _ResolveResult {
  _CtorResolveResult _result;
  bool _resolvedSuccessfully;

  _ResolveResult.fail() : _resolvedSuccessfully = false;
  _ResolveResult.success(this._result) : _resolvedSuccessfully = true;

  bool get resolvedSuccessfully => _resolvedSuccessfully;
  _CtorResolveResult get result => _result;
}
