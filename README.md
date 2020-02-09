# Activatory

[![Build Status](https://travis-ci.com/syberside/Activatory.svg?branch=master)](https://travis-ci.com/syberside/Activatory)
[![Coverage Status](https://coveralls.io/repos/github/syberside/Activatory/badge.svg)](https://coveralls.io/github/syberside/Activatory)
[![Pub](https://img.shields.io/pub/v/activatory.svg)](https://pub.dartlang.org/packages/activatory)

Test data generator for Dart ecosystem.
Simplifies unit testing and Test-Driven Development.

This project is inspired by .NET [Autofixture](https://github.com/AutoFixture/AutoFixture) library.

## Overview
While writing tests developers need some way to create random data. It starts from using `Random` class to receive some `int`/`double`/`bool` and continues to handwritten helper methods with a big amount of optional parameters to create complex object graphs. Helpers become more complex and require more maintenance while time passing. This makes them not flexible, but inferrable and annoying. 

Activatory allows you to use ready-from-the-box class which can do the same as handwritten boilerplate code and don't waste your time on writing them.

Tests with activatory are:
* more readable because requires less boilerplate code;
* more sustainable to changes because all required objects in test data graph are created and wired automatically;
* more maintainable because all relevant logic is placed in test. No more complex helpers common for all tests;
* more flexible because activatory contains features that are hard to implement in handwritten helpers. 
 
For more information please see "[Why activatory does matter](#why-activatory-does-matter)" section below.


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

## Why activatory does matter
Suppose we are writing unit test for following sample classes
```dart
class UserDto {
  String name;
  int id;
  bool isActive;
  DateTime birthDate;
}

class UserId {
  final int value;

  UserId(this.value);
}

class UserViewModel {
  final String name;
  final UserId id;
  final DateTime birthDate;

  UserViewModel(this.name, this.id, this.birthDate);
}

abstract class UsersAPI {
  Future<List<UserDto>> getAll();
}

class UsersManager {
  final UsersAPI _api;

  UsersManager(this._api);

  Future<List<UserViewModel>> getActiveUsers() async {
    final allItems = await _api.getAll();
    return allItems.where((x) => x.isActive).map(_convert).toList(growable: false);
  }

  UserViewModel _convert(UserDto x) => new UserViewModel(x.name, new UserId(x.id), x.birthDate);

  Future<UserViewModel> getById(UserId id) async {
    final allItems = await _api.getAll();
    final userDto = allItems.firstWhere((x) => x.id == id.value);
    return _convert(userDto);
  }
}

class _UsersAPIMock extends Mock implements UsersAPI {}

bool _isViewModelMatchUserDto(UserViewModel x, UserDto user) =>
    x.id.value == user.id && x.name == user.name && x.birthDate == user.birthDate;
```
`UserAPI` class implementation is skipped for brevity. Its contract includes one method returning all available `UserDto`'s. `UserManager` is responsible for providing `UserViewModel` to views.

`_UsersAPIMock` is mock class created with [mockito](https://pub.dev/packages/mockito) library.

`_isViewModelMatchUserDto` is a helper for asserts, defined to brief samples.

Lets now write unit tests for `UserManager`: one for`getById` method, another one for `getAll` method.

### Attempt 1: using Random class inside test
```dart
group('Attempt #1: using Random class inside test', () {
    Random _random;
    _UsersAPIMock _apiMock;
    UsersManager _manager;
    setUp(() {
      _random = new Random(DateTime.now().millisecondsSinceEpoch);
      _apiMock = new _UsersAPIMock();
      _manager = new UsersManager(_apiMock);
    });

    test('can find single user by id', () async {
      // arrange
      final userDtoItems = List.generate(
        10,
        (i) => new UserDto()
          ..id = i
          ..isActive = _random.nextBool()
          ..birthDate = new DateTime(
            _random.nextInt(100) + 1900, //1900-2000
            _random.nextInt(12),
            _random.nextInt(29), // minimal count of days in month - 28
            _random.nextInt(24),
            _random.nextInt(60),
            _random.nextInt(60),
          )
          ..name = 'username $i',
      );
      final user = userDtoItems[_random.nextInt(10)];
      final userId = new UserId(user.id);
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getById(userId);
      // assert
      expect(result, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });

    test('can find all active users', () async {
      // arrange
      final userDtoItems = List.generate(
        10,
        (i) => new UserDto()
          ..id = i
          ..isActive = false
          ..birthDate = new DateTime(
            _random.nextInt(100) + 1900, //1900-2000
            _random.nextInt(12),
            _random.nextInt(29), // minimal count of days in month - 28
            _random.nextInt(24),
            _random.nextInt(60),
            _random.nextInt(60),
          )
          ..name = 'username $i',
      );
      final user = userDtoItems[_random.nextInt(10)];
      user.isActive = true;
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getActiveUsers();
      // assert
      expect(result, hasLength(1));
      expect(result.first, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });
  });
```
Obviously, there are a lot of duplication in this sample. Most of developers will try to extract useful helpers to reduce duplication.

### Attempt 2: using handwritten helpers
```dart
 group('Attempt #2: using handwriten helpers', () {
    Random _random;
    _UsersAPIMock _apiMock;
    UsersManager _manager;

    setUp(() {
      _random = new Random(DateTime.now().millisecondsSinceEpoch);
      _apiMock = new _UsersAPIMock();
      _manager = new UsersManager(_apiMock);
    });

    UserDto _createRandomUserDto(int id, {bool isActive = false}) {
      return new UserDto()
        ..id = id
        ..isActive = isActive ?? _random.nextBool()
        ..birthDate = new DateTime(
          _random.nextInt(100) + 1900, //1900-2000
          _random.nextInt(12),
          _random.nextInt(29), // minimal count of days in month - 28
          _random.nextInt(24),
          _random.nextInt(60),
          _random.nextInt(60),
        )
        ..name = 'username $id';
    }

    test('can find single user by id', () async {
      // arrange
      final userDtoItems = List.generate(10, _createRandomUserDto);
      final user = userDtoItems[_random.nextInt(10)];
      final userId = new UserId(user.id);
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getById(userId);
      // assert
      expect(result, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });

    test('can find all active users', () async {
      // arrange
      final userDtoItems = List.generate(10, (i) => _createRandomUserDto(i, isActive: false));
      final user = userDtoItems[_random.nextInt(10)];
      user.isActive = true;
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getActiveUsers();
      // assert
      expect(result, hasLength(1));
      expect(result.first, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });
  });
```
We move `UserDto` instance creation logic to `_createRandomUserDto` and arrange section is read much easier. This is good but not enough. Lets rewrite this test using Activatory.

### Attempt #3: using Activatory
With Activatory we can not waste our time and use out-of-the-box helpers to create random instances of objects.
```dart
group('Attempt #3: using Activatory', () {
    Activatory _activatory;
    _UsersAPIMock _apiMock;
    UsersManager _manager;
    setUp(() {
      _activatory = new Activatory();
      _apiMock = new _UsersAPIMock();
      _manager = new UsersManager(_apiMock);
    });

    test('can find single item by id', () async {
      // arrange
      final userDtoItems = _activatory.getMany<UserDto>(count: 10);
      final user = _activatory.take(userDtoItems);
      final userId = new UserId(user.id);
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getById(userId);
      // assert
      expect(result, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });

    test('can find all active users', () async {
      // arrange
      final userDtoItems = _activatory.getMany<UserDto>(count: 10);
      userDtoItems.forEach((x) => x.isActive = false);
      final user = _activatory.take(userDtoItems);
      user.isActive = true;
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getActiveUsers();
      // assert
      expect(result, hasLength(1));
      expect(result.first, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });
  });
```
No handwritten helpers are required. There is no need to write code describing **how** to create random instance of `UserDto`.

**With activatory test code becomes more readable, brief and maintainable.** 

But it is important to mention fact that tests are most useful when we are extending existing functionality.

### Attempt 4: Extending `UserDto` with `UserSettingsDto`
Lets extends our `UserDto` with extra data field `UserSettingsDto`:
```dart
class UserDto {
  // other fields skipped for brief
  UserContactsDto userContacts;
}

class UserContactsDto {
  String email;
  bool notificationsEnabled;
}

class UserViewModel {
  // other fields skipped for brief
  final String email;

  UserViewModel(this.name, this.id, this.birthDate, this.email);
}

class UsersManager {
  // other members skipped for brief
  UserViewModel _convert(UserDto x) => new UserViewModel(x.name, new UserId(x.id), x.birthDate, x.userContacts.email);
}
```
If we run tests now we will found that tests written without Activatory are failing with cryptic errors, e.g. ` NoSuchMethodError: The getter 'email' was called on null.`

That's because we forgot to update our tests! In "[Attemp 2](#attempt-2-using-handwritten-helpers)" sample we need to update `_createRandomUserDto` method implementation to create randomly filled `UserSettingsDto` and pass it to `UserDto`. So most of `UserDto` extending will require the helper to be updated!

**Activatory helps you to make your tests more reliable and more sustainable to changes.**

Adding new data to models is just half of a story. Let's add complexity - another consumer of UsersAPI.

### Attempt 5: Adding more consumers to `UsersAPI`
Let's add `MailingRecipientsManager` class responsible for providing an email list for mailing.

```dart
class MailingRecipientsManager {
  final UsersAPI _api;

  MailingRecipientsManager(this._api);

  Future<List<String>> getRecipientsList() async {
    final items = await _api.getAll();
    return items.map((x) => x.userContacts.email).toList(growable: false);
  }
}
```

If we write tests for this class we will hit the following problems with `_createRandomUserDto` helper:
* method is private for file,
* helper didn't allow to control creation of `UserSettingsDto`.

The first problem can be resolved by moving the helper method to a separate file named `user_dto_helper.dart`. The second one can be resolved by passing `UserSettingsDto` or email as a parameter to the helper. Both fixes will make our test code more and more unmaintainable. The helper will grow to match all corner cases. So in the future, the helper will become troublemaker - it will be changed for every business logic change, changes will flow from different branches and it will harder and harder to merge them.

**Activatory helps you to make your tests code more flexible and maintainable.**
