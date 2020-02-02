import 'package:activatory/src/factories/factory.dart';

abstract class FactoryResolver {
  Factory resolve(List<Factory> factories);
}
