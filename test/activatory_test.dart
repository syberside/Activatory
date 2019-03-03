import 'dart:collection';

import 'package:activatory/activatory.dart';
import 'package:activatory/src/activatory.dart';
import 'package:activatory/src/customization/backend_resolution_strategy.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/post_activation/fields_auto_fill.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'task_params.dart';
import 'test-classes.dart';

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
        var result = _activatory.get(type);
        expect(result, isNotNull);
        expect(result.runtimeType, same(type));
      });
    }
  });

  group('Can create complex object', () {
    test('with default (implicit) ctor', () {
      var result = _activatory.getTyped<DefaultCtor>();
      expect(result, isNotNull);
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
      expect(() => _activatory.getTyped<AbstractClass>(), throwsA(TypeMatcher<ActivationException>()));
    });

    test('class without public ctor', () {
      expect(() => _activatory.getTyped<NoPublicCtor>(), throwsA(TypeMatcher<ActivationException>()));
    });
  });

  group("Default values of", () {
    group("positional arguments are", () {
      test("ignored if they are nulls and used if not", () {
        var result = _activatory.getTyped<DefaultPositionalValues>();
        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });
    });

    group("named arguments are", () {
      test("ignored if they are nulls and used if not", () {
        var result = _activatory.getTyped<DefaultNamedValues>();
        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNotNull);
        assertComplexObjectIsNotNull(result.nullSetObject);
        assertComplexObjectIsNotNull(result.notSetObject);
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

    group("with pin for", () {
      test("primitive type", () {
        _activatory.pin<DateTime>();
        var result1 = _activatory.getTyped<DateTime>();
        var result2 = _activatory.getTyped<DateTime>();
        expect(result1, equals(result2));
      });

      test("complex type", () {
        _activatory.pin<DefaultCtor>();
        var result1 = _activatory.getTyped<DefaultCtor>();
        var result2 = _activatory.getTyped<DefaultCtor>();
        expect(result1, same(result2));
      });
    });

    group("with pined value for", () {
      test("primitive type", () {
        var expected = _activatory.getTyped<int>();
        _activatory.pinValue(expected);
        var result1 = _activatory.getTyped<int>();
        var result2 = _activatory.getTyped<int>();
        expect(result1, equals(expected));
        expect(result2, equals(expected));
      });

      test("complex type", () {
        var expected = new DefaultCtor();
        _activatory.pinValue(expected);
        var result1 = _activatory.getTyped<DefaultCtor>();
        var result2 = _activatory.getTyped<DefaultCtor>();
        expect(result1, same(expected));
        expect(result2, same(expected));
      });
    });
  });

  group('Can use labels to define', () {
    group('pined values to use:', () {
      void testLabels<TKey, TValue>(TKey key1, TValue value1, TKey key2, TValue value2) {
        _activatory.pinValue(value1, key: key1);
        _activatory.pinValue(value2, key: key2);

        var result1 = _activatory.get(TValue, key1);
        var result2 = _activatory.get(TValue, key2);
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
    test('factories to use', () {
      var value1 = 'value1';
      var key1 = 'key1';
      var value2 = 'value1';
      var key2 = 'key2';
      _activatory.override<String>((ctx) => value1, key: key1);
      _activatory.override<String>((ctx) => value2, key: key2);

      var result1 = _activatory.get(String, key1);
      var result2 = _activatory.get(String, key2);
      var result = _activatory.get(String);

      expect(result1, equals(value1));
      expect(result2, equals(value2));
      expect(result, isNot(equals(result1)));
      expect(result, isNot(equals(result2)));
    });

    test('defined values to use', () {
      var key1 = 'key1';
      var key2 = 'key2';
      _activatory.pin<String>(key: key1);
      _activatory.pin<String>(key: key2);
      //NOTE: The order does matter
      _activatory.pin<String>();

      var result_1a = _activatory.get(String, key1);
      var result_1b = _activatory.get(String, key1);
      var result_2a = _activatory.get(String, key2);
      var result_2b = _activatory.get(String, key2);
      var result_a = _activatory.get(String);
      var result_b = _activatory.get(String);

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
          var items = _activatory.get(type) as List;

          _assertArray(items, primitiveArrayTypes[type]);
        });
      }

      test('of enums with explicit array registration', () {
        _activatory.registerArray<TestEnum>();
        var items = _activatory.getTyped<List<TestEnum>>();

        _assertArray(items, TestEnum);
        for (var item in items) {
          expect(TestEnum.values, contains(item));
        }
      });
    });
    test('of complex object with explicit registration', () {
      _activatory.registerArray<PrimitiveComplexObject>();
      var items = _activatory.getTyped<List<PrimitiveComplexObject>>();

      _assertArray(items, PrimitiveComplexObject);
    });
    group('required in ctor', () {
      test('(concret array requirement)', () {
        var result = _activatory.getTyped<IntArrayInCtor>();

        expect(result, isNotNull);
        _assertArray(result.listField, int);
      });

      test('(closed by inheritance generic array requirement)', () {
        var result = _activatory.getTyped<ClosedByInheritanceGeneric>();

        expect(result, isNotNull);
        _assertArray(result.listField, String);
      });
    });
  });

  test('Cant create array of complex type without explicit registration', () {
    expect(() => _activatory.getTyped<List<PrimitiveComplexObject>>(), throwsA(TypeMatcher<ActivationException>()));
  });

  group('Can use generics with explicit overriding', () {
    void overrideGeneric<T>() => _activatory.override((ctx) => new Generic<T>(ctx.createTyped<T>(ctx)));
    void overrideGenericArray<T>() =>
        _activatory.override((ctx) => new GenericArrayInCtor<T>(ctx.createTyped<List<T>>(ctx)));

    test('for ctor argument', () {
      overrideGeneric<bool>();
      overrideGeneric<int>();

      var genericResult1 = _activatory.getTyped<Generic<bool>>();
      var genericResult2 = _activatory.getTyped<Generic<int>>();

      expect(genericResult1, isNotNull);
      expect(genericResult1.field, isNotNull);

      expect(genericResult2, isNotNull);
      expect(genericResult2.field, isNotNull);
    });

    test('for ctor array argument', () {
      overrideGenericArray<bool>();
      overrideGenericArray<int>();

      var genericResult1 = _activatory.getTyped<GenericArrayInCtor<bool>>();
      var genericResult2 = _activatory.getTyped<GenericArrayInCtor<int>>();

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
      var linked = _activatory.getTyped<LinkedNode>();

      _assertLinkedNode(linked);
    });

    test('with pinned generated values', () {
      _activatory.pin<LinkedNode>();
      var linked1 = _activatory.getTyped<LinkedNode>();
      var linked2 = _activatory.getTyped<LinkedNode>();

      _assertLinkedNode(linked1);
      expect(linked1, same(linked2));
    });

    test('with overrided factory recursion call', () {
      _activatory.override<LinkedNode>((ctx) => ctx.create(LinkedNode, ctx));
      var linked = _activatory.getTyped<LinkedNode>();

      expect(linked, isNull);
    });

    test('for object with array in ctor', () {
      _activatory.registerArray<TreeNode>();
      var tree = _activatory.getTyped<TreeNode>();

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
      _activatory.registerArray<TreeNode>();
      var tree = _activatory.getTyped<List<TreeNode>>();

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

  group('Can use ParamsObject', () {
    test('for complex type', () {
      _activatory.useParamsObject<Task, TaskParams>();
      var title = _activatory.getTyped<String>();

      var result = _activatory.getTyped<Task>(TaskParams(title: v(title), isTemplate: v(null)));

      expect(result, isNotNull);
      expect(result.id, isNotNull);
      expect(result.title, equals(title));
      expect(result.isRecurrent, isNotNull);
      expect(result.isTemplate, isNull);
      expect(result.dueDate, isNull);
    });

    test('for generic type', () {
      _activatory.useParamsObject<Generic<int>, GenericParams<int>>();

      var result = _activatory.getTyped<Generic<int>>(GenericParams<int>());

      expect(result, isNotNull);
      expect(result.field, isNotNull);
    });

    test('for generic type with generic array in ctor', () {
      _activatory.useParamsObject<GenericArrayInCtor<int>, GenericArrayInCtorParams<int>>();

      var result = _activatory.getTyped<GenericArrayInCtor<int>>(GenericArrayInCtorParams<int>());

      expect(result, isNotNull);
      expect(result.listField, isNotNull);
      expect(result.listField, hasLength(3));
      expect(result.listField, isNot(contains(null)));
    });
  });

  test('Can use library to create mock', () {
    var result = _activatory.getTyped<TaskMock>();
    when(result.isRecurrent).thenReturn(true);

    expect(result, isNotNull);
    expect(result.isRecurrent, isTrue);
    expect(result.isTemplate, isNull);
  });

  group('Can customize', () {
    group('backends', () {
      group('without overrides', () {
        test('take first for complex type to take first ctor', () {
          _activatory.pinValue('E');
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeFirstDefined;

          var items = List.generate(15, (_) => _activatory.getTyped<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });

        test('take random named ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeRandomNamedCtor;

          var items = List.generate(15, (_) => _activatory.getTyped<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['A', 'B', 'C', 'D'];
          expect(result, equals(expected));
        });

        test('take random for complex type to take random ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy = BackendResolutionStrategy.TakeRandom;
          _activatory.pinValue<String>('E');

          var items = List.generate(200, (_) => _activatory.getTyped<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['A', 'B', 'C', 'D', 'E'];
          expect(result, equals(expected));
        });

        test('take default ctor for type with default ctor', () {
          _activatory.customize<NamedCtorsAndDefaultCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeDefaultCtor;
          _activatory.pinValue<String>('E');

          var items = List.generate(15, (_) => _activatory.getTyped<NamedCtorsAndDefaultCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });

        test('take default for class with factory', () {
          _activatory.customize<NamedCtorsAndFactory>().resolutionStrategy = BackendResolutionStrategy.TakeDefaultCtor;
          _activatory.pinValue<String>('E');

          var items = List.generate(15, (_) => _activatory.getTyped<NamedCtorsAndFactory>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });

        test('take default for class with const ctor', () {
          _activatory.customize<NamedCtorsAndConstCtor>().resolutionStrategy =
              BackendResolutionStrategy.TakeDefaultCtor;
          _activatory.pinValue<String>('E');

          var items = List.generate(15, (_) => _activatory.getTyped<NamedCtorsAndConstCtor>());
          var result = SplayTreeSet.from(items.map((item) => item.field));

          var expected = ['E'];
          expect(result, equals(expected));
        });
      });

      group('with overrides', () {
        test('take random to take random from overrides', () {
          _activatory.pinValue(10);
          _activatory.override((ctx) => 20);
          _activatory.pinValue(30);
          _activatory.override((ctx) => 40);
          _activatory.customize<int>()
            ..arraySize = 15
            ..resolutionStrategy = BackendResolutionStrategy.TakeRandom;

          final generated = _activatory.getTyped<List<int>>();
          var result = SplayTreeSet.from(generated);

          const expected = [10, 20, 30, 40];
          expect(result, equals(expected));
        });

        test('take random to take random from overrides', () {
          _activatory.pinValue(10);
          _activatory.override((ctx) => 20);
          _activatory.pinValue(30);
          _activatory.override((ctx) => 40);
          _activatory.customize<int>()
            ..arraySize = 15
            ..resolutionStrategy = BackendResolutionStrategy.TakeFirstDefined;

          final generated = _activatory.getTyped<List<int>>();
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

      final intArray = _activatory.getTyped<List<int>>();
      final nullArray = _activatory.getTyped<List<Null>>();

      expect(intArray, hasLength(expectedIntArraySize));
      expect(nullArray, hasLength(expectedNullSize));
    });

    test('array sizes for all types', () {
      final defaultSize = 5;
      _activatory.defaultCustomization.arraySize = defaultSize;

      final intList = _activatory.getTyped<List<int>>();

      expect(intList, hasLength(defaultSize));
    });

    test('recursion limit per type', () {
      _activatory.registerArray<TreeNode>();
      var expectedArrayRecursionLimit = 5;
      var expectedRefRecursionLimit = 0;
      _activatory.customize<TreeNode>().maxRecursion = expectedArrayRecursionLimit;
      _activatory.customize<LinkedNode>().maxRecursion = expectedRefRecursionLimit;

      final tree = _activatory.getTyped<TreeNode>();
      final linkedNode = _activatory.getTyped<LinkedNode>();

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

  test('Can create map with explicit registration', () {
    _activatory.registerMap<String, int>();

    final result = _activatory.getTyped<Map<String, int>>();

    expect(result, isNotNull);
    expect(result, hasLength(_activatory.defaultCustomization.arraySize));
  });

  group('Can customize', () {
    test('argument by type with delegate', () {
      _activatory.customize<FactoryWithFixedValues>()..whenArgument<String>().than(useCallback: (ctx) => 'A');
      _activatory.registerArray<FactoryWithFixedValues>();

      final items = _activatory.getTyped<List<FactoryWithFixedValues>>();
      var result = SplayTreeSet.from(items.map((item) => item.field));

      final expected = ['A'];
      expect(result, equals(expected));
    });

    test('argument by type and name with delegate', () {
      _activatory.customize<CtorWithTwoStringArgs>()
        ..whenArgument<String>('_b').than(useCallback: (ctx) => 'B')
        ..whenArgument<String>().than(useCallback: (ctx) => 'A');

      final result = _activatory.getTyped<CtorWithTwoStringArgs>();

      expect(result.a, equals('A'));
      expect(result.b, equals('B'));
    });

    test('argument by type with pool', () {
      _activatory.customize<FactoryWithFixedValues>()
        ..arraySize = 15
        ..whenArgument<String>().than(usePool: ['A', 'B', 'C']);
      _activatory.registerArray<FactoryWithFixedValues>();

      final items = _activatory.getTyped<List<FactoryWithFixedValues>>();
      var result = SplayTreeSet.from(items.map((item) => item.field));

      final expected = ['A', 'B', 'C'];
      expect(result, equals(expected));
    });

    test('argument by type and name with pool', () {
      _activatory.customize<CtorWithTwoStringArgs>()
        ..arraySize = 15
        ..whenArgument<String>('_b').than(usePool: ['B', 'C'])
        ..whenArgument<String>().than(usePool: ['A']);
      _activatory.registerArray<CtorWithTwoStringArgs>();

      final items = _activatory.getTyped<List<CtorWithTwoStringArgs>>();
      var resultA = SplayTreeSet.from(items.map((item) => item.a));
      var resultB = SplayTreeSet.from(items.map((item) => item.b));

      expect(resultA, equals(['A']));
      expect(resultB, equals(['B', 'C']));
    });
  });

  group('Can create arrays without explicit regestration',(){
    test('with default length',(){
      var result = _activatory.getManyTyped<int>();
      expect(result, isNotNull);
      expect(result, hasLength(3));
      expect(result, isNot(contains(null)));
    });
    test('with parametrized length',(){
      var result = _activatory.getManyTyped<int>(count: 2);
      expect(result, isNotNull);
      expect(result, hasLength(2));
      expect(result, isNot(contains(null)));
    });
    test('with customized per type length',(){
      _activatory.customize<int>().arraySize = 10;
      var result = _activatory.getManyTyped<int>();
      expect(result, isNotNull);
      expect(result, hasLength(10));
      expect(result, isNot(contains(null)));
    });
    test('with customized key',(){
      var key = 'key';
      _activatory.pinValue(10, key: key);
      var result = _activatory.getManyTyped<int>(key: key);
      expect(result, isNotNull);
      expect(result, hasLength(3));
      var unique = new Set.from(result);
      expect(unique, equals([10]));
    });
  });

  group('Type aliases',(){
    test('allow iterable of primitive type activation without setup',(){
      var result = _activatory.getTyped<PrimitiveIterableInCtor>();

      expect(result, isNotNull);
      expect(result.field, isNotEmpty);
      expect(result.field, hasLength(3));
      expect(result.field, isNot(contains(null)));
    });

    test('allow iterable of complex type activation with setup',(){
      _activatory.registerArray<PrimitiveIterableInCtor>();
      var result = _activatory.getTyped<ComplexIterableInCtor>();

      expect(result, isNotNull);
      expect(result.field, isNotEmpty);
      expect(result.field, hasLength(3));
      expect(result.field, isNot(contains(null)));
    });

    test('allow use subtype activation strategy for parent type',(){
      _activatory.registerAlias<ParentClass, ChildClass>();

      var result = _activatory.getTyped<ParentClass>();

      expect(result, isNotNull);
      expect(result, TypeMatcher<ChildClass>());
    });
  });

  group('Can customize default values usage',(){
    //Positional
    //Named

    //Nulls
    //NotNulls

    // UseDefaultValue
    // ReplaceNulls
    // ReplaceAll
  });

  group("Can customize default values usage for", () {
    group("positional arguments", () {
      test("with ReplaceNulls", () {
        _activatory.customize<DefaultPositionalValues>()
          .defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceNulls;


        var result = _activatory.getTyped<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });

      test("with ReplaceAll", () {
        _activatory.customize<DefaultPositionalValues>()
            .defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceAll;

        var result = _activatory.getTyped<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, isNot(equals(DefaultPositionalValues.defaultStringValue)));
        expect(result.nullSetStringValue, isNotNull);
        assertComplexObjectIsNotNull(result.notSetObject);
        assertComplexObjectIsNotNull(result.nullSetObject);
      });

      test("with UseAll", () {
        _activatory.customize<DefaultPositionalValues>()
            .defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.UseAll;

        var result = _activatory.getTyped<DefaultPositionalValues>();

        expect(result, isNotNull);
        expect(result.notNullSetStringValue, equals(DefaultPositionalValues.defaultStringValue));
        expect(result.nullSetStringValue, isNull);
        expect(result.notSetObject, isNull);
        expect(result.nullSetObject, isNull);
      });
    });

    group("named arguments", () {
      test("with ReplaceNulls", () {
        _activatory.customize<DefaultNamedValues>()
            .defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceNulls;

        var result = _activatory.getTyped<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNotNull);
        assertComplexObjectIsNotNull(result.nullSetObject);
        assertComplexObjectIsNotNull(result.notSetObject);
      });

      test("with ReplaceAll", () {
        _activatory.customize<DefaultNamedValues>()
            .defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceAll;

        var result = _activatory.getTyped<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, isNot(equals(DefaultNamedValues.defaultValue)));
        expect(result.nullSetString, isNotNull);
        assertComplexObjectIsNotNull(result.nullSetObject);
        assertComplexObjectIsNotNull(result.notSetObject);
      });

      test("with UseAll", () {
        _activatory.customize<DefaultNamedValues>()
            .defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.UseAll;

        var result = _activatory.getTyped<DefaultNamedValues>();

        expect(result, isNotNull);
        expect(result.notNullSetString, equals(DefaultNamedValues.defaultValue));
        expect(result.nullSetString, isNull);
        expect(result.nullSetObject, isNull);
        expect(result.notSetObject, isNull);
      });
    });
  });

  test('Can customize per key',(){
    _activatory.customize<int>(key: 'A').arraySize = 10;
    _activatory.customize<int>(key: 'B').arraySize = 1;

    var resultA = _activatory.getTyped<List<int>>('A');
    var resultB = _activatory.getTyped<List<int>>('B');
    var resultC = _activatory.getTyped<List<int>>();

    expect(resultA, hasLength(10));
    expect(resultB, hasLength(1));
    expect(resultC, hasLength(3));
  });

  test('Can fill fields',(){
    var result = _activatory.getTyped<FiledsWithPublicSetters>();

    expect(result.finalField, isNotNull);
    expect(result.publicField, isNotNull);
    expect(result.publicProperty, isNull);
  });

  group('Can customize fields usage',(){
    test('FieldsAndSetters', (){
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFill = FieldsAutoFill.FieldsAndSetters;

      var result = _activatory.getTyped<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNotNull);
      expect(result.publicProperty, isNotNull);
    });

    test('fields only', (){
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFill = FieldsAutoFill.Fields;

      var result = _activatory.getTyped<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNotNull);
      expect(result.publicProperty, isNull);
    });

    test('none', (){
      _activatory.customize<FiledsWithPublicSetters>().fieldsAutoFill = FieldsAutoFill.None;

      var result = _activatory.getTyped<FiledsWithPublicSetters>();

      expect(result.finalField, isNotNull);
      expect(result.publicField, isNull);
      expect(result.publicProperty, isNull);
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
