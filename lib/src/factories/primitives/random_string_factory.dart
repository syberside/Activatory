import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:uuid/uuid.dart';

class RandomStringFactory implements Factory<String> {
  @override
  String get(ActivationContext context) => new Uuid().v1();

  @override
  String getDefaultValue() => '';
}
