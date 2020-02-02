import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';
import 'package:uuid/uuid.dart';

class RandomStringFactory implements Factory<String> {
  @override
  String get(InternalActivationContext context) => new Uuid().v1();

  @override
  String getDefaultValue() => '';
}
