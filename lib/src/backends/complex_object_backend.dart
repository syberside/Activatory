import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/argument_info.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/ctor_info.dart';
import 'package:activatory/src/ctor_type.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';

class ComplexObjectBackend implements GeneratorBackend<Object> {
  final CtorInfo _ctorInfo;

  ComplexObjectBackend(this._ctorInfo);

  CtorType get ctorType => _ctorInfo.type;

  @override
  Object get(ActivationContext context) {
    var positionalArguments =
        _ctorInfo.args.where((arg) => !arg.isNamed).map((arg) => _generateValues(arg, context)).toList();

    var namedArguments = new Map<Symbol, Object>();
    _ctorInfo.args
        .where((args) => args.isNamed)
        .forEach((arg) => namedArguments[new Symbol(arg.name)] = _generateValues(arg, context));

    var result = _ctorInfo.classMirror.newInstance(_ctorInfo.ctor, positionalArguments, namedArguments).reflectee;
    return result;
  }

  Object _generateValues(ArgumentInfo arg, ActivationContext context) {
    final overrideDelegate = context.getArgumentOverride(_ctorInfo.classType, arg.type, arg.name);
    if (overrideDelegate != null) {
      return overrideDelegate(context);
    }

    final defaultValuesStrategy = context.defaultValuesHandlingStrategy(_ctorInfo.classType);
    switch (defaultValuesStrategy) {
      case DefaultValuesHandlingStrategy.UseAll:
        return arg.defaultValue;
      case DefaultValuesHandlingStrategy.ReplaceNulls:
        return arg.defaultValue != null ? arg.defaultValue : context.create(arg.type, context);
      case DefaultValuesHandlingStrategy.ReplaceAll:
        return context.create(arg.type, context);
      default:
        throw new UnsupportedError('${defaultValuesStrategy.toString()} is not supported');
    }
  }
}
