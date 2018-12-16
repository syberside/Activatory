import 'dart:mirrors';
import 'package:Activatory/src/activatory.dart';
import 'package:Activatory/src/activation_context.dart';
import 'package:Activatory/src/backends/generator_backend.dart';

class ComplexObjectBackend implements GeneratorBackend<Object>{

  Type _type;

  ComplexObjectBackend(this._type);

  @override
  Object get(ActivationContext context) {
    var classMirror = reflectClass(_type);
    if(classMirror.isAbstract){
      throw new Exception("Cant create instance of abstract class ${_type}");
    }

    var ctorResolutionResult = _resolveByCtor(classMirror, context);
    if(ctorResolutionResult.resolvedSuccessfully){
      return ctorResolutionResult.result;
    }

    throw new Exception("Cant find constructor for type ${_type}");
  }

  _ResolveResult _resolveByCtor(ClassMirror classMirror, ActivationContext context){
    var constructors = classMirror.declarations.values;
    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor) {
        var parameters = method.parameters;
        var positionalArguments = new List<Object>();
        for (var parameter in parameters) {
          var backend = context.find(parameter.type.reflectedType);
          var value = backend.get(context);
          positionalArguments.add(value);
        }

        var result = classMirror
            .newInstance(new Symbol(''), positionalArguments)
            .reflectee;
        return _ResolveResult.success(result);
      }
    }
    return _ResolveResult.fail();
  }
}

class _ResolveResult{
  Object _result;
  Object get result => _result;

  bool _resolvedSuccessfully;
  bool get resolvedSuccessfully => _resolvedSuccessfully;

  _ResolveResult.success(this._result):_resolvedSuccessfully = true;
  _ResolveResult.fail():_resolvedSuccessfully = false;
}