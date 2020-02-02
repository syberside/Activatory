import 'package:activatory/src/factories/factory.dart';

abstract class FactoryWrapper<T> {
  Factory<T> get wrapped;
}
