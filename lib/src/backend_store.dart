import 'package:activatory/src/resolve_key.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class BackendStore {
  Map<ResolveKey, List<GeneratorBackend>> _backends = new Map<ResolveKey, List<GeneratorBackend>>();

  BackendStore();
  BackendStore._fromMap(this._backends);

  BackendStore clone() {
    var copy = new BackendStore._fromMap(_backends);
    return copy;
  }

  List<GeneratorBackend> find(ResolveKey key) {
    return _backends[key];
  }

  void store(GeneratorBackend backend, ResolveKey key) {
    var itemsList = _backends[key];
    if (itemsList == null) {
      itemsList = new List<GeneratorBackend>();
      _backends[key] = itemsList;
    }
    itemsList.insert(0, backend);
  }
}
