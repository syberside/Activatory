import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/post_activation/fields_auto_fill.dart';

class FieldsFiller {
  void fill(Object object, ActivationContext ctx) {
    var fieldsStrategy = ctx.fieldsAutoFill(object.runtimeType);
    if (fieldsStrategy == FieldsAutoFill.None) {
      return;
    }

    var reflected = reflect(object);
    var publicFields = reflected.type.declarations.values
        .where((DeclarationMirror d) => d is VariableMirror)
        .cast<VariableMirror>()
        .where((VariableMirror v) => v.isFinal == false && v.isStatic == false && v.isPrivate == false)
        .toList();
    for (var field in publicFields) {
      var value = ctx.create(field.type.reflectedType, ctx);
      reflected.setField(field.simpleName, value);
    }
    if (fieldsStrategy == FieldsAutoFill.Fields) {
      return;
    }

    var publicSetters = reflected.type.declarations.values
        .where((DeclarationMirror d) => d is MethodMirror)
        .cast<MethodMirror>()
        .where((MethodMirror m) => m.isStatic == false && m.isPrivate == false && m.isSetter)
        .toList();
    for (var setter in publicSetters) {
      //TODO: This looks like hack, but other solutions was not found.
      //See https://github.com/dart-lang/sdk/issues/13083 for details
      var name = MirrorSystem.getName(setter.simpleName);
      name = name.substring(0, name.length - 1);
      var symbol = MirrorSystem.getSymbol(name);

      var value = ctx.create(setter.parameters.first.type.reflectedType, ctx);
      reflected.setField(symbol, value);
    }
  }
}
