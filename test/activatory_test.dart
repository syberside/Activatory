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
      expect(() => _activatory.getTyped<AbstractClass>(),
          throwsA(isInstanceOf<Exception>()));
    });

    test('class without public ctor', () {
      expect(() => _activatory.getTyped<NoPublicCtor>(),
          throwsA(isInstanceOf<Exception>()));
    });
  });

  group("Default values of", () {
    group("positional arguments are", () {
      test("used when they are not nulls", () {
        var result = _activatory.getTyped<DefaultPositionalNoNullValue>();
        expect(result, isNotNull);
        expect(result.stringValue,
            equals(DefaultPositionalNoNullValue.defaultValue));
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
        expect(
            result.stringValue, equals(DefaultNamedNoNullValue.defaultValue));
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
}
