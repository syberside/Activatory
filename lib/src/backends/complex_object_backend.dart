
import 'dart:mirrors';

import 'package:Activatory/Activatory.dart';

class ComplexObjectBackend implements GeneratorBackend<Object>{

  Type _type;

  ComplexObjectBackend(this._type);

  @override
  Object get(ActivationContext context) {
    var classMirror = reflectClass(_type);
    var constructors = classMirror.declarations.values;
    for(var method in constructors){
      if(method is MethodMirror && method.isConstructor){
        var parameters = method.parameters;
        var positionalArguments = new List<Object>();
        for(var parameter in parameters){
          var backend = context.find(parameter.type.reflectedType);
          var value = backend.get(context);
          positionalArguments.add(value);
        }
        return classMirror.newInstance(new Symbol(''), positionalArguments).reflectee;
      }
    }
    throw new Exception("Cant find constructor for type ${_type}");
  }
}