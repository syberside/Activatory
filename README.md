# Activatory

[![Build Status](https://travis-ci.com/syberside/Activatory.svg?branch=master)](https://travis-ci.com/syberside/Activatory)
[![Coverage Status](https://coveralls.io/repos/github/syberside/Activatory/badge.svg)](https://coveralls.io/github/syberside/Activatory)
[![Pub](https://img.shields.io/pub/v/activatory.svg)](https://pub.dartlang.org/packages/activatory)

Test data generator for Dart ecosystem.
Simplifies unit testing and Test-Driven Development.

This project is inspired by .NET [Autofixture](https://github.com/AutoFixture/AutoFixture) library.

## Supported types
Activatory can be used to create:
- random values of primitive types (String, int, double, bool, DateTime, enums, Null);
- random values of complex types using all [Dart constructor](https://dart.dev/guides/language/language-tour#constructors) types;
- List, Iterables and Maps;
- random values of recursive types (trees, linked lists and etc);
- random values of generic classes.

Any constructor arguments and public fields/setter values will be created and passed automatically.

## Customization
Most of activation behaviors can be customized:
- default factories can be overridden with explicit function call, singleton value created by user/automatically; 
- constructor resolution behavior can be changed to select first defined, random, random named or default one;
- default values for arguments can be ignored, used while they are not null or always used as is;
- public fields and setters can be ignored or filled with random data;
- array size and allowed recursion level can changed from default value (3) to any integer;
- any subclass can be marked as substitution for superclass.

Customization can be defined for:
- all types,
- per type,
- for specific activation call using key argument which can be instance of any type.

## Helpers
Activatory allows to simplify test code by providing usefull helpers for:
- selecting one or more random items from array;
- creating list of Objects of given type.

## Samples
For up-to-date list of samples see [example folder on project GitHub](https://github.com/syberside/Activatory/tree/master/example) or [example section on pub package page](https://pub.dev/packages/activatory#-example-tab-).

## Supported platforms
Current implementation depends on reflection ([Mirrors package](https://api.dart.dev/stable/2.7.1/dart-mirrors/dart-mirrors-library.html)). So, **Activatory supports only VM platform for now**.
 
 If you have package depending on other platform (e.g. Flutter or Dart Web) you should move testing required business logic to separate platform independent package to be able to use Activatory in tests. Platform independent package of Activatory will be implemented in the future, but it will require much more setup from user (due to Mirrors unavailability). Also, keep in mind, that moving business logic to separate package is almost always a good decision.

## Further improvements
For planned features and more see [enhancements on github](https://github.com/syberside/Activatory/issues?utf8=%E2%9C%93&q=is%3Aenhancement+is%3Aopen+). 
