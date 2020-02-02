import 'package:activatory/src/factories-registry/resolve_key.dart';
import 'package:activatory/src/factories/factory.dart';

class FactoriesStore {
  final Map<ResolveKey, List<Factory>> _factories = <ResolveKey, List<Factory>>{};

  FactoriesStore();

  FactoriesStore._fromMap(Map<ResolveKey, List<Factory>> factories) {
    _factories.addAll(factories);
  }

  FactoriesStore clone() => new FactoriesStore._fromMap(_factories);

  List<Factory> find(ResolveKey key) {
    return _factories[key];
  }

  void store(Factory backend, ResolveKey key) {
    var itemsList = _factories[key];
    if (itemsList == null) {
      itemsList = <Factory>[];
      _factories[key] = itemsList;
    }
    itemsList.insert(0, backend);
  }
}
