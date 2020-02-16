import 'dart:mirrors';

import 'package:activatory/src/internal_activation_context.dart';
import 'package:activatory/src/post-activation/fields_auto_filling_strategy.dart';

class ReflectiveFieldsFiller {
  void fill(Object object, InternalActivationContext ctx) {
    final fieldsStrategy = ctx.fieldsAutoFill(object.runtimeType);
    if (fieldsStrategy == FieldsAutoFillingStrategy.None) {
      return;
    }

    final reflected = reflect(object);
    final publicFields = reflected.type.declarations.values
        .whereType<VariableMirror>()
        .where((VariableMirror v) => v.isFinal == false && v.isStatic == false && v.isPrivate == false);
    for (var field in publicFields) {
      final value = ctx.createUntyped(field.type.reflectedType);
      reflected.setField(field.simpleName, value);
    }
    if (fieldsStrategy == FieldsAutoFillingStrategy.Fields) {
      return;
    }

    final publicSetters = reflected.type.declarations.values
        .whereType<MethodMirror>()
        .where((MethodMirror m) => m.isStatic == false && m.isPrivate == false && m.isSetter);
    for (var setter in publicSetters) {
      //TODO: This looks like hack, but other solutions was not found.
      //See https://github.com/dart-lang/sdk/issues/13083 for details
      var name = MirrorSystem.getName(setter.simpleName);
      name = name.substring(0, name.length - 1);
      final symbol = MirrorSystem.getSymbol(name);

      final value = ctx.createUntyped(setter.parameters.first.type.reflectedType);
      reflected.setField(symbol, value);
    }
  }
}
