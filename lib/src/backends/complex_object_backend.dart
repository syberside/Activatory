import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/argument_info.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/ctor_info.dart';

class ComplexObjectBackend implements GeneratorBackend<Object> {
  final CtorInfo _ctorInfo;

  ComplexObjectBackend(this._ctorInfo);

  CtorType get ctorType => _ctorInfo.type;

  @override
  Object get(ActivationContext context) {
    var positionalArguments = _ctorInfo.args.where((arg) => !arg.isNamed).map((arg) => _generateValues(arg, context)).toList();

    var namedArguments = new Map<Symbol, Object>();
    _ctorInfo.args.where((args) => args.isNamed).forEach((arg) => namedArguments[arg.name] = _generateValues(arg, context));

    var result = _ctorInfo.classMirror.newInstance(_ctorInfo.ctor, positionalArguments, namedArguments).reflectee;
    return result;
  }

  Object _generateValues(ArgumentInfo arg, ActivationContext context) {
    final overrideDelegate = context.getArgumentOverride(_ctorInfo.classType, arg.type);
    if(overrideDelegate!=null){
      return overrideDelegate(context);
    }

    if (arg.defaultValue != null) {
      return arg.defaultValue;
    }

    return context.create(arg.type, context);
  }
}

