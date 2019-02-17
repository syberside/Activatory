class ArgumentInfo {
  Type _type;
  Object _defaultValue;
  bool _isNamed;
  String _name;

  ArgumentInfo(this._type, this._defaultValue, this._isNamed, this._name);

  Object get defaultValue => _defaultValue;
  bool get isNamed => _isNamed;
  String get name => _name;
  Type get type => _type;
}
