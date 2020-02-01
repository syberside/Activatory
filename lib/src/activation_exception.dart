import 'package:activatory/activatory.dart';

/// Exception is thrown if [Activatory] cant process activation request.
class ActivationException implements Exception {
  final String message;

  ActivationException(this.message);

  @override
  String toString() => 'ActivationException: $message';
}
