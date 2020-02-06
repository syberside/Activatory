# Activatory

[![Build Status](https://travis-ci.com/syberside/Activatory.svg?branch=master)](https://travis-ci.com/syberside/Activatory)
[![Coverage Status](https://coveralls.io/repos/github/syberside/Activatory/badge.svg)](https://coveralls.io/github/syberside/Activatory)
[![Pub](https://img.shields.io/pub/v/activatory.svg)](https://pub.dartlang.org/packages/activatory)

Test data generator for Dart ecosystem.
Simplifies unit testing and Test-Driven Development.

This project is inspired by .NET [Autofixture](https://github.com/AutoFixture/AutoFixture) library.

## Overview
While writing tests developers need some way to create random data. It starts from using `Random` class to receive some `int`/`double`/`bool` and continues to handwritten helper methods with a big amount of optional parameters to create complex object graphs. Helpers become more complex and require more maintenance while time passing. This makes them not flexible, but inferrable and annoying.

Activatory allows you to use ready-from-the-box class which can do the same as handwritten boilerplate code and don't waste your time on writing them. Keep in mind: **less code in tests is less code to maintain and understand**.

### Basic usage
To create activatory instance just call a constructor
```dart
import 'package:activatory/activatory.dart';
final activatory = new Activatory();
```

After it you can create almost every type of objects using activatory instance
```dart
final int randomInt = activatory.get<int>();
final AlmostAnyClass instance = activatory.get<AlmostAnyClass>();
```

### Supported types
Activatory can be used to create:
- random values of primitive types (String, int, double, bool, DateTime, enums, Null);
- random values of complex types using all [Dart constructor](https://dart.dev/guides/language/language-tour#constructors) types;
- List, Iterables and Maps;
- random values of recursive types (trees, linked lists and etc);
- random values of generic classes;
- any not listed above type with a bit setup code.

Any constructor arguments and public fields/setter values will be created, filled with random data and passed automatically.

### Typed VS untyped API
Activatory support both styles of passing type parameters:
 * with a generic class argument,
 * with a regular `Type` object method parameter.
In general, **typed API is preferable** because of generic code robustness and readability.

Suppose to use
```dart
final AlmostAnyClass instance = activatory.get<AlmostAnyClass>();
``` 
instead of
```dart
final AlmostAnyClass instance = activatory.getUntyped(AlmostAnyClass) as AlmostAnyClass;
``` 
Untyped API can be helpful in case when class type itself is resolved at runtime (for instance, it could be taken from array of types in foreach loop).

## Customization
Activation behaviors can be customized in different ways.

### Replacing underlying factories per type

#### With user defined function
One of the following situations can occur:
- creating of instance has some logic behind (e.g. filling with special values),
- type is not supported by activatory directly right now.

In this situation default factories can be replaced with explicit user defined function call by `useFunction` method.
```dart
activatory.useFunction((ActivationContext ctx) => 42); // Imagine some logic behind 42 receiving, e.g. custom code.
final int goodNumber = activatory.get<int>(); // 42
```
The `ActivationContext` is object that allows you to create any type instance inside callback.
```dart
activatory
  ..useFunction((ActivationContext ctx) => 42);
  ..useFunction((ActivationContext ctx) => ctx.get<int>().toString());
final int goodNumber = activatory.get<String>(); // "42"
```

#### With user defined value
If test scenario requires multiple instances of one class with the same value `useSingleton` method can be used to pin single value for all activations of given type.
```dart
activatory.useSingleton(42);
final int fourtyTwo1 = activatory.get<int>(); // 42
final int fourtyTwo2 = activatory.get<int>(); // 42
```
This can be helpful if you test object graph contains repeating data, e.g. customer name, object ids, contacts and so on.

Suppose we are testing some single user scenario:
```dart
class ContactInfo { int id; String name;}
class ReportItem { ContactInfo contact; int amount; String itemName;}
...
final contact = new ContactInfo()
  ..id = 10 // or activatory.get<int>()
  ..name = 'Joe'; // or activatory.get<String>()
activatory.useSingleton(contact);
final List<ReportItem> report = activatory.getMany<ReportItem>();
final contactsCount = report.map((r) => r.contact).toSet().length; // 1
final reportItemsCount = report.map((r) => r.itemName).toSet().length; // 3
```
In this example activatory will create 3 instances of `ReportItem` each of which will receive different values for `itemName`. But all 3 instances will share one `ContactInfo` instance.

#### With activatory created random value
If a test scenario requires the same value for all type instances but there is no need to create it by hand `useGeneratedSingleton` method can be used.

Let's rewrite sample below. In this code snipped we don't depend on contact id and name values, so them could be created without user defined code.
```dart
activatory.useGeneratedSingleton<ContactInfo>();
final List<ReportItem> report = activatory.getMany<ReportItem>();
final contactsCount = report.map((r) => r.contact).toSet().length; // 1
final reportItemsCount = report.map((r) => r.itemName).toSet().length; // 3
```
Existing configuration will be used while creating random value. Value is created during `useGeneratedSingleton` call, so any following configuration will not affect it.

### Changing factory resolving strategy
By default activatory takes first defined factory for class. This means first founded by reflection public constructor will be used if no override was provided. If any override was provided latest one will be used.
 
```dart
activatory.customize<MyClass>().resolvingStrategy = FactoryResolvingStrategy.TakeRandomNamedCtor;
```

Available strategies are:
 - `TakeFirstDefined` (default one), 
 - `TakeRandomNamedCtor`,
 - `TakeRandom`,
 - `TakeDefaultCtor`.

In this section `SomeClassWithConstructors` class will be used as an example. Here is a definition.
```dart
class SomeClassWithConstructors {
  final String value;

  SomeClassWithConstructors.named1() : this('named1');

  SomeClassWithConstructors(this.value);

  SomeClassWithConstructors.named2() : this('named2');
}
```

#### Using `TakeFirstDefined` strategy
TakeFirstDefined is the default strategy. This strategy will take the first available factory.
If no overrides were provided will be used one of next:
 - random value factory for primitive types;
 - random value factory enums;
 - fist defined constructor for complex type.

Example:
```dart
_activatory.customize<SomeClassWithConstructors>().resolvingStrategy = FactoryResolvingStrategy.TakeFirstDefined; // This line actually can be skipped
final firstDefinedCtorCallCount = _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'named1').length; // 100
```
In this example `firstDefinedCtorCallCount` will be equals 100 because first defined constructor (named as `named1`) is used. This could looks strange, but it's common pattern to place more generic constructor first. Dart ecosystem even have a [linter rule](https://dart-lang.github.io/linter/lints/sort_unnamed_constructors_first.html) for constructor order validation. So usually first defined is more applicable to simulate random input.

If you override factory with any other latest one override will be used:
```dart
_activatory.useFunction((ctx) => new SomeClassWithConstructors('hello'));
final latestOverrideCallCount = _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'hello').length; // 100
```
This behavior is used to match expected behavior on override call. So `latestOverrideCallCount` will be equals 100.

#### Using `TakeRandomNamedCtor` strategy
This strategy takes random named ctor for complex type. If type doesn't have public named constructor or type is not complex `ActivationException` will be thrown.
```dart
_activatory.customize<SomeClassWithConstructors>().resolvingStrategy = FactoryResolvingStrategy.TakeRandomNamedCtor;

final items = _activatory.getMany<SomeClassWithConstructors>(count: 100);
final firstNamedCtorCallsCount = items.where((x) => x.value == 'named1').length; // ~50
final secondNamedCtorCallsCount = items.where((x) => x.value == 'named2').length; // ~50
final totalCtorCallsCount = firstNamedCtorCallsCount + secondNamedCtorCallsCount; // 100
```

If you override factory with any other latest one override will be used:
```dart
_activatory.useFunction((ctx) => new SomeClassWithConstructors('hello'));
final overrideUsedCount = _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'hello').length; // 100
```
 
 #### Using `TakeRandom` strategy
 This strategy will take a random available factory.
 
 If no overrides are provided will be used:
 - random value factory for primitive types;
 - random value factory enums;
 - random ctor for complex type.
 
 ```dart
_activatory.customize<SomeClassWithConstructors>().resolvingStrategy = FactoryResolvingStrategy.TakeRandom;

final items = _activatory.getMany<SomeClassWithConstructors>(count: 100);
final firstNamedCtorCallsCount = items.where((x) => x.value == 'named1').length; // ~33
final secondNamedCtorCallsCount = items.where((x) => x.value == 'named2').length; // ~33
final defaultCtorCallsCount = items.where((x) => !x.value.startsWith('named')).length; // ~33
final totalCtorCallCount = firstNamedCtorCallsCount + secondNamedCtorCallsCount + defaultCtorCallsCount; // 100
```

If overrides were provided random one will be chosen from overrides.
```dart
_activatory.useFunction((ctx) => new SomeClassWithConstructors('hello'));
final items2 = _activatory.getMany<SomeClassWithConstructors>(count: 100);
final overrideUsedCount = items2.where((x) => x.value == 'hello').length; // ~25
final firstNamedCtorCallsCount2 = items2.where((x) => x.value == 'named1').length; // ~25
final secondNamedCtorCallsCount2 = items2.where((x) => x.value == 'named2').length; // ~25
final defaultCtorCallsCount2 = items2.where((x) => x.value != 'hello' && !x.value.startsWith('named')).length; // ~25
final totalOverrideCallsCount = overrideUsedCount + firstNamedCtorCallsCount2 + secondNamedCtorCallsCount2 + defaultCtorCallsCount2; // 100
```
 #### Using `TakeDefaultCtor` strategy
Take default ctor for complex type. Default ctor is the one called during evaluating `new T()` expression. This can be factory, const or usual ctor. If type doesn't have public default ctor or type is not complex [ActivationException] will be thrown.
 
 ```dart
_activatory.customize<SomeClassWithConstructors>().resolvingStrategy = FactoryResolvingStrategy.TakeDefaultCtor;

final items = _activatory.getMany<SomeClassWithConstructors>(count: 100);
final defaultCtorCallsCount = items.where((x) => !x.value.startsWith('named')).length; // 100
```

If overrides were provided they will be ignored.
```dart
_activatory.useFunction((ctx) => new SomeClassWithConstructors('hello'));
final overrideUsedCount = _activatory.getMany<SomeClassWithConstructors>(count: 100).where((x) => x.value == 'hello').length; // 0
```
 
 ### Changing default values usage
 ```dart
activatory.customize<MyClass>().defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceAll;
 ```
Available strategies are:
 - `ReplaceNulls`. Default values will be used while they not equals `null`.
 - `ReplaceAll`. Value will be created and passed regardless default value. 
 - `UseAll`. Default value will be used regardless it value.
 
### Changing public fields and setters filling
 ```dart
activatory.customize<MyClass>().fieldsAutoFillingStrategy = FieldsAutoFillingStrategy.FieldsAndSetters;
 ```
Available strategies are:
- `Fields` (default). Public fields will be filled with random data;
- `None`. Public fields and setters will be not filled;
- `FieldsAndSetters`. Public fields and setters will be filled with random data.

### Changing Array size
The default used array size is 3.

 ```dart
final length1 = activatory.getMany<MyClass>().length; // 3
final length2 = activatory.get<List<MyClass>>().length; // 3
activatory.customize<MyClass>().arraySize = 100500;
final length3 = activatory.getMany<MyClass>().length; // 100500
final length4 = activatory.get<List<MyClass>>().length; // 100500
 ```
Please note that any activation of multiple instances of `MyClass` will respect this configuration.

### Replacing subclass with superclass
Suppose we need have a class that expect abstract class as constructor parameter.
```dart
abstract class User {}
class ReportItem { User user;}
```
In this case we can create subclass of `User` and register it as substitution in activatory.
```dart
class VipUser extends User {}
...
activatory.replaceSupperClass<User, VipUser>();
final userType = activatory.get<ReportItem>().user.runtimeType; // VipUser
```

### Customization levels
Customization can be defined on multiple levels:
- on global level for all types, using `activatory.defaultTypeCustomization`;
- on type level, using `activatory.customize<T>()`;
- on specific scope level by passing `key` argument  (which can be an instance of any type) by calling `activatory.customize<T>(key: 'some key')`. `Key` should be the same for all setup and activation calls to share setup.

Factories can't be overridden on a global level, only type and scope levels are supported.

## Helpers
Activatory allows to simplify test code by providing useful helpers.
- selecting one or more random items from array
```dart
final fromOneToFive = activatory.take([1, 2, 3, 4, 5]);
final threeItemsFromOneToFive = activatory.takeMany(3, [1, 2, 4, 5]);
```
- creating list of Objects of given type
```dart
final List<int> intArray = activatory.getMany<int>();
```

## Samples
For up-to-date list of samples see [example folder on project GitHub](https://github.com/syberside/Activatory/tree/master/example) or [example section on pub package page](https://pub.dev/packages/activatory#-example-tab-).

## Supported platforms
Current implementation depends on reflection ([Mirrors package](https://api.dart.dev/stable/2.7.1/dart-mirrors/dart-mirrors-library.html)). So, **Activatory supports only VM platform for now**.
 
 If you have a package depending on other platforms (e.g. Flutter or Dart Web) you should move testing required business logic to separate platform-independent package to be able to use Activatory in tests. Platform independent package of Activatory will be implemented in the future, but it will require much more setup from a user (due to Mirrors unavailability). Also, keep in mind, that moving business logic to a separate package is almost always a good decision.

## Further improvements
For planned features and more see [enhancements on github](https://github.com/syberside/Activatory/issues?utf8=%E2%9C%93&q=is%3Aenhancement+is%3Aopen+). 
