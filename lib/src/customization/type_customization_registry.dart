import 'package:activatory/src/customization/type_customization.dart';

class TypeCustomizationRegistry {
  final Map<Type, TypeCustomization> _store = new Map<Type, TypeCustomization>();

  TypeCustomization get(Type type) {
    var result = _store[type];
    if (result == null) {
      result = new TypeCustomization();
      _store[type] = result;
    }
    return result;
  }
}
