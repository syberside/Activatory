abstract class AbstractClass {
  int _intField;

  AbstractClass(this._intField);
}

class ClosedByInheritanceGeneric extends GenericArrayInCtor<String> {
  ClosedByInheritanceGeneric(List<String> listField) : super(listField);
}

class CtorWithTwoStringArgs {
  final String _a;
  final String _b;

  CtorWithTwoStringArgs(this._a, this._b);

  String get a => _a;

  String get b => _b;
}

class DefaultCtor {}

class DefaultNamedValues {
  static const String defaultValue = "defaultValue is not generated";

  String _nullSetString;
  PrimitiveComplexObject _notSetObject;

  PrimitiveComplexObject _nullSetObject;

  String _notNullSetString;

  DefaultNamedValues(
      {PrimitiveComplexObject notSetObject,
      PrimitiveComplexObject nullSetObject = null,
      String nullSetString = null,
      String notNullSetString = defaultValue}) {
    _nullSetString = nullSetString;
    _notSetObject = notSetObject;
    _nullSetObject = nullSetObject;
    _notNullSetString = notNullSetString;
  }

  PrimitiveComplexObject get notSetObject => _notSetObject;

  PrimitiveComplexObject get nullSetObject => _nullSetObject;

  String get nullSetString => _nullSetString;

  String get notNullSetString => _notNullSetString;
}

class DefaultPositionalValues {
  static const String defaultStringValue = 'default value is not overriden';
  final String _nullSetString;
  final String _notNullString;
  final PrimitiveComplexObject _notSetObject;
  final PrimitiveComplexObject _nullSetObject;

  DefaultPositionalValues(
      [this._notSetObject,
      this._nullSetObject = null,
      this._nullSetString = null,
      this._notNullString = defaultStringValue]);

  PrimitiveComplexObject get notSetObject => _notSetObject;

  PrimitiveComplexObject get nullSetObject => _nullSetObject;

  String get nullSetStringValue => _nullSetString;

  String get notNullSetStringValue => _notNullString;
}

class FactoryCtor {
  String _stringField;
  String _nonFactoryField;

  factory FactoryCtor(String stringField) {
    return new FactoryCtor._internal(stringField, null);
  }

  FactoryCtor._internal(this._stringField, this._nonFactoryField);

  String get nonFactoryField => _nonFactoryField;

  String get stringField => _stringField;
}

class FactoryWithFixedValues {
  static final FactoryWithFixedValues a = new FactoryWithFixedValues._("A");
  static final FactoryWithFixedValues b = new FactoryWithFixedValues._("B");

  static final FactoryWithFixedValues c = new FactoryWithFixedValues._("C");

  String _field;

  factory FactoryWithFixedValues(String type) {
    switch (type) {
      case 'A':
        return a;
      case 'B':
        return b;
      case 'C':
        return c;
      default:
        throw new ArgumentError(type);
    }
  }

  FactoryWithFixedValues._(this._field);

  String get field => _field;
}

class Generic<T> {
  final T _field;

  Generic(this._field);

  T get field => _field;
}

class GenericArrayInCtor<T> {
  final List<T> _listField;

  GenericArrayInCtor(this._listField);

  List<T> get listField => _listField;
}

class IntArrayInCtor {
  final List<int> _listField;

  IntArrayInCtor(this._listField);

  List<int> get listField => _listField;
}

class LinkedNode {
  final LinkedNode _next;

  LinkedNode(this._next);

  LinkedNode get next => _next;
}

class NamedCtor {
  String _stringField;

  NamedCtor.nonDefaultName(this._stringField);

  String get stringField => _stringField;
}

class NamedCtorsAndConstCtor {
  final String _field;

  const NamedCtorsAndConstCtor(this._field);

  NamedCtorsAndConstCtor.A() : this('A');

  NamedCtorsAndConstCtor.B() : this('B');

  NamedCtorsAndConstCtor.C() : this('C');

  String get field => _field;
}

class NamedCtorsAndDefaultCtor {
  final String _field;

  NamedCtorsAndDefaultCtor(this._field);

  NamedCtorsAndDefaultCtor.createA() : this("A");

  NamedCtorsAndDefaultCtor.createB() : this("B");

  NamedCtorsAndDefaultCtor.createC() : this("C");

  NamedCtorsAndDefaultCtor.createD() : this("D");

  String get field => _field;
}

class NamedCtorsAndFactory {
  String _field;

  factory NamedCtorsAndFactory(String arg) {
    return NamedCtorsAndFactory._internal(arg);
  }

  NamedCtorsAndFactory.createA() {
    _field = "A";
  }

  NamedCtorsAndFactory._internal(String arg) {
    _field = arg;
  }

  String get field => _field;
}

class NonPrimitiveComplexObject {
  PrimitiveComplexObject _primitiveComplexObject;
  int _intField;

  NonPrimitiveComplexObject(this._primitiveComplexObject, this._intField);

  int get intField => _intField;

  PrimitiveComplexObject get primitiveComplexObject => _primitiveComplexObject;
}

class NoPublicCtor {
  String _stringField;

  NoPublicCtor._internal(this._stringField);

  String get stringField => _stringField;
}

class PrimitiveComplexObject {
  int _intField;
  String _stringField;
  double _doubleField;
  bool _boolField;
  DateTime _dateTimeField;
  TestEnum _enumField;

  PrimitiveComplexObject(
      this._intField, this._stringField, this._doubleField, this._boolField, this._dateTimeField, this._enumField);

  bool get boolField => _boolField;

  DateTime get dateTimeField => _dateTimeField;

  double get doubleField => _doubleField;

  TestEnum get enumField => _enumField;

  int get intField => _intField;

  String get stringField => _stringField;
}

abstract class Task {
  DateTime get dueDate;

  int get id;

  bool get isRecurrent;

  bool get isTemplate;

  String get title;
}

enum TestEnum { A, B, C }

class TreeNode {
  final List<TreeNode> _children;

  TreeNode(this._children);

  List<TreeNode> get children => _children;
}

class PrimitiveIterableInCtor {
  final Iterable<String> _field;

  PrimitiveIterableInCtor(this._field);

  Iterable<String> get field => _field;
}

class ComplexIterableInCtor {
  final Iterable<PrimitiveIterableInCtor> _field;

  ComplexIterableInCtor(this._field);

  Iterable<PrimitiveIterableInCtor> get field => _field;
}

abstract class ParentClass {}

class ChildClass extends ParentClass {}

class FiledsWithPublicSetters {
  final String _finalField;

  String get finalField => _finalField;

  FiledsWithPublicSetters(this._finalField);

  String publicField;

  String _publicProperty;

  String get publicProperty => _publicProperty;

  void set publicProperty(String value) => _publicProperty = value;
}
