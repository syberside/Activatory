import 'package:activatory/activatory.dart';
import 'package:activatory/params_object.dart';
import 'package:activatory/src/activatory.dart';
import 'package:activatory/src/customization/backend_resolution_strategy.dart';
import 'package:activatory/src/customization/default_values_handling_strategy.dart';
import 'package:activatory/src/customization/type_customization.dart';

main() {
  var activatory = new Activatory();

  // Activatory can create primitive types instances. No pre-configuration required.
  int randomInt = activatory.get<int>();
  assert(randomInt != null);
  String randomString = activatory.get<String>();
  assert(randomString != null);
  DateTime randomDateTime = activatory.get<DateTime>();
  assert(randomDateTime != null);
  bool randomBool = activatory.get<bool>();
  assert(randomBool != null);
  MyEnum randomEnumValue = activatory.get<MyEnum>();
  assert(randomEnumValue != null);

  // Activatory can create custom types instances. No pre-configuration required.
  var randomMyClass = activatory.get<MyClass>();
  // Fields with public setters are automatically filled with random data.
  assert(randomMyClass.intFieldWithPublicSetter != null);
  // Constructor parameters are automatically filled with random data.
  assert(randomMyClass.finalStringFieldFilledWithCtor != null);

  // Activatory can create complex graph of objects. No pre-configuration required.
  var myComplexGraphClass = activatory.get<ComplexGraphClass>();
  // Activatory automatically supply random data to constructor parameters and public setters.
  assert(myComplexGraphClass.dateTimeFieldWithPublicSetter != null);
  // If constructor parameter or getter type is custom class it will be created in same way.
  assert(myComplexGraphClass.myClassFieldWithPublicSetter.intFieldWithPublicSetter != null);

  // Recursive graphs are also handled.
  final myLinkedList = activatory.get<LinkedNode<int>>();
  assert(myLinkedList.next.next.next.value != null); // Default recursion limit is 3.

  // Activatory can create multiple objects at one call.
  var intArray = activatory.getManyTyped<int>();
  assert(intArray.length == 3); //default array length is 3

  // List, iterables and map parameters or fields are also supported.
  var explicitRegistrationSample = activatory.get<MyClassWithArrayIterableAndMapParameters>();
  assert(explicitRegistrationSample.intArray.length == 3); //default array length is 3
  assert(explicitRegistrationSample.intIterable.length == 3); //default iterable length is 3
  assert(explicitRegistrationSample.intToStringMap.length == 3); //default map length is 3

  // Generics are also supported but requires explicit registration too.
  //activatory.useFunction((ctx) => new MyGenericClass<int>(ctx.createTyped<int>(ctx)));
  var genericClassInstance = activatory.get<MyGenericClass<MyGenericClass<int>>>();
  assert(genericClassInstance.value != null);

  // Activatory support all constructor types:
  // 1. Default constructor
  var myClassWithDefaultConstructor = activatory.get<MyClassWithDefaultConstructor>();
  assert(myClassWithDefaultConstructor.someData != null);
  // 2. Named constructor
  var myClassWithNamedConstructor = activatory.get<MyClassWithNamedConstructor>();
  assert(myClassWithNamedConstructor.someData != null);
  // 3. Factory constructors
  var myClassWithFactoryConstructor = activatory.get<MyClassWithFactoryConstructor>();
  assert(myClassWithFactoryConstructor.someData != null);

  // Default parameters are used while they are not nulls:
  // 1. For named parameters
  var withNamedParameters = activatory.get<MyClassWithNamedParameter>();
  assert(withNamedParameters.namedArgumentWithDefaultValue == MyClassWithNamedParameter.namedArgumentDefaultValue);
  assert(withNamedParameters.namedArgumentWithoutDefaultValue != null);
  // 2. For position parameters
  var withPositionParameters = activatory.get<MyClassWithPositionalParameters>();
  assert(withPositionParameters.positionalArgumentWithDefaultValue ==
      MyClassWithPositionalParameters.positionalArgumentDefaultValue);
  assert(withPositionParameters.positionalArgumentWithoutDefaultValue != null);

  // Default object creation strategy can be customized.
  // 1. With explicit function to completely control object creation
  activatory.useFunction((ActivationContext ctx) => 42); // Imagine some logic behind 42 receiving, e.g. custom code.
  var goodNumber = activatory.get<int>();
  assert(goodNumber == 42);
  // Function accept activation context that can be used in complex scenarios to activate other types, read settings and etc.
  activatory.useFunction((ActivationContext ctx) => 'This string contains 34 characters');
  activatory.useFunction((ActivationContext ctx) => ctx.createTyped<String>(ctx).length);
  var thirtyFour = activatory.get<int>();
  assert(thirtyFour == 34);
  // 2.1. With singleton value generated automatically
  activatory.useGeneratedSingleton<int>();
  randomInt = activatory.get<int>();
  assert(randomInt != null);
  // 2.2. With singleton value defined by user
  activatory.useSingleton(42);
  goodNumber = activatory.get<int>();
  assert(goodNumber == 42);

  // In some cases you may require different strategies for different activation calls.
  // This can be accomplished with using key parameter of customization/activation methods.
  activatory.useSingleton(42, key: 'good number');
  activatory.useSingleton(10, key: 'not good number');
  //TODO: should works without key specification
  activatory.useFunction((ctx) => ctx.createTyped<int>(ctx).toString(), key: 'good number');
  activatory.useFunction((ctx) => ctx.createTyped<int>(ctx).toString(), key: 'not good number');
  var goodNumberStr = activatory.get<String>('good number');
  assert(goodNumberStr == '42');
  var notGoodNumberStr = activatory.get<String>('not good number');
  assert(notGoodNumberStr == '10');
  // Key can be any type of object. It's value can be accessed through ActivationContext if required.
  var now = DateTime.now();
  activatory.useFunction((ctx) => ctx.key as DateTime, key: now);
  var today = activatory.get<DateTime>(now);
  assert(today == now);

  // [Params] can be used as a key to activate object using passed from test arguments.
  // See [params_example.dart] for more complex example.
  final task = activatory.get<Task>(new TaskParams(type: Value('specific value')));
  assert(task.title == 'random =)');
  assert(task.id == null);
  assert(task.type == 'specific value');

  // Activation behavior can be customized for all types or per type.
  TypeCustomization defaultCustomization = activatory.defaultCustomization;
  defaultCustomization
    ..arraySize = 100500
    ..defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceAll
    ..fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.FieldsAndSetters
    ..maxRecursionLevel = 10
    ..resolutionStrategy = BackendResolutionStrategy.TakeRandomNamedCtor;
  // TypeCustomization allows to bind some configuration directly to argument by name. It can be unsafe because arguments can be renamed.
  TypeCustomization typeCustomization = activatory.customize<MyClass>();
  typeCustomization
    ..whenArgument('finalStringFieldFilledWithCtor').than(usePool: [DateTime.now()])
    ..whenArgument('intFieldWithPublicSetter').than(useCallback: (ctx) => 10);

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

class Task {
  final int id;
  final String title;
  final String type;
  final String a1;
  final String a2;
  final String a3;
  final String a4;

  Task(this.id, this.title, this.type, this.a1, this.a2, this.a3, this.a4);
}

class TaskParams extends Params<Task> {
  Value<int> _id;
  Value<String> _title;
  Value<String> _type;

  TaskParams({
    Value<int> id = const NullValue(),
    Value<String> title = const Value('random =)'),
    Value<String> type,
  }) {
    _id = id;
    _title = title;
    _type = type;
  }

  @override
  Task resolve(ActivationContext ctx) {
    return new Task(
      get(_id, ctx),
      get(_title, ctx),
      get(_type, ctx),
      ctx.createTyped<String>(ctx),
      ctx.createTyped<String>(ctx),
      ctx.createTyped<String>(ctx),
      ctx.createTyped<String>(ctx),
    );
  }
}
