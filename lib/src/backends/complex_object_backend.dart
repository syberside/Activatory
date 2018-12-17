import 'dart:mirrors';
import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class ComplexObjectBackend implements GeneratorBackend<Object> {
  Type _type;
  List<_CtorResolveResult> _ctors = new List<_CtorResolveResult>();

  ComplexObjectBackend(this._type);

  @override
  Object get(ActivationContext context) {
    var classMirror = reflectClass(_type);

    var ctorResolutionResult = _resolveByCtor(classMirror, context);
    if (ctorResolutionResult.resolvedSuccessfully) {
      var factory = ctorResolutionResult.result;
      return factory.factory(factory.arguments, context);
    }

    throw new Exception("Cant find constructor for type ${_type}");
  }

  _ResolveResult _resolveByCtor(
      ClassMirror classMirror, ActivationContext context) {
    if (classMirror.isAbstract) {
      throw new Exception("Cant create instance of abstract class ${_type}");
    }

    if (_ctors.isEmpty) {
      _ctors = _extractCtors(classMirror, context).toList();
    }

    if (_ctors.isEmpty) {
      return _ResolveResult.fail();
    }

    return _ResolveResult.success(_ctors[0]);
  }

  Iterable<_CtorResolveResult> _extractCtors(
      ClassMirror classMirror, ActivationContext context) sync* {
    var constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        var parameters = method.parameters;
        var positionalArguments =
            parameters.map((p) => p.type.reflectedType).toList();
        yield new _CtorResolveResult(
            (List<Type> args, ActivationContext ctx) => activateInstance(
                classMirror, method.constructorName, args, ctx),
            positionalArguments);
      }
    }
  }

  activateInstance(ClassMirror classMirror, Symbol ctor, List<Type> args,
      ActivationContext context) {
    var argValues = generateValues(args, context).toList();
    var result = classMirror.newInstance(ctor, argValues).reflectee;
    return result;
  }

  Iterable<Object> generateValues(
      List<Type> args, ActivationContext context) sync* {
    for (var argType in args) {
      var backend = context.find(argType);
      if (backend == null) {
        throw new Exception("Backend of type ${argType} not found");
      }
      var value = backend.get(context);
      yield value;
    }
  }
}

class _ResolveResult {
  _CtorResolveResult _result;
  _CtorResolveResult get result => _result;

  bool _resolvedSuccessfully;
  bool get resolvedSuccessfully => _resolvedSuccessfully;

  _ResolveResult.success(this._result) : _resolvedSuccessfully = true;
  _ResolveResult.fail() : _resolvedSuccessfully = false;
}

class _CtorResolveResult {
  List<Type> _arguments;
  List<Type> get arguments => _arguments;

  Function _factory;
  Function get factory => _factory;

  _CtorResolveResult(this._factory, this._arguments);
}
