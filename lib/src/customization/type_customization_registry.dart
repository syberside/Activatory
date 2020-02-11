import 'package:activatory/src/customization/type_customization.dart';
import 'package:activatory/src/factories-registry/resolve_key.dart';

class TypeCustomizationRegistry {
  final Map<ResolveKey, TypeCustomization> _store = <ResolveKey, TypeCustomization>{};
  final ResolveKey _defaultKey = ResolveKey(null, null);

  TypeCustomizationRegistry() {
    _store[_defaultKey] = TypeCustomization();
  }

  TypeCustomization getCustomization(Type type, {Object key}) {
    final customizationKey = ResolveKey(type, key);
    var result = _store[customizationKey];
    if (result == null) {
      result = _getDefaultForType(type).clone();
      _store[customizationKey] = result;
    }
    return result;
  }

  TypeCustomization _getDefaultForType(Type type) {
    final customizationKey = ResolveKey(type, null);
    var result = _store[customizationKey];
    if (result == null) {
      result = _getDefault().clone();
      _store[customizationKey] = result;
    }
    return result;
  }

  TypeCustomization _getDefault() {
    return _store[_defaultKey];
  }
}
