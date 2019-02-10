import 'package:activatory/src/generator_delegate.dart';

class ArgumentCustomization<T> {
  GeneratorDelegate<T> _than;
  List<T> _pool;

  void than({GeneratorDelegate<T> useCallback, List<T> usePool}){
    if(useCallback!=null && usePool!=null){
      throw new ArgumentError('useCallback and usePool cant be provided together');
    }
    _pool = usePool;
    _than = useCallback;
  }

  GeneratorDelegate<T> get callback => _than;
  List<T> get pool => _pool;
}