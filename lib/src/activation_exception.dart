class ActivationException implements Exception {
  final String _message;

  ActivationException(this._message);

  String get message => _message;
}
