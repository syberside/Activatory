# Activatory

[![Build Status](https://travis-ci.com/syberside/Activatory.svg?branch=master)](https://travis-ci.com/syberside/Activatory)
[![Pub](https://img.shields.io/pub/v/activatory.svg)](https://pub.dartlang.org/packages/activatory)

This project is aimed to bring a test data generator to Dart's ecosystem.
This will greatly simplify unit testing and especially Test-Driven Development.

This project is inspired by .NET [Autofixture](https://github.com/AutoFixture/AutoFixture) library.

## Supported features
- Effortless primitive types (String, int, double, bool, DateTime, enums) generating
- Effortless complex object generating using constructors/factory methods/named constructors (default values for arguments are preferred)
- Overriding default generating behavior with custom factories, pinned values defined by user or auto generated
- Overriding default generating behavior for specific cases using any object as a key
- Arrays generating: it is effortless for primitive types and require explicit registration for enums and complex types
- Support of recursive graphs (trees, linked lists and etc) 
- Generic class instances generating with explicit factory registration

## Roadmap
This is my first Dart project and, actually, this is "pet-project". So there are no exact plans and etc.
For planned features and more see [enhancements on github](https://github.com/syberside/Activatory/issues?utf8=%E2%9C%93&q=is%3Aenhancement+is%3Aopen+). 
