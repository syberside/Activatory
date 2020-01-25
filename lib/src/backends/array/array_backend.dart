import 'package:activatory/src/backends/generator_backend.dart';

abstract class ArrayBackend<T> extends GeneratorBackend<List<T>> {
  List<T> empty();
}
