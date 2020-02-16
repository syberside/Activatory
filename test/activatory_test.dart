@TestOn('vm')
import 'dart:collection';

import 'package:activatory/activatory.dart';
import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/activatory.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/customization/factory-resolving/factory_resolving_strategy.dart';
import 'package:activatory/src/post-activation/fields_auto_filling_strategy.dart';
import 'package:test/test.dart';

import 'test_classes.dart';

/// TODO: Tests MUST BE refactored: https://github.com/syberside/Activatory/issues/33
void main() {
  Type _getType<T>() => T;

  Activatory _activatory;
  setUp(() {
    _activatory = Activatory();
  });

  void _assertComplexObjectIsNotNull(PrimitiveComplexObject obj) {
    expect(obj, isNotNull);
    expect(obj.dateTimeField, isNotNull);
    expect(obj.boolField, isNotNull);
    expect(obj.doubleField, isNotNull);
    expect(obj.stringField, isNotNull);
    expect(obj.intField, isNotNull);
    expect(obj.enumField, isNotNull);
    expect(TestEnum.values, contains(obj.enumField));
  }

  final supportedPrimitiveTypes = [String, int, bool, double, DateTime, Duration, TestEnum];
  group('Can generate primitive types ${supportedPrimitiveTypes}', () {
    for (final type in supportedPrimitiveTypes) {
      test(type, () {
        final result = _activatory.getUntyped(type);

        expect(result, isNotNull);
        expect(result.runtimeType, same(type));
      });
    }
  });

  group('Can create complex object', () {
    test('with default (implicit) ctor', () {
      final result = _activatory.get<DefaultCtor>();

      expect(result, isNotNull);
    });

    test('with primitives only in ctor parameters', () {
      final result = _activatory.get<PrimitiveComplexObject>();
      _assertComplexObjectIsNotNull(result);
    });

    test('with not only primitives in ctor parameters', () {
      final result = _activatory.get<NonPrimitiveComplexObject>();

      expect(result, isNotNull);
      expect(result.intField, isNotNull);
      _assertComplexObjectIsNotNull(result.primitiveComplexObject);
    });

    test('with named ctor', () {
      final result = _activatory.get<NamedCtor>();

      expect(result, isNotNull);
      expect(result.stringField, isNotNull);
    });

    test('with factory ctor', () {
      final result = _activatory.get<FactoryCtor>();

      expect(result, isNotNull);
      expect(result.stringField, isNotNull);
      expect(result.nonFactoryField, isNull);
    });
  });

  group('Cant create', () {
    test('abstract class', () {
      expect(() => _activatory.get<AbstractClass>(), throwsA(const TypeMatcher<ActivationException>()));
    });

    test('class without public ctor', () {
      expect(() => _activatory.get<NoPublicCtor>(), throwsA(const TypeMatcher<ActivationException>()));
    });
  });

  group('Default values of', () {
    group('positional arguments are', () {
      test('ignored if they are nulls and used if not', () {
        final result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNotNull);
        _assertComplexObjectIsNotNull(result.notSetObject);
        _assertComplexObjectIsNotNull(result.nullSetObject);
      });
    });

    group('named arguments are', () {
      test('ignored if they are nulls and used if not', () {
        final result = _activatory.get<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNotNull);
        _assertComplexObjectIsNotNull(result.nullSetObject);
        _assertComplexObjectIsNotNull(result.notSetObject);
      });
    });
  });

  group('Can override default factory resolution logic ', () {
    group('with explicit factory for', () {
      test('primitive type', () {
        final expected = _activatory.get<int>();

        _activatory.useFunction((_) => expected);
        final result1 = _activatory.get<int>();
        final result2 = _activatory.get<int>();

        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test('complex type', () {
        final expected = DefaultCtor();

        _activatory.useFunction((_) => expected);
        final result1 = _activatory.get<DefaultCtor>();
        final result2 = _activatory.get<DefaultCtor>();

        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });

    group('with generated singleton value for', () {
      test('primitive type', () {
        _activatory.useGeneratedSingleton<DateTime>();
        final result1 = _activatory.get<DateTime>();
        final result2 = _activatory.get<DateTime>();

        expect(result1, equals(result2));
      });

      test('complex type', () {
        _activatory.useGeneratedSingleton<DefaultCtor>();
        final result1 = _activatory.get<DefaultCtor>();
        final result2 = _activatory.get<DefaultCtor>();

        expect(result1, same(result2));
      });
    });

    group('with predefined value for', () {
      test('primitive type', () {
        final expected = _activatory.get<int>();

        _activatory.useSingleton(expected);
        final result1 = _activatory.get<int>();
        final result2 = _activatory.get<int>();

        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test('complex type', () {
        final expected = DefaultCtor();

        _activatory.useSingleton(expected);
        final result1 = _activatory.get<DefaultCtor>();
        final result2 = _activatory.get<DefaultCtor>();

        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });

    group('with predefined values for', () {
      test('primitive type', () {
        final expected = _activatory.getMany<int>(count: 100);

        _activatory.useOneOf(expected);
        final result1 = _activatory.get<int>();
        final result2 = _activatory.get<int>();

        expect(expected, contains(result1));
        expect(expected, contains(result2));
        expect(result1, isNot(equals(result2)));
      });

      test('complex type', () {
        final expected = Iterable.generate(100, (_) => DefaultCtor()).toList();

        _activatory.useOneOf(expected);
        final result1 = _activatory.get<DefaultCtor>();
        final result2 = _activatory.get<DefaultCtor>();

        expect(expected, contains(result1));
        expect(expected, contains(result2));
        expect(result1, isNot(equals(result2)));
      });
    });
  });

  group('Can use labels to define', () {
    group('pined values to use:', () {
      void testLabels<TKey, TValue>(TKey key1, TValue value1, TKey key2, TValue value2) {
        _activatory.useSingleton(value1, key: key1);
        _activatory.useSingleton(value2, key: key2);

        final result1 = _activatory.getUntyped(TValue, key: key1);
        final result2 = _activatory.getUntyped(TValue, key: key2);
        final result = _activatory.getUntyped(TValue);

        expect(result1, equals(value1));
        expect(result2, equals(value2));
        expect(result, isNot(equals(result1)));
        expect(result, isNot(equals(result2)));
      }

      test('primitive key, primitive value', () {
        testLabels('key1', 10, 'key2', 22);
      });

      test('primitive key, complex value', () {
        final value1 = _activatory.getUntyped(PrimitiveComplexObject);
        final value2 = _activatory.getUntyped(PrimitiveComplexObject);

        testLabels('key1', value1, 'key2', value2);
      });
      test('complex key, complex value', () {
        final key1 = _activatory.getUntyped(PrimitiveComplexObject);
        final key2 = _activatory.getUntyped(PrimitiveComplexObject);
        final value1 = _activatory.getUntyped(PrimitiveComplexObject);
        final value2 = _activatory.getUntyped(PrimitiveComplexObject);

        testLabels(key1, value1, key2, value2);
      });
    });
    test('factories to use', () {
      const value1 = 'value1';
      const key1 = 'key1';
      const value2 = 'value1';
      const key2 = 'key2';
      _activatory.useFunction<String>((ctx) => value1, key: key1);
      _activatory.useFunction<String>((ctx) => value2, key: key2);

      final result1 = _activatory.getUntyped(String, key: key1);
      final result2 = _activatory.getUntyped(String, key: key2);
      final result = _activatory.getUntyped(String);

      expect(result1, equals(value1));
      expect(result2, equals(value2));
      expect(result, isNot(equals(result1)));
      expect(result, isNot(equals(result2)));
    });

    test('generated values to use', () {
      const key1 = 'key1';
      const key2 = 'key2';
      _activatory.useGeneratedSingleton<String>(key: key1);
      _activatory.useGeneratedSingleton<String>(key: key2);
      //NOTE: The order does matter
      _activatory.useGeneratedSingleton<String>();

      final resultK1A = _activatory.getUntyped(String, key: key1);
      final resultK1B = _activatory.getUntyped(String, key: key1);
      final resultK2A = _activatory.getUntyped(String, key: key2);
      final resultK2B = _activatory.getUntyped(String, key: key2);
      final resultA = _activatory.getUntyped(String);
      final resultB = _activatory.getUntyped(String);

      expect(resultK1A, equals(resultK1B));
      expect(resultK2A, equals(resultK2B));
      expect(resultK1A, isNot(equals(resultK2A)));

      expect(resultA, equals(resultB));
      expect(resultA, isNot(equals(resultK1A)));
      expect(resultA, isNot(equals(resultK2A)));
    });
  });

  test('Keyless setup is used if no matching keyed setup exists', () {
    const value1 = 42;
    const value2 = 13;
    const key1 = 'key1';
    const key2 = 'key2';
    _activatory.useSingleton(value1, key: key1);
    _activatory.useSingleton(value2, key: key2);
    _activatory.useFunction((ctx) => ctx.create<int>().toString());

    final result1 = _activatory.get<String>(key: key1);
    final result2 = _activatory.get<String>(key: key2);
    expect(result1, equals(value1.toString()));
    expect(result2, equals(value2.toString()));
  });

  group('Can create array', () {
    void _assertArray(List<Object> items, Type expectedType) {
      expect(items, isNotNull);
      expect(items.length, equals(3));

      final itemsType = items.map((x) => x.runtimeType).cast<Type>().toSet().single;
      expect(itemsType, equals(expectedType));
    }

    group('of primitive type (except enum)', () {
      final primitiveArrayTypes = {
        _getType<List<String>>(): String,
        _getType<List<int>>(): int,
        _getType<List<double>>(): double,
        _getType<List<bool>>(): bool,
        _getType<List<DateTime>>(): DateTime,
        _getType<List<Duration>>(): Duration,
      };
      for (final type in primitiveArrayTypes.keys) {
        test(type, () {
          final items = _activatory.getUntyped(type) as List;

          _assertArray(items, primitiveArrayTypes[type]);
        });
      }
    });

    test('of enums', () {
      final items = _activatory.get<List<TestEnum>>();

      _assertArray(items, TestEnum);
      for (final item in items) {
        expect(TestEnum.values, contains(item));
      }
    });

    test('of complex object', () {
      final items = _activatory.get<List<PrimitiveComplexObject>>();

      _assertArray(items, PrimitiveComplexObject);
    });
    group('required in ctor', () {
      test('(concret array requirement)', () {
        final result = _activatory.get<IntArrayInCtor>();

        expect(result, isNotNull);
        _assertArray(result.listField, int);
      });

      test('(closed by inheritance generic array requirement)', () {
        final result = _activatory.get<ClosedByInheritanceGeneric>();

        expect(result, isNotNull);
        _assertArray(result.listField, String);
      });

      test('(with complex type)', () {
        final result = _activatory.get<GenericArrayInCtor<GenericArrayInCtor<int>>>();

        expect(result, isNotNull);
        _assertArray(result.listField, _getType<GenericArrayInCtor<int>>());
      });
    });
  });

  group('Can use generics', () {
    test('for ctor argument', () {
      final genericResult1 = _activatory.get<Generic<bool>>();
      final genericResult2 = _activatory.get<Generic<int>>();

      expect(genericResult1, isNotNull);
      expect(genericResult1.field, isNotNull);

      expect(genericResult2, isNotNull);
      expect(genericResult2.field, isNotNull);
    });

    test('for ctor array argument', () {
      final genericResult1 = _activatory.get<GenericArrayInCtor<bool>>();
      final genericResult2 = _activatory.get<GenericArrayInCtor<int>>();

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
      final linked = _activatory.get<LinkedNode>();

      _assertLinkedNode(linked);
    });

    test('with pinned generated values', () {
      _activatory.useGeneratedSingleton<LinkedNode>();
      final linked1 = _activatory.get<LinkedNode>();
      final linked2 = _activatory.get<LinkedNode>();

      _assertLinkedNode(linked1);
      expect(linked1, same(linked2));
    });

    test('with overrided factory recursion call', () {
      _activatory.useFunction<LinkedNode>((ctx) => ctx.createUntyped(LinkedNode) as LinkedNode);
      final linked = _activatory.get<LinkedNode>();

      expect(linked, isNull);
    });

    test('for object with array in ctor', () {
      final tree = _activatory.get<TreeNode>();

      _assertTreeNode(tree, 3);
      for (final node1 in tree.children) {
        _assertTreeNode(node1, 3);
        for (final node2 in node1.children) {
          _assertTreeNode(node2, 0);
        }
      }
    });

    test('for array with recursive object', () {
      final list = _activatory.get<List<TreeNode>>();
      for (final node in list) {
        _assertTreeNode(node, 3);
        for (final node1 in node.children) {
          _assertTreeNode(node1, 3);
          for (final node2 in node1.children) {
            _assertTreeNode(node2, 0);
          }
        }
      }
    });

    test('for array of objects with array in ctor', () {
      final tree = _activatory.get<List<TreeNode>>();

      for (final node1 in tree) {
        _assertTreeNode(node1, 3);
        for (final node2 in node1.children) {
          _assertTreeNode(node2, 3);
          for (final node3 in node2.children) {
            _assertTreeNode(node3, 0);
          }
        }
      }
    });
  });

  group('Can customize', () {
    group('factories', () {
      group('without overrides', () {
        test('take first for complex type to take first ctor', () {
          _activatory.useSingleton('E');
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolvingStrategy =
              FactoryResolvingStrategy.TakeFirstDefined;

          final items = List.generate(15, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          final result = SplayTreeSet<String>.from(items.map<String>((item) => item.field));

          final expected = ['E'];
          expect(result, equals(expected));
        });

        test('take random named ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolvingStrategy =
              FactoryResolvingStrategy.TakeRandomNamedCtor;

          final items = List.generate(30, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          final result = SplayTreeSet<String>.from(items.map<String>((item) => item.field));

          final expected = ['A', 'B', 'C', 'D'];
          expect(result, equals(expected));
        });

        test('take random for complex type to take random ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolvingStrategy = FactoryResolvingStrategy.TakeRandom;
          _activatory.useSingleton<String>('E');

          final items = List.generate(200, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          final result = SplayTreeSet<String>.from(items.map<String>((item) => item.field));

          final expected = ['A', 'B', 'C', 'D', 'E'];
          expect(result, equals(expected));
        });

        test('take default ctor for type with default ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolvingStrategy =
              FactoryResolvingStrategy.TakeDefaultCtor;
          _activatory.useSingleton<String>('E');

          final items = List.generate(15, (_) => _activatory.get<NamedCtorsAndDefaultCtor>());
          final result = SplayTreeSet<String>.from(items.map<String>((item) => item.field));

          final expected = ['E'];
          expect(result, equals(expected));
        });

        test('take default for class with factory', () {
          _activatory.customize<NamedCtorsAndFactory>().resolvingStrategy = FactoryResolvingStrategy.TakeDefaultCtor;
          _activatory.useSingleton<String>('E');

          final items = List.generate(15, (_) => _activatory.get<NamedCtorsAndFactory>());
          final result = SplayTreeSet<String>.from(items.map<String>((item) => item.field));

          final expected = ['E'];
          expect(result, equals(expected));
        });

        test('take default for class with const ctor', () {
          _activatory.customize<NamedCtorsAndConstCtor>().resolvingStrategy = FactoryResolvingStrategy.TakeDefaultCtor;
          _activatory.useSingleton<String>('E');

          final items = List.generate(15, (_) => _activatory.get<NamedCtorsAndConstCtor>());
          final result = SplayTreeSet<String>.from(items.map<String>((item) => item.field));

          final expected = ['E'];
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
            ..resolvingStrategy = FactoryResolvingStrategy.TakeRandom;

          final generated = _activatory.get<List<int>>();
          final result = SplayTreeSet<int>.from(generated);

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
            ..resolvingStrategy = FactoryResolvingStrategy.TakeFirstDefined;

          final generated = _activatory.get<List<int>>();
          final result = SplayTreeSet<int>.from(generated);

          const expected = [40];
          expect(result, equals(expected));
        });
      });
    });

    test('array sizes per type', () {
      const expectedIntArraySize = 5;
      const expectedNullSize = 0;
      _activatory.customize<int>().arraySize = expectedIntArraySize;
      _activatory.customize<Null>().arraySize = expectedNullSize;

      final intArray = _activatory.get<List<int>>();
      final nullArray = _activatory.get<List<Null>>();

      expect(intArray, hasLength(expectedIntArraySize));
      expect(nullArray, hasLength(expectedNullSize));
    });

    test('array sizes for all types', () {
      const defaultSize = 5;
      _activatory.defaultCustomization.arraySize = defaultSize;

      final intList = _activatory.get<List<int>>();

      expect(intList, hasLength(defaultSize));
    });

    test('recursion limit per type', () {
      const expectedArrayRecursionLimit = 5;
      const expectedRefRecursionLimit = 2;
      _activatory.customize<TreeNode>().maxRecursionLevel = expectedArrayRecursionLimit;
      _activatory.customize<LinkedNode>().maxRecursionLevel = expectedRefRecursionLimit;

      final tree = _activatory.get<TreeNode>();
      final linkedNode = _activatory.get<LinkedNode>();

      _assertTreeNode(tree, 3);
      for (final node1 in tree.children) {
        _assertTreeNode(node1, 3);
        for (final node2 in node1.children) {
          _assertTreeNode(node2, 3);
          for (final node3 in node2.children) {
            _assertTreeNode(node3, 0);
          }
        }
      }

      expect(linkedNode, isNotNull);
      expect(linkedNode.next, isNotNull);
      expect(linkedNode.next.next, isNull);
    });
  });

  test('Can create map', () {
    final result = _activatory.get<Map<String, int>>();

    expect(result, isNotNull);
    expect(result, hasLength(_activatory.defaultCustomization.arraySize));
  });

  group('Can create arrays', () {
    test('with default length', () {
      final result = _activatory.getMany<int>();
      expect(result, isNotNull);
      expect(result, hasLength(3));
      expect(result, isNot(contains(null)));
    });

    test('with parametrized length', () {
      final result = _activatory.getMany<int>(count: 2);
      expect(result, isNotNull);
      expect(result, hasLength(2));
      expect(result, isNot(contains(null)));
    });

    test('with customized per type length', () {
      _activatory.customize<int>().arraySize = 10;
      final result = _activatory.getMany<int>();
      expect(result, isNotNull);
      expect(result, hasLength(10));
      expect(result, isNot(contains(null)));
    });

    test('with customized key', () {
      const key = 'key';
      _activatory.useSingleton(10, key: key);
      final result = _activatory.getMany<int>(key: key);
      expect(result, isNotNull);
      expect(result, hasLength(3));
      final unique = Set<int>.from(result);
      expect(unique, equals([10]));
    });
  });

  group('Type type-aliasing', () {
    test('allow iterable of primitive type activation', () {
      final result = _activatory.get<PrimitiveIterableInCtor>();

      expect(result, isNotNull);
      expect(result.field, isNotEmpty);
      expect(result.field, hasLength(3));
      expect(result.field, isNot(contains(null)));
    });

    test('allow iterable of complex type activation', () {
      final result = _activatory.get<ComplexIterableInCtor>();

      expect(result, isNotNull);
      expect(result.field, isNotEmpty);
      expect(result.field, hasLength(3));
      expect(result.field, isNot(contains(null)));
    });

    test('allow use subtype activation strategy for parent type', () {
      _activatory.replaceSupperClass<ParentClass, ChildClass>();

      final result = _activatory.get<ParentClass>();

      expect(result, isNotNull);
      expect(result, const TypeMatcher<ChildClass>());
    });
  });

  group('Can customize default values usage for', () {
    group('positional arguments', () {
      test('with ReplaceNulls', () {
        _activatory.customize<DefaultPositionalValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceNulls;

        final result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNotNull);
        _assertComplexObjectIsNotNull(result.notSetObject);
        _assertComplexObjectIsNotNull(result.nullSetObject);
      });

      test('with ReplaceAll', () {
        _activatory.customize<DefaultPositionalValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceAll;

        final result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, isNot(equals(DefaultPositionalValues.defaultStringValue)));
        expect(result.nullSetStringValue, isNotNull);
        _assertComplexObjectIsNotNull(result.notSetObject);
        _assertComplexObjectIsNotNull(result.nullSetObject);
      });

      test('with UseAll', () {
        _activatory.customize<DefaultPositionalValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.UseAll;

        final result = _activatory.get<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNull);
        expect(result.notSetObject, isNull);
        expect(result.nullSetObject, isNull);
      });
    });

    group('named arguments', () {
      test('with ReplaceNulls', () {
        _activatory.customize<DefaultNamedValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceNulls;

        final result = _activatory.get<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNotNull);
        _assertComplexObjectIsNotNull(result.nullSetObject);
        _assertComplexObjectIsNotNull(result.notSetObject);
      });

      test('with ReplaceAll', () {
        _activatory.customize<DefaultNamedValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.ReplaceAll;

        final result = _activatory.get<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, isNot(equals(DefaultNamedValues.defaultValue)));
        expect(result.nullSetString, isNotNull);
        _assertComplexObjectIsNotNull(result.nullSetObject);
        _assertComplexObjectIsNotNull(result.notSetObject);
      });

      test('with UseAll', () {
        _activatory.customize<DefaultNamedValues>().defaultValuesHandlingStrategy =
            DefaultValuesHandlingStrategy.UseAll;

        final result = _activatory.get<DefaultNamedValues>();

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

    final resultA = _activatory.get<List<int>>(key: 'A');
    final resultB = _activatory.get<List<int>>(key: 'B');
    final resultC = _activatory.get<List<int>>();

    expect(resultA, hasLength(10));
    expect(resultB, hasLength(1));
    expect(resultC, hasLength(3));
  });

  test('Can fill fields', () {
    final result = _activatory.get<FiledsWithPublicSetters>();

    expect(result.finalField, isNotNull);
    expect(result.publicField, isNotNull);
    expect(result.publicProperty, isNull);
  });

  group('Can customize fields usage', () {
    test('FieldsAndSetters', () {
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFillingStrategy =
          FieldsAutoFillingStrategy.FieldsAndSetters;

      final result = _activatory.get<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNotNull);
      expect(result.publicProperty, isNotNull);
    });

    test('fields only', () {
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.Fields;

      final result = _activatory.get<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNotNull);
      expect(result.publicProperty, isNull);
    });

    test('none', () {
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.None;

      final result = _activatory.get<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNull);
      expect(result.publicProperty, isNull);
    });
  });

  group('Can select from predefined iterable', () {
    test('single item with typed api', () {
      final variants = _activatory.getMany<int>();

      final result = _activatory.take(variants);

      expect(variants, contains(result));
    });

    test('single item with typed api and expect some items', () {
      final variants = _activatory.getMany<int>();

      final result = _activatory.take(variants, except: variants.skip(1));

      expect(result, equals(variants.first));
    });

    test('single item with not typed api', () {
      final variants = _activatory.getMany<int>();

      final result = _activatory.takeUntyped(variants);

      expect(variants, contains(result));
    });

    test('multiple item with typed api', () {
      final variants = _activatory.getMany<int>(count: 10);

      final result = _activatory.takeMany<int>(variants, count: 5);

      expect(result, hasLength(5));
      expect(variants.toSet(), containsAll(result.toSet()));
    });

    test('multiple item with not typed api', () {
      final variants = _activatory.getMany<int>(count: 10);

      final result = _activatory.takeMany(variants, count: 5);

      expect(result, hasLength(5));
      expect(variants.toSet(), containsAll(result.toSet()));
    });

    test('multiple item except one of them with typed api', () {
      final variants = _activatory.getMany<int>(count: 10);
      final exclude = _activatory.take(variants);

      final result = _activatory.takeMany<int>(variants, count: 10, except: [exclude]);

      expect(result, isNot(contains(exclude)));
      expect(result, hasLength(10));
      expect(variants.toSet(), containsAll(result.toSet()));
    });
  });

  group('FactoryResolvingStrategy tests', () {
    test('TakeFirstDefined', () {
      _activatory.customize<SomeClassWithConstructors>().resolvingStrategy =
          FactoryResolvingStrategy.TakeFirstDefined; //Default strategy
      final firstDefinedCtorCallCount =
          _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'named1').length; // 100

      _activatory.useFunction((ctx) => SomeClassWithConstructors('hello'));
      final latestOverrideCallCount =
          _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'hello').length; // 100

      expect(firstDefinedCtorCallCount, 100);
      expect(latestOverrideCallCount, 100);
    });

    test('TakeRandomNamedCtor', () {
      _activatory.customize<SomeClassWithConstructors>().resolvingStrategy =
          FactoryResolvingStrategy.TakeRandomNamedCtor;

      final items = _activatory.getMany<SomeClassWithConstructors>(count: 100);
      final firstNamedCtorCallsCount =
          items.where((x) => x.value == 'named1').length; //exact count is unknown, but approximately equals 50
      final secondNamedCtorCallsCount =
          items.where((x) => x.value == 'named2').length; //exact count is unknown, but approximately equals 50
      final totalCtorCallsCount = firstNamedCtorCallsCount + secondNamedCtorCallsCount; // 100

      _activatory.useFunction((ctx) => SomeClassWithConstructors('hello1'));
      final overrideUsedCount1 =
          _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'hello1').length; // 100

      expect(firstNamedCtorCallsCount, greaterThan(0));
      expect(secondNamedCtorCallsCount, greaterThan(0));
      expect(totalCtorCallsCount, 100);
      expect(overrideUsedCount1, 0);
    });

    test('TakeRandom', () {
      _activatory.customize<SomeClassWithConstructors>().resolvingStrategy = FactoryResolvingStrategy.TakeRandom;

      final items = _activatory.getMany<SomeClassWithConstructors>(count: 100);
      final firstNamedCtorCallsCount =
          items.where((x) => x.value == 'named1').length; //exact count is unknown, but approximately equals 33
      final secondNamedCtorCallsCount =
          items.where((x) => x.value == 'named2').length; //exact count is unknown, but approximately equals 33
      final defaultCtorCallsCount =
          items.where((x) => !x.value.startsWith('named')).length; //exact count is unknown, but approximately equals 33
      final totalCtorCallCount = firstNamedCtorCallsCount + secondNamedCtorCallsCount + defaultCtorCallsCount; // 100

      _activatory.useFunction((ctx) => SomeClassWithConstructors('hello'));
      final items2 = _activatory.getMany<SomeClassWithConstructors>(count: 100);
      final overrideUsedCount =
          items2.where((x) => x.value == 'hello').length; //exact count is unknown, but approximately equals 25
      final firstNamedCtorCallsCount2 =
          items2.where((x) => x.value == 'named1').length; //exact count is unknown, but approximately equals 25
      final secondNamedCtorCallsCount2 =
          items2.where((x) => x.value == 'named2').length; //exact count is unknown, but approximately equals 25
      final defaultCtorCallsCount2 = items2
          .where((x) => x.value != 'hello' && !x.value.startsWith('named'))
          .length; //exact count is unknown, but approximately equals 25
      final totalOverrideCallsCount =
          overrideUsedCount + firstNamedCtorCallsCount2 + secondNamedCtorCallsCount2 + defaultCtorCallsCount2;

      expect(firstNamedCtorCallsCount, greaterThan(0));
      expect(secondNamedCtorCallsCount, greaterThan(0));
      expect(defaultCtorCallsCount, greaterThan(0));
      expect(totalCtorCallCount, 100);
      expect(overrideUsedCount, greaterThan(0));
      expect(firstNamedCtorCallsCount2, greaterThan(0));
      expect(secondNamedCtorCallsCount2, greaterThan(0));
      expect(defaultCtorCallsCount2, greaterThan(0));
      expect(totalOverrideCallsCount, 100);
    });

    test('TakeDefaultCtor', () {
      _activatory.customize<SomeClassWithConstructors>().resolvingStrategy = FactoryResolvingStrategy.TakeDefaultCtor;

      final items = _activatory.getMany<SomeClassWithConstructors>(count: 100);
      final defaultCtorCallsCount = items.where((x) => !x.value.startsWith('named')).length; //100

      _activatory.useFunction((ctx) => SomeClassWithConstructors('hello'));
      final overrideUsedCount =
          _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'hello').length; //0

      expect(defaultCtorCallsCount, 100);
      expect(overrideUsedCount, 0);
    });
  });
}

class SomeClassWithConstructors {
  final String value;

  SomeClassWithConstructors.named1() : this('named1');

  SomeClassWithConstructors(this.value);

  SomeClassWithConstructors.named2() : this('named2');
}
// ignore_for_file: sort_unnamed_constructors_first

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
