# Activatory

[![Build Status](https://travis-ci.com/syberside/Activatory.svg?branch=master)](https://travis-ci.com/syberside/Activatory)
[![Coverage Status](https://coveralls.io/repos/github/syberside/Activatory/badge.svg)](https://coveralls.io/github/syberside/Activatory)
[![Pub](https://img.shields.io/pub/v/activatory.svg)](https://pub.dartlang.org/packages/activatory)

Test data generator for Dart ecosystem.
Simplifies unit testing and Test-Driven Development.

This project is inspired by .NET [Autofixture](https://github.com/AutoFixture/AutoFixture) library.

## Overview
When we are writing tests we need some way to create random data. It starts from using Random class to receive some int/double/bool and continues to handwritten helper methods with big amount of parameters to create complex object graphs. Helpers become more complex and require more maintenance while time passing. This makes them not flexible, inferrable and annoying.

Activatory allow you to use ready-from-the-box class which can do the same as handwritten boilerplate code and don't waste your time writing them. Keep in mind: **less code in tests is less code to maintain and understand**

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
 * with generic class argument,
 * with regular Type object method parameter.
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
Most of activation behaviors can be customized

### Replacing underlying factories for types

#### With user defined function
Sometimes one this situations can occur:
- creating of instance has some logic behind (e.g. filling with special values),
- type is not supported by activatory directly right now.
In this situation default factories can be replaced with explicit user defined function call by `useFunction` method.
```dart
// Overriding with explicit function call.
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
If test data requires multiple instances of one class with the same value `useSingleton` method can be used to use single value for all activations of given type.
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
final contactsCount = report.map((r)=>r.contact).toSet().length; // 1
final reportItemsCount = report.map((r)=>r.itemName).toSet().length; // 3
```
In this example activatory will create 3 instances of ReportItem, each will receive different values for `itemName` but all thee instances will share `ContactInfo` instance.

#### With activatory created random value
If test requires to use same value for all type instances but there is no need to create it by hand `useGeneratedSingleton` method can be used.

Let's rewrite sample below. In this code snipped we don't depend on contact id and name values, so thay can be created without user defined code.
```dart
activatory.useGeneratedSingleton<ContactInfo>();
final List<ReportItem> report = activatory.getMany<ReportItem>();
final contactsCount = report.map((r)=>r.contact).toSet().length; // 1
final reportItemsCount = report.map((r)=>r.itemName).toSet().length; // 3
```
### Changing factory resolving strategy
By default activatory takes first defined factory for class. This means that first founded by reflection public constructor will be used if no overrides was provided. If any overrides was provided latest one will be used.
 
```dart
activatory.customize<MyClass>().resolvingStrategy = FactoryResolvingStrategy.TakeRandomNamedCtor;
```
Available strategies are:
 - select first defined factory (default), 
 - take random factory,
 - take random named constructor,
 - take default constructor.
 
 ### Changing default values usage
 ```dart
activatory.customize<MyClass>().defaultValuesHandlingStrategy = DefaultValuesHandlingStrategy.ReplaceAll;
 ```
Available strategies are:
 - ignore all default values;
 - use not null default values (default);
 - always use default values.
### Changing public fields and setters filling
 ```dart
activatory.customize<MyClass>().fieldsAutoFillingStrategy =  FieldsAutoFillingStrategy.FieldsAndSetters;
 ```
Available strategies are:
- ignore;
- fill with random data fields only (default);
- fill with random data fields and setters.
### Changing Array size
Default used array size is 3.
 ```dart
activatory.customize<MyClass>().arraySize = 100500;
final length = activatory.getMany<MyClass>().length; //100500
final length = activatory.get<List<MyClass>>().length; //100500
 ```
Please note that any activation of multiple instances of `MyClass` will respect this configuration.
### Replacing subclass with superclass
Suppose we need have a class that expect abstract class as constructor parameter.
```dart
abstract class User {}
class ReportItem{ User user;}
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
- on global level all types, using `activatory.defaultTypeCustomization`;
- on type level, using `activatory.customize<T>()`;
- on specific scope level by passing key argument  which can be instance of any type `activatory.customize<T>(key: 'some key')`. Key should be the same for all setup and activation calls to share setup.
Factories can't be overridden on global level, only type and scope levels are supported.

## Helpers
Activatory allows to simplify test code by providing useful helpers.
- selecting one or more random items from array
```dart
final fromOneToFive = activatory.take([1, 2, 3, 4, 5]);
final threeItemsFromOneToFive = activatory.takeMany(3, [1, 2, 4, 5]);
```
- creating list of Objects of given type.
```dart
final List<int> intArray = activatory.getMany<int>();
```

## Samples
For up-to-date list of samples see [example folder on project GitHub](https://github.com/syberside/Activatory/tree/master/example) or [example section on pub package page](https://pub.dev/packages/activatory#-example-tab-).

## Supported platforms
Current implementation depends on reflection ([Mirrors package](https://api.dart.dev/stable/2.7.1/dart-mirrors/dart-mirrors-library.html)). So, **Activatory supports only VM platform for now**.
 
 If you have package depending on other platform (e.g. Flutter or Dart Web) you should move testing required business logic to separate platform independent package to be able to use Activatory in tests. Platform independent package of Activatory will be implemented in the future, but it will require much more setup from user (due to Mirrors unavailability). Also, keep in mind, that moving business logic to separate package is almost always a good decision.

## Further improvements
For planned features and more see [enhancements on github](https://github.com/syberside/Activatory/issues?utf8=%E2%9C%93&q=is%3Aenhancement+is%3Aopen+). 
