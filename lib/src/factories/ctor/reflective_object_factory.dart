import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/factories/ctor/argument_info.dart';
import 'package:activatory/src/factories/ctor/ctor_info.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class ReflectiveObjectFactory implements Factory<Object> {
  final CtorInfo _ctorInfo;

  ReflectiveObjectFactory(
    this._ctorInfo,
  );

  CtorType get ctorType => _ctorInfo.type;

  @override
  Object get(InternalActivationContext context) {
    final positionalArguments = <Object>[];
    final namedArguments = <Symbol, Object>{};
    for (final arg in _ctorInfo.args) {
      final value = _generateValues(arg, context);
      if (arg.isNamed) {
        namedArguments[arg.name] = value;
      } else {
        positionalArguments.add(value);
      }
    }

    final result = _ctorInfo.classMirror.newInstance(_ctorInfo.ctor, positionalArguments, namedArguments);
    return result.reflectee;
  }

  Object _generateValues(ArgumentInfo arg, InternalActivationContext context) {
    final defaultValuesStrategy = context.defaultValuesHandlingStrategy(_ctorInfo.classType);
    switch (defaultValuesStrategy) {
      case DefaultValuesHandlingStrategy.UseAll:
        return arg.defaultValue;
      case DefaultValuesHandlingStrategy.ReplaceNulls:
        return arg.defaultValue ?? context.createUntyped(arg.type);
      case DefaultValuesHandlingStrategy.ReplaceAll:
        return context.createUntyped(arg.type);
      default:
        throw UnsupportedError('${defaultValuesStrategy.toString()} is not supported');
    }
  }

  @override
  Object getDefaultValue() => null;
}
