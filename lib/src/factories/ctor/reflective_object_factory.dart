import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/factories/ctor/argument_info.dart';
import 'package:activatory/src/factories/ctor/ctor_info.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/factory.dart';

class ReflectiveObjectFactory implements Factory<Object> {
  final CtorInfo _ctorInfo;

  ReflectiveObjectFactory(
    this._ctorInfo,
  );

  CtorType get ctorType => _ctorInfo.type;

  @override
  Object get(ActivationContext context) {
    final positionalArguments = <Object>[];
    final namedArguments = new Map<Symbol, Object>();
    for (final arg in _ctorInfo.args) {
      final value = _generateValues(arg, context);
      if (arg.isNamed) {
        namedArguments[arg.name] = value;
      } else {
        positionalArguments.add(value);
      }
    }

    var result = _ctorInfo.classMirror.newInstance(_ctorInfo.ctor, positionalArguments, namedArguments);
    return result.reflectee;
  }

  Object _generateValues(ArgumentInfo arg, ActivationContext context) {
    final defaultValuesStrategy = context.defaultValuesHandlingStrategy(_ctorInfo.classType);
    switch (defaultValuesStrategy) {
      case DefaultValuesHandlingStrategy.UseAll:
        return arg.defaultValue;
      case DefaultValuesHandlingStrategy.ReplaceNulls:
        return arg.defaultValue != null ? arg.defaultValue : context.createUntyped(arg.type, context);
      case DefaultValuesHandlingStrategy.ReplaceAll:
        return context.createUntyped(arg.type, context);
      default:
        throw new UnsupportedError('${defaultValuesStrategy.toString()} is not supported');
    }
  }

  @override
  Object getDefaultValue() => null;
}
