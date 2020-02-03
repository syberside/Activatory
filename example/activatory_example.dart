import 'package:activatory/activatory.dart';
// ignore_for_file: omit_local_variable_types

void main() {
  final activatory = new Activatory();

  // Activatory can create primitive types instances. No pre-configuration required.
  final int randomInt = activatory.get<int>();
  assert(randomInt != null);
  final String randomString = activatory.get<String>();
  assert(randomString != null);
  final DateTime randomDateTime = activatory.get<DateTime>();
  assert(randomDateTime != null);
  final bool randomBool = activatory.get<bool>();
  assert(randomBool != null);
  final MyEnum randomEnumValue = activatory.get<MyEnum>();
  assert(randomEnumValue != null);

  // Activatory can create custom types instances. No pre-configuration required.
  final MyClass randomMyClass = activatory.get<MyClass>();
  // Fields with public setters are automatically filled with random data.
  assert(randomMyClass.intFieldWithPublicSetter != null);
  // Constructor parameters are automatically filled with random data.
  assert(randomMyClass.finalStringFieldFilledWithCtor != null);

  // Activatory can create complex graph of objects. No pre-configuration required.
  final ComplexGraphClass myComplexGraphClass = activatory.get<ComplexGraphClass>();
  // Activatory supply random data to constructor parameters and public setters.
  assert(myComplexGraphClass.dateTimeFieldWithPublicSetter != null);
  // If constructor parameter or setter is user defined class it will be created in the same way.
  assert(myComplexGraphClass.myClassFieldWithPublicSetter.intFieldWithPublicSetter != null);

  // Recursive graphs are also supported.
  final LinkedNode<int> myLinkedList = activatory.get<LinkedNode<int>>();
  assert(myLinkedList.next.next.value != null); // Default recursion limit is 3.

  // Activatory can create multiple objects at one call.
  final List<int> intArray = activatory.getMany<int>();
  assert(intArray.length == 3); //default array length is 3

  // List, iterables and map parameters or fields are also supported.
  final MyClassWithArrayIterableAndMapParameters collectionsSample =
      activatory.get<MyClassWithArrayIterableAndMapParameters>();
  assert(collectionsSample.intArray.length == 3); //default array length is 3
  assert(collectionsSample.intIterable.length == 3); //default iterable length is 3
  assert(collectionsSample.intToStringMap.length == 3); //default map length is 3

  // Generics are also supported. No pre-configuration required.
  final MyGenericClass<MyGenericClass<int>> genericClassInstance =
      activatory.get<MyGenericClass<MyGenericClass<int>>>();
  assert(genericClassInstance.value != null);

  // Activatory support all constructor types:
  // 1. Default constructor
  final MyClassWithDefaultConstructor myClassWithDefaultConstructor = activatory.get<MyClassWithDefaultConstructor>();
  assert(myClassWithDefaultConstructor.someData != null);
  // 2. Named constructor
  final MyClassWithNamedConstructor myClassWithNamedConstructor = activatory.get<MyClassWithNamedConstructor>();
  assert(myClassWithNamedConstructor.someData != null);
  // 3. Factory constructors
  final MyClassWithFactoryConstructor myClassWithFactoryConstructor = activatory.get<MyClassWithFactoryConstructor>();
  assert(myClassWithFactoryConstructor.someData != null);

  // Default parameter values are used while they are not nulls. But this behavior can be customized (see below).
  // 1. Named parameters
  final MyClassWithNamedParameter withNamedParameters = activatory.get<MyClassWithNamedParameter>();
  assert(withNamedParameters.namedArgumentWithDefaultValue == MyClassWithNamedParameter.namedArgumentDefaultValue);
  assert(withNamedParameters.namedArgumentWithoutDefaultValue != null);
  // 2. Position parameters
  final MyClassWithPositionalParameters withPositionParameters = activatory.get<MyClassWithPositionalParameters>();
  assert(withPositionParameters.positionalArgumentWithDefaultValue ==
      MyClassWithPositionalParameters.positionalArgumentDefaultValue);
  assert(withPositionParameters.positionalArgumentWithoutDefaultValue != null);

  // Default object creation strategy can be customized.
  // 1. With explicit function to completely control object creation
  activatory.useFunction((ActivationContext ctx) => 42); // Imagine some logic behind 42 receiving, e.g. custom code.
  int goodNumber = activatory.get<int>();
  assert(goodNumber == 42);
  // Function accept activation context that can be used in complex scenarios to activate other types, read settings and etc.
  activatory.useFunction((ActivationContext ctx) => 'This string contains 34 characters');
  activatory.useFunction((ActivationContext ctx) => ctx.create<String>().length);
  final int thirtyFour = activatory.get<int>();
  assert(thirtyFour == 34);
  // 2.1. With singleton value generated automatically
  activatory.useGeneratedSingleton<int>();
  final int randomSingletonInt = activatory.get<int>();
  assert(randomSingletonInt != null);
  // 2.2. With singleton value defined by user
  activatory.useSingleton(42);
  goodNumber = activatory.get<int>();
  assert(goodNumber == 42);

  // In some cases you may require different strategies for different activation calls.
  // This can be accomplished with using key parameter of customization/activation methods.
  activatory.useSingleton(42, key: 'good number');
  activatory.useSingleton(13, key: 'not good number');
  activatory.useFunction((ctx) => ctx.create<int>().toString());
  final String goodNumberStr = activatory.get<String>('good number');
  assert(goodNumberStr == '42');
  final String notGoodNumberStr = activatory.get<String>('not good number');
  assert(notGoodNumberStr == '13');
  // Key can be any type of object. It's value can be accessed through ActivationContext if required.
  final DateTime now = DateTime.now();
  activatory.useFunction((ctx) => ctx.key as DateTime, key: now);
  final DateTime today = activatory.get<DateTime>(now);
  assert(today == now);

  // Super classes can be replaced with subtypes.
  activatory.replaceSupperClass<AbstractClass, AbstractClassInheritor>();
  final notSoAbstractInstance = activatory.get<AbstractClass>();
  assert(notSoAbstractInstance.runtimeType == AbstractClassInheritor);

  // Activation behavior can be customized for all types or per type.
  final TypeCustomization defaultCustomization = activatory.defaultCustomization;
  defaultCustomization
    ..arraySize = 100500
    ..defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceAll
    ..fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.FieldsAndSetters
    ..maxRecursionLevel = 10
    ..resolvingStrategy = FactoryResolvingStrategy.TakeRandomNamedCtor;

  // Activatory contains helpful methods
  // To take random item(s) from array
  final fromOneToFive = activatory.take([1, 2, 3, 4, 5]);
  assert(fromOneToFive >= 1 && fromOneToFive <= 5);
  final threeItemsFromOneToFive = activatory.takeMany(3, [1, 2, 4, 5]);
  assert(threeItemsFromOneToFive.length == 3);

  //See activatory_test.dart for more examples
}

