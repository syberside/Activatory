import 'package:activatory/src/customization/type_customization.dart';

class TypeCustomizationRegistry {
  final Map<Type, TypeCustomization> _store = new Map<Type, TypeCustomization>();

  TypeCustomizationRegistry() {
    _store[null] = new TypeCustomization();
  }

  TypeCustomization get(Type type) {
    var result = _store[type];
    if (result == null) {
      result = get(null).clone();
      _store[type] = result;
    }
    return result;
  }
}
