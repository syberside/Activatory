import 'package:activatory/src/factories-registry/resolve_key.dart';
import 'package:activatory/src/factories/factory.dart';

class FactoriesStore {
  final Map<ResolveKey, List<Factory>> _factories = new Map<ResolveKey, List<Factory>>();

  FactoriesStore();

  FactoriesStore._fromMap(Map<ResolveKey, List<Factory>> factories) {
    _factories.addAll(factories);
  }

  FactoriesStore clone() {
    var copy = new FactoriesStore._fromMap(_factories);
    return copy;
  }

  List<Factory> find(ResolveKey key) {
    return _factories[key];
  }

  void store(Factory backend, ResolveKey key) {
    var itemsList = _factories[key];
    if (itemsList == null) {
      itemsList = new List<Factory>();
      _factories[key] = itemsList;
    }
    itemsList.insert(0, backend);
  }
}
