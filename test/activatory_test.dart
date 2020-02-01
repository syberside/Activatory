import 'dart:collection';

import 'package:activatory/activatory.dart';
import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/activatory.dart';
import 'package:activatory/src/customization/backend_resolution_strategy.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/post_activation/fields_auto_filling_strategy.dart';
import 'package:test/test.dart';

import 'test_classes.dart';

void main() {
  Type _getType<T>() => T;

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
    expect(obj.enumField, isNotNull);
    expect(TestEnum.values, contains(obj.enumField));
  }

  group('Can generate primitive types', () {
    var supportedPrimitiveTypes = [String, int, bool, DateTime, double, TestEnum];
    for (var type in supportedPrimitiveTypes) {
      test(type, () {
        var result = _activatory.getUntyped(type);
        expect(result, isNotNull);
        expect(result.runtimeType, same(type));
      });
    }
  });

  group('Can create complex object', () {
    test('with default (implicit) ctor', () {
      var result = _activatory.get<DefaultCtor>();
      expect(result, isNotNull);
    });

    test('with primitives only in ctor parameters', () {
      var result = _activatory.get<PrimitiveComplexObject>();
      assertComplexObjectIsNotNull(result);
    });

    test('with not only primitives in ctor parameters', () {
      var result = _activatory.get<NonPrimitiveComplexObject>();
      expect(result, isNotNull);
      expect(result.intField, isNotNull);
      assertComplexObjectIsNotNull(result.primitiveComplexObject);
    });

    test('with named ctor', () {
      var result = _activatory.get<NamedCtor>();
      expect(result, isNotNull);
      expect(result.stringField, isNotNull);
    });

    test('with factory ctor', () {
      var result = _activatory.get<FactoryCtor>();
      expect(result, isNotNull);
      expect(result.stringField, isNotNull);
      expect(result.nonFactoryField, isNull);
    });
  });

  group('Cant create', () {
    test('abstract class', () {
      expect(() => _activatory.get<AbstractClass>(), throwsA(TypeMatcher<ActivationException>()));
    });

    test('class without public ctor', () {
      expect(() => _activatory.get<NoPublicCtor>(), throwsA(TypeMatcher<ActivationException>()));
    });
  });

  group("Default values of", () {
    group("positional arguments are", () {
      test("ignored if they are nulls and used if not", () {
        var result = _activatory.get<DefaultPositionalValues>();
        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });
    });

    group("named arguments are", () {
      test("ignored if they are nulls and used if not", () {
        var result = _activatory.get<DefaultNamedValues>();
        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNotNull);
        assertComplexObjectIsNotNull(result.nullSetObject);
        assertComplexObjectIsNotNull(result.notSetObject);
      });
    });
  });

  group("Can override default factory resolution logic ", () {
    group("with explicit factory for", () {
      test("primitive type", () {
        var expected = _activatory.get<int>();
        _activatory.useFunction((_) => expected);
        var result1 = _activatory.get<int>();
        var result2 = _activatory.get<int>();
        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test("complex type", () {
        var expected = new DefaultCtor();
        _activatory.useFunction((_) => expected);
        var result1 = _activatory.get<DefaultCtor>();
        var result2 = _activatory.get<DefaultCtor>();
        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });

    group("with pin for", () {
      test("primitive type", () {
        _activatory.useGeneratedSingleton<DateTime>();
        var result1 = _activatory.get<DateTime>();
        var result2 = _activatory.get<DateTime>();
        expect(result1, equals(result2));
      });

      test("complex type", () {
        _activatory.useGeneratedSingleton<DefaultCtor>();
        var result1 = _activatory.get<DefaultCtor>();
        var result2 = _activatory.get<DefaultCtor>();
        expect(result1, same(result2));
      });
    });

    group("with pined value for", () {
      test("primitive type", () {
        var expected = _activatory.get<int>();
        _activatory.useSingleton(expected);
        var result1 = _activatory.get<int>();
        var result2 = _activatory.get<int>();
        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test("complex type", () {
        var expected = new DefaultCtor();
        _activatory.useSingleton(expected);
        var result1 = _activatory.get<DefaultCtor>();
        var result2 = _activatory.get<DefaultCtor>();
        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });
  });

  group('Can use labels to define', () {
    group('pined values to use:', () {
      void testLabels<TKey, TValue>(TKey key1, TValue value1, TKey key2, TValue value2) {
        _activatory.useSingleton(value1, key: key1);
        _activatory.useSingleton(value2, key: key2);

        var result1 = _activatory.getUntyped(TValue, key1);
        var result2 = _activatory.getUntyped(TValue, key2);
        var result = _activatory.getUntyped(TValue);

        expect(result1, equals(value1));
        expect(result2, equals(value2));
        expect(result, isNot(equals(result1)));
        expect(result, isNot(equals(result2)));
      }

      test('primitive key, primitive value', () {
        testLabels('key1', 10, 'key2', 22);
      });
      test('primitive key, complex value', () {
        var value1 = _activatory.getUntyped(PrimitiveComplexObject);
        var value2 = _activatory.getUntyped(PrimitiveComplexObject);
        testLabels('key1', value1, 'key2', value2);
      });
      test('complex key, complex value', () {
        var key1 = _activatory.getUntyped(PrimitiveComplexObject);
        var key2 = _activatory.getUntyped(PrimitiveComplexObject);
        var value1 = _activatory.getUntyped(PrimitiveComplexObject);
        var value2 = _activatory.getUntyped(PrimitiveComplexObject);
        testLabels(key1, value1, key2, value2);
      });
    });
    test('factories to use', () {
      var value1 = 'value1';
      var key1 = 'key1';
      var value2 = 'value1';
      var key2 = 'key2';
      _activatory.useFunction<String>((ctx) => value1, key: key1);
      _activatory.useFunction<String>((ctx) => value2, key: key2);

      var result1 = _activatory.getUntyped(String, key1);
      var result2 = _activatory.getUntyped(String, key2);
      var result = _activatory.getUntyped(String);

      expect(result1, equals(value1));
      expect(result2, equals(value2));
      expect(result, isNot(equals(result1)));
      expect(result, isNot(equals(result2)));
    });

    test('defined values to use', () {
      var key1 = 'key1';
      var key2 = 'key2';
      _activatory.useGeneratedSingleton<String>(key: key1);
      _activatory.useGeneratedSingleton<String>(key: key2);
      //NOTE: The order does matter
      _activatory.useGeneratedSingleton<String>();

      var result_1a = _activatory.getUntyped(String, key1);
      var result_1b = _activatory.getUntyped(String, key1);
      var result_2a = _activatory.getUntyped(String, key2);
      var result_2b = _activatory.getUntyped(String, key2);
      var result_a = _activatory.getUntyped(String);
      var result_b = _activatory.getUntyped(String);

      expect(result_1a, equals(result_1b));
      expect(result_2a, equals(result_2b));
      expect(result_1a, isNot(equals(result_2a)));

      expect(result_a, equals(result_b));
      expect(result_a, isNot(equals(result_1a)));
      expect(result_a, isNot(equals(result_2a)));
    });
  });

  group('Can create array', () {
    void _assertArray(List items, Type expectedType) {
      expect(items, isNotNull);
      expect(items.length, equals(3));

      var itemsType = items.map((x) => x.runtimeType).cast<Type>().toSet().single;
      expect(itemsType, equals(expectedType));
    }

    group('of primitive type (except enum)', () {
      var primitiveArrayTypes = {
        _getType<List<String>>(): String,
        _getType<List<int>>(): int,
        _getType<List<bool>>(): bool,
        _getType<List<DateTime>>(): DateTime,
        _getType<List<double>>(): double,
      };
      for (var type in primitiveArrayTypes.keys) {
        test(type, () {
          var items = _activatory.getUntyped(type) as List;

          _assertArray(items, primitiveArrayTypes[type]);
        });
      }
    });

    test('of enums', () {
      var items = _activatory.get<List<TestEnum>>();

      _assertArray(items, TestEnum);
      for (var item in items) {
        expect(TestEnum.values, contains(item));
      }
    });

    test('of complex object', () {
      var items = _activatory.get<List<PrimitiveComplexObject>>();

      _assertArray(items, PrimitiveComplexObject);
    });
    group('required in ctor', () {
      test('(concret array requirement)', () {
        var result = _activatory.get<IntArrayInCtor>();

        expect(result, isNotNull);
        _assertArray(result.listField, int);
      });

      test('(closed by inheritance generic array requirement)', () {
        var result = _activatory.get<ClosedByInheritanceGeneric>();

        expect(result, isNotNull);
        _assertArray(result.listField, String);
      });

      test('(with complex type)', () {
        var result = _activatory.get<GenericArrayInCtor<GenericArrayInCtor<int>>>();

        expect(result, isNotNull);
        _assertArray(result.listField, _getType<GenericArrayInCtor<int>>());
      });
    });
  });

  group('Can use generics', () {
    test('for ctor argument', () {
      var genericResult1 = _activatory.get<Generic<bool>>();
      var genericResult2 = _activatory.get<Generic<int>>();

      expect(genericResult1, isNotNull);
      expect(genericResult1.field, isNotNull);

      expect(genericResult2, isNotNull);
      expect(genericResult2.field, isNotNull);
    });

    test('for ctor array argument', () {
      var genericResult1 = _activatory.get<GenericArrayInCtor<bool>>();
      var genericResult2 = _activatory.get<GenericArrayInCtor<int>>();

      expect(genericResult1, isNotNull);
      expect(genericResult1.listField, isNotNull);
      expect(genericResult1.listField, hasLength(3));
      expect(genericResult1.listField, isNot(contains(null)));

      expect(genericResult2, isNotNull);
      expect(genericResult2.listField, isNotNull);
      expect(genericResult2.listField, hasLength(3));
      expect(genericResult2.listField, isNot(contains(null)));
    });
  });

  group('Can create recursive graph ', () {
    test('for object with same object in ctor', () {
      var linked = _activatory.get<LinkedNode>();

      _assertLinkedNode(linked);
    });

    test('with pinned generated values', () {
      _activatory.useGeneratedSingleton<LinkedNode>();
      var linked1 = _activatory.get<LinkedNode>();
      var linked2 = _activatory.get<LinkedNode>();

      _assertLinkedNode(linked1);
      expect(linked1, same(linked2));
    });

    test('with overrided factory recursion call', () {
      _activatory.useFunction<LinkedNode>((ctx) => ctx.create(LinkedNode, ctx));
      var linked = _activatory.get<LinkedNode>();

      expect(linked, isNull);
    });

    test('for object with array in ctor', () {
      var tree = _activatory.get<TreeNode>();

      _assertTreeNode(tree, 3);
      for (var node1 in tree.children) {
        _assertTreeNode(node1, 3);
        for (var node2 in node1.children) {
          _assertTreeNode(node2, 3);
          for (var node3 in node2.children) {
            _assertTreeNode(node3, 0);
          }
        }
      }
    });

    test('for array of objects with array in ctor', () {
      var tree = _activatory.get<List<TreeNode>>();

      for (var node1 in tree) {
        _assertTreeNode(node1, 3);
        for (var node2 in node1.children) {
          _assertTreeNode(node2, 3);
          for (var node3 in node2.children) {
            _assertTreeNode(node3, 3);
            for (var node4 in node3.children) {
              _assertTreeNode(node4, 0);
            }
          }
        }
      }
    });
  });

  group('Can customize', () {
    group('backends', () {
      group('without overrides', () {
        test('take first for complex type to take first ctor', () {
          _activatory.useSingleton('E');
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeFirstDefined;

          var items = List.generate(15, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });

        test('take random named ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeRandomNamedCtor;

          var items = List.generate(15, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['A', 'B', 'C', 'D'];
          expect(result, equals(expected));
        });

        test('take random for complex type to take random ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy = BackendResolutionStrategy.TakeRandom;
          _activatory.useSingleton<String>('E');

          var items = List.generate(200, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['A', 'B', 'C', 'D', 'E'];
          expect(result, equals(expected));
        });

        test('take default ctor for type with default ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeDefaultCtor;
          _activatory.useSingleton<String>('E');

          var items = List.generate(15, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });

        test('take default for class with factory', () {
          _activatory.customize<NamedCtorsAndFactory>().resolutionStrategy = BackendResolutionStrategy.TakeDefaultCtor;
          _activatory.useSingleton<String>('E');

          var items = List.generate(15, (_) => _activatory.get<NamedCtorsAndFactory>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });

        test('take default for class with const ctor', () {
          _activatory.customize<NamedCtorsAndConstCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeDefaultCtor;
          _activatory.useSingleton<String>('E');

          var items = List.generate(15, (_) => _activatory.get<NamedCtorsAndConstCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });
      });

      group('with overrides', () {
        test('take random to take random from overrides', () {
          _activatory.useSingleton(10);
          _activatory.useFunction((ctx) => 20);
          _activatory.useSingleton(30);
          _activatory.useFunction((ctx) => 40);
          _activatory.customize<int>()
            ..arraySize = 30
            ..resolutionStrategy = BackendResolutionStrategy.TakeRandom;

          final generated = _activatory.get<List<int>>();
          var result = SplayTreeSet.from(generated);

          const expected = [10, 20, 30, 40];
          expect(result, equals(expected));
        });

        test('take random to take random from overrides', () {
          _activatory.useSingleton(10);
          _activatory.useFunction((ctx) => 20);
          _activatory.useSingleton(30);
          _activatory.useFunction((ctx) => 40);
          _activatory.customize<int>()
            ..arraySize = 15
            ..resolutionStrategy = BackendResolutionStrategy.TakeFirstDefined;

          final generated = _activatory.get<List<int>>();
          var result = SplayTreeSet.from(generated);

          const expected = [40];
          expect(result, equals(expected));
        });
      });
    });

    test('array sizes per type', () {
      var expectedIntArraySize = 5;
      var expectedNullSize = 0;
      _activatory.customize<int>().arraySize = expectedIntArraySize;
      _activatory.customize<Null>().arraySize = expectedNullSize;

      final intArray = _activatory.get<List<int>>();
      final nullArray = _activatory.get<List<Null>>();

      expect(intArray, hasLength(expectedIntArraySize));
      expect(nullArray, hasLength(expectedNullSize));
    });

    test('array sizes for all types', () {
      final defaultSize = 5;
      _activatory.defaultCustomization.arraySize = defaultSize;

      final intList = _activatory.get<List<int>>();

      expect(intList, hasLength(defaultSize));
    });

    test('recursion limit per type', () {
      var expectedArrayRecursionLimit = 5;
      var expectedRefRecursionLimit = 0;
      _activatory.customize<TreeNode>().maxRecursionLevel = expectedArrayRecursionLimit;
      _activatory.customize<LinkedNode>().maxRecursionLevel = expectedRefRecursionLimit;

      final tree = _activatory.get<TreeNode>();
      final linkedNode = _activatory.get<LinkedNode>();

      _assertTreeNode(tree, 3);
      for (var node1 in tree.children) {
        _assertTreeNode(node1, 3);
        for (var node2 in node1.children) {
          _assertTreeNode(node2, 3);
          for (var node3 in node2.children) {
            _assertTreeNode(node3, 3);
            for (var node4 in node3.children) {
              _assertTreeNode(node4, 0);
            }
          }
        }
      }

      expect(linkedNode, isNotNull);
      expect(linkedNode.next, isNull);
    });
  });

  test('Can create map', () {
    final result = _activatory.get<Map<String, int>>();

    expect(result, isNotNull);
    expect(result, hasLength(_activatory.defaultCustomization.arraySize));
  });

  group('Can create arrays without explicit regestration', () {
    test('with default length', () {
      var result = _activatory.getMany<int>();
      expect(result, isNotNull);
      expect(result, hasLength(3));
      expect(result, isNot(contains(null)));
    });
    test('with parametrized length', () {
      var result = _activatory.getMany<int>(count: 2);
      expect(result, isNotNull);
      expect(result, hasLength(2));
      expect(result, isNot(contains(null)));
    });
    test('with customized per type length', () {
      _activatory.customize<int>().arraySize = 10;
      var result = _activatory.getMany<int>();
      expect(result, isNotNull);
      expect(result, hasLength(10));
      expect(result, isNot(contains(null)));
    });
    test('with customized key', () {
      var key = 'key';
      _activatory.useSingleton(10, key: key);
      var result = _activatory.getMany<int>(key: key);
      expect(result, isNotNull);
      expect(result, hasLength(3));
      var unique = new Set.from(result);
      expect(unique, equals([10]));
    });
  });

  group('Type aliases', () {
    test('allow iterable of primitive type activation', () {
      var result = _activatory.get<PrimitiveIterableInCtor>();

      expect(result, isNotNull);
      expect(result.field, isNotEmpty);
      expect(result.field, hasLength(3));
      expect(result.field, isNot(contains(null)));
    });

    test('allow iterable of complex type activation', () {
      var result = _activatory.get<ComplexIterableInCtor>();

      expect(result, isNotNull);
      expect(result.field, isNotEmpty);
      expect(result.field, hasLength(3));
      expect(result.field, isNot(contains(null)));
    });

    test('allow use subtype activation strategy for parent type', () {
      _activatory.replaceSupperClass<ParentClass, ChildClass>();

      var result = _activatory.get<ParentClass>();

      expect(result, isNotNull);
      expect(result, TypeMatcher<ChildClass>());
    });
  });

  group("Can customize default values usage for", () {
    group("positional arguments", () {
      test("with ReplaceNulls", () {
        _activatory.customize<DefaultPositionalValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceNulls;

        var result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });

      test("with ReplaceAll", () {
        _activatory.customize<DefaultPositionalValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceAll;

        var result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, isNot(equals(DefaultPositionalValues.defaultStringValue)));
        expect(result.nullSetStringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });

      test("with UseAll", () {
        _activatory.customize<DefaultPositionalValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.UseAll;

        var result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNull);
        expect(result.notSetObject, isNull);
        expect(result.nullSetObject, isNull);
      });
    });

    group("named arguments", () {
      test("with ReplaceNulls", () {
        _activatory.customize<DefaultNamedValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceNulls;

        var result = _activatory.get<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNotNull);
        assertComplexObjectIsNotNull(result.nullSetObject);
        assertComplexObjectIsNotNull(result.notSetObject);
      });

      test("with ReplaceAll", () {
        _activatory.customize<DefaultNamedValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceAll;

        var result = _activatory.get<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, isNot(equals(DefaultNamedValues.defaultValue)));
        expect(result.nullSetString, isNotNull);
        assertComplexObjectIsNotNull(result.nullSetObject);
        assertComplexObjectIsNotNull(result.notSetObject);
      });

      test("with UseAll", () {
        _activatory.customize<DefaultNamedValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.UseAll;

        var result = _activatory.get<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNull);
        expect(result.nullSetObject, isNull);
        expect(result.notSetObject, isNull);
      });
    });
  });

  test('Can customize per key', () {
    _activatory.customize<int>(key: 'A').arraySize = 10;
    _activatory.customize<int>(key: 'B').arraySize = 1;

    var resultA = _activatory.get<List<int>>('A');
    var resultB = _activatory.get<List<int>>('B');
    var resultC = _activatory.get<List<int>>();

    expect(resultA, hasLength(10));
    expect(resultB, hasLength(1));
    expect(resultC, hasLength(3));
  });

  test('Can fill fields', () {
    var result = _activatory.get<FiledsWithPublicSetters>();

    expect(result.finalField, isNotNull);
    expect(result.publicField, isNotNull);
    expect(result.publicProperty, isNull);
  });

  group('Can customize fields usage', () {
    test('FieldsAndSetters', () {
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFillingStrategy =
          FieldsAutoFillingStrategy.FieldsAndSetters;

      var result = _activatory.get<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNotNull);
      expect(result.publicProperty, isNotNull);
    });

    test('fields only', () {
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.Fields;

      var result = _activatory.get<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNotNull);
      expect(result.publicProperty, isNull);
    });

    test('none', () {
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.None;

      var result = _activatory.get<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNull);
      expect(result.publicProperty, isNull);
    });
  });

  group('Can select item from predefined iterable', () {
    test('with typed api', () {
      final variants = _activatory.getMany<int>();
      final result = _activatory.take<int>(variants);
      expect(variants, contains(result));
    });

    test('with not typed api', () {
      final variants = _activatory.getMany<int>();
      final result = _activatory.takeUntyped(variants);
      expect(variants, contains(result));
    });
  });
}

void _assertLinkedNode(LinkedNode linked) {
  expect(linked, isNotNull);
  expect(linked.next, isNotNull);
  expect(linked.next.next, isNotNull);
}

void _assertTreeNode(TreeNode node, int childrenCount) {
  expect(node, isNotNull);
  expect(node.children, isNotNull);
  expect(node.children, hasLength(childrenCount));
}
