import 'package:activatory/src/activatory.dart';
import 'package:test/test.dart';

import 'test-classes.dart';

void main() {
  Activatory _activatory;
  setUp(() {
    _activatory = new Activatory();
  });

  assertComplexObjectIsNotNull(PrimitiveComplexObject obj) {
    expect(obj, isNotNull);
    expect(obj.dateTimeField, isNotNull);
    expect(obj.boolField, isNotNull);
    expect(obj.doubleField, isNotNull);
    expect(obj.stringField, isNotNull);
    expect(obj.intField, isNotNull);
  }

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
      assertComplexObjectIsNotNull(result);
    });

    test('with not only primitives in ctor parameters', () {
      var result = _activatory.getTyped<NonPrimitiveComplexObject>();
      expect(result, isNotNull);
      expect(result.intField, isNotNull);
      assertComplexObjectIsNotNull(result.primitiveComplexObject);
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
      expect(() => _activatory.getTyped<AbstractClass>(), throwsA(isInstanceOf<Exception>()));
    });

    test('class without public ctor', () {
      expect(() => _activatory.getTyped<NoPublicCtor>(), throwsA(isInstanceOf<Exception>()));
    });
  });

  group("Default values of", () {
    group("positional arguments are", () {
      test("used when they are not nulls", () {
        var result = _activatory.getTyped<DefaultPositionalNoNullValue>();
        expect(result, isNotNull);
        expect(result.stringValue, equals(DefaultPositionalNoNullValue.defaultValue));
        assertComplexObjectIsNotNull(result.object);
      });

      test("not used when they are nulls", () {
        var result = _activatory.getTyped<DefaultPositionalNullValue>();
        expect(result, isNotNull);
        expect(result.stringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });
    });

    group("named arguments are", () {
      test("used when they are not nulls", () {
        var result = _activatory.getTyped<DefaultNamedNoNullValue>();
        expect(result, isNotNull);
        expect(result.stringValue, equals(DefaultNamedNoNullValue.defaultValue));
        assertComplexObjectIsNotNull(result.object);
      });

      test("not used when they are nulls", () {
        var result = _activatory.getTyped<DefaultNamedNullValue>();
        expect(result, isNotNull);
        expect(result.stringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });
    });
  });

  group("Can override default factory resolution logic ", () {
    tearDown(() {
      _activatory = new Activatory();
    });

    group("with explicit factory for", () {
      test("primitive type", () {
        var expected = _activatory.getTyped<int>();
        _activatory.override((_) => expected);
        var result1 = _activatory.getTyped<int>();
        var result2 = _activatory.getTyped<int>();
        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test("complex type", () {
        var expected = new DefaultCtor();
        _activatory.override((_) => expected);
        var result1 = _activatory.getTyped<DefaultCtor>();
        var result2 = _activatory.getTyped<DefaultCtor>();
        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });

    group("with singletone for", () {
      test("primitive type", () {
        _activatory.useSingleton(DateTime);
        var result1 = _activatory.getTyped<DateTime>();
        var result2 = _activatory.getTyped<DateTime>();
        expect(result1, equals(result2));
      });

      test("complex type", () {
        _activatory.useSingleton(DefaultCtor);
        var result1 = _activatory.getTyped<DefaultCtor>();
        var result2 = _activatory.getTyped<DefaultCtor>();
        expect(result1, same(result2));
      });
    });

    group("with fixed value for", () {
      test("primitive type", () {
        var expected = _activatory.getTyped<int>();
        _activatory.useValue(expected);
        var result1 = _activatory.getTyped<int>();
        var result2 = _activatory.getTyped<int>();
        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test("complex type", () {
        var expected = new DefaultCtor();
        _activatory.useValue(expected);
        var result1 = _activatory.getTyped<DefaultCtor>();
        var result2 = _activatory.getTyped<DefaultCtor>();
        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });
  });

  group('Can use labels to define factory to use:', () {
    void testLabels<TKey, TValue>(TKey key1, TValue value1, TKey key2, TValue value2) {
      _activatory.useValue(value1, key: key1);
      _activatory.useValue(value2, key: key2);

      var result1 = _activatory.get(TValue, key: key1);
      var result2 = _activatory.get(TValue, key: key2);
      var result = _activatory.get(TValue);

      expect(result1, equals(value1));
      expect(result2, equals(value2));
      expect(result, isNot(equals(result1)));
      expect(result, isNot(equals(result2)));
    }

    test('primitive key, primitive value', () {
      testLabels('key1', 10, 'key2', 22);
    });
    test('primitive key, complex value', () {
      var value1 = _activatory.get(PrimitiveComplexObject);
      var value2 = _activatory.get(PrimitiveComplexObject);
      testLabels('key1', value1, 'key2', value2);
    });
    test('complex key, complex value', () {
      var key1 = _activatory.get(PrimitiveComplexObject);
      var key2 = _activatory.get(PrimitiveComplexObject);
      var value1 = _activatory.get(PrimitiveComplexObject);
      var value2 = _activatory.get(PrimitiveComplexObject);
      testLabels(key1, value1, key2, value2);
    });
  });
}