class ComplexGraphClass {
  final DateTime dateTimeFieldWithPublicSetter;
  MyClass myClassFieldWithPublicSetter;

  ComplexGraphClass(this.dateTimeFieldWithPublicSetter, this.myClassFieldWithPublicSetter);
}

class MyClass {
  final String finalStringFieldFilledWithCtor;

  int intFieldWithPublicSetter;

  MyClass(this.finalStringFieldFilledWithCtor);
}

class MyClassWithDefaultConstructor {
  final DateTime someData;

  MyClassWithDefaultConstructor(this.someData);
}

class MyClassWithNamedConstructor {
  final DateTime someData;

  MyClassWithNamedConstructor(this.someData);
}

class MyClassWithFactoryConstructor {
  final DateTime someData;

  MyClassWithFactoryConstructor(this.someData);
}

class MyClassWithPositionalParameters {
  static const positionalArgumentDefaultValue = 'Hello positional';
  final String positionalArgumentWithDefaultValue;
  final String positionalArgumentWithoutDefaultValue;

  MyClassWithPositionalParameters(
    this.positionalArgumentWithoutDefaultValue, [
    this.positionalArgumentWithDefaultValue = positionalArgumentDefaultValue,
  ]);
}

class MyClassWithNamedParameter {
  static const namedArgumentDefaultValue = 'Hello named';
  final String namedArgumentWithDefaultValue;
  final String namedArgumentWithoutDefaultValue;

  MyClassWithNamedParameter(
    this.namedArgumentWithoutDefaultValue, {
    this.namedArgumentWithDefaultValue = namedArgumentDefaultValue,
  });
}

class MyClassWithArrayIterableAndMapParameters {
  final List<int> intArray;
  final Iterable<int> intIterable;
  final Map<int, String> intToStringMap;

  MyClassWithArrayIterableAndMapParameters(this.intArray, this.intIterable, this.intToStringMap);
}

class MyGenericClass<T> {
  final T value;

  MyGenericClass(this.value);
}

enum MyEnum { A, B, C }

class LinkedNode<T> {
  final T value;
  final LinkedNode<T> next;

  LinkedNode(this.value, this.next);
}

abstract class AbstractClass {}

class AbstractClassInheritor extends AbstractClass {}
