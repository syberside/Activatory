import 'package:activatory/src/backends/generator_backend.dart';

abstract class GeneratorBackendWrapper<T>{
  GeneratorBackend<T> get wrapped;
}