abstract class AbstractClass {
  int _intField;

  AbstractClass(this._intField);
}

class DefaultCtor {
  int intField;
}

class PrimitiveComplexObject {
  int _intField;
  int get intField => _intField;

  String _stringField;
  String get stringField => _stringField;

  double _doubleField;
  double get doubleField => _doubleField;

  bool _boolField;
  bool get boolField => _boolField;

  DateTime _dateTimeField;
  DateTime get dateTimeField => _dateTimeField;

  PrimitiveComplexObject(this._intField, this._stringField, this._doubleField,
      this._boolField, this._dateTimeField);
}

class NonPrimitiveComplexObject {
  PrimitiveComplexObject _primitiveComplexObject;
  PrimitiveComplexObject get primitiveComplexObject => _primitiveComplexObject;

  int _intField;
  int get intField => _intField;

  NonPrimitiveComplexObject(this._primitiveComplexObject, this._intField);
}

class NamedCtor {
  String _stringField;
  String get stringField => _stringField;

  NamedCtor.nonDefaultName(this._stringField);
}

class FactoryCtor {
  String _stringField;
  String get stringField => _stringField;

  String _nonFactoryField;
  String get nonFactoryField => _nonFactoryField;

  FactoryCtor._internal(this._stringField, this._nonFactoryField);

  factory FactoryCtor(String stringField) {
    return new FactoryCtor._internal(stringField, null);
  }
}

class NoPublicCtor {
  String _stringField;
  String get stringField => _stringField;

  NoPublicCtor._internal(this._stringField);
}

class DefaultPositionalNoNullValue {
  static const String defaultValue = "defaultValue is not generated";
  String _stringValue;
  String get stringValue => _stringValue;

  PrimitiveComplexObject _object;
  PrimitiveComplexObject get object => _object;

  DefaultPositionalNoNullValue(this._object,
      [this._stringValue = defaultValue]);
}

class DefaultPositionalNullValue {
  String _stringValue;
  String get stringValue => _stringValue;

  PrimitiveComplexObject _notSetObject;
  PrimitiveComplexObject get notSetObject => _notSetObject;

  PrimitiveComplexObject _nullSetObject;
  PrimitiveComplexObject get nullSetObject => _nullSetObject;

  DefaultPositionalNullValue(
      [this._notSetObject,
      this._nullSetObject = null,
      this._stringValue = null]);
}

class DefaultNamedNoNullValue {
  static const String defaultValue = "defaultValue is not generated";
  String _stringValue;
  String get stringValue => _stringValue;

  PrimitiveComplexObject _object;
  PrimitiveComplexObject get object => _object;

  DefaultNamedNoNullValue(this._object, {String stringValue = defaultValue}) {
    _stringValue = stringValue;
  }
}

class DefaultNamedNullValue {
  String _stringValue;
  String get stringValue => _stringValue;

  PrimitiveComplexObject _notSetObject;
  PrimitiveComplexObject get notSetObject => _notSetObject;

  PrimitiveComplexObject _nullSetObject;
  PrimitiveComplexObject get nullSetObject => _nullSetObject;

  DefaultNamedNullValue(
      {PrimitiveComplexObject notSetObject,
      PrimitiveComplexObject nullSetObject = null,
      String stringValue = null}) {
    _stringValue = stringValue;
    _notSetObject = notSetObject;
    _nullSetObject = nullSetObject;
  }
}
