import 'package:activatory/src/activatory.dart';
import 'package:test/test.dart';

void main() {
  Activatory _activatory;
  setUp(() {
    _activatory = new Activatory();
  });

  group('Can generate primitive types', () {
    var types = [String, int, bool, DateTime, double];
    for (var type in types) {
      test(type, () {
        var result = _activatory.get(type);
        expect(result, allOf([isNotNull]));
        expect(result.runtimeType, same(type));
      });
    }
  });

  group('Can create complex object', () {
    test('with default (implicit) ctor', () {
      var result = _activatory.getTyped<DefaultCtor>();
      expect(result, isNotNull);
      expect(result.intField, isNull);
    });

    test('with primitives only in ctor parameters', () {
      var result = _activatory.getTyped<PrimitiveComplexObject>();
      expect(result, isNotNull);
      expect(result.dateTimeField, isNotNull);
      expect(result.boolField, isNotNull);
      expect(result.doubleField, isNotNull);
      expect(result.stringField, isNotNull);
      expect(result.intField, isNotNull);
    });

    test('with not only primitives in ctor parameters', () {
      var result = _activatory.getTyped<NonPrimitiveComplexObject>();
      expect(result, isNotNull);
      //TODO: use common method or matcher
      expect(result.primitiveComplexObject, isNotNull);
      expect(result.primitiveComplexObject.dateTimeField, isNotNull);
      expect(result.primitiveComplexObject.boolField, isNotNull);
      expect(result.primitiveComplexObject.doubleField, isNotNull);
      expect(result.primitiveComplexObject.stringField, isNotNull);
      expect(result.primitiveComplexObject.intField, isNotNull);
      expect(result.intField, isNotNull);
    });

    test('with named ctor', () {
      var result = _activatory.getTyped<NamedCtor>();
      expect(result, isNotNull);
      expect(result.stringField, isNotNull);
    });

    test('with factory ctor', () {
      var result = _activatory.getTyped<FactoryCtor>();
      expect(result, isNotNull);
      expect(result.stringField, isNotNull);
      expect(result.nonFactoryField, isNull);
    });
  });

  group('Cant create', () {
    test('abstract class', () {
      expect(() => _activatory.getTyped<AbstractClass>(),
          throwsA(isInstanceOf<Exception>()));
    });

    test('class without public ctor', () {
      expect(() => _activatory.getTyped<NoPublicCtor>(),
          throwsA(isInstanceOf<Exception>()));
    });
  });
}

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
