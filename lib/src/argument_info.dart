class ArgumentInfo {
  Type _type;
  Object _defaultValue;

  bool _isNamed;
  Symbol _name;

  ArgumentInfo(this._type, this._defaultValue, this._isNamed, this._name);
  Object get defaultValue => _defaultValue;

  bool get isNamed => _isNamed;
  Symbol get name => _name;

  Type get type => _type;
}