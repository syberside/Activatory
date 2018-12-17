# Activatory

[![Build Status](https://travis-ci.com/syberside/Activatory.svg?branch=master)](https://travis-ci.com/syberside/Activatory)
[![Pub](https://img.shields.io/pub/v/activatory.svg)](https://pub.dartlang.org/packages/activatory)

This project is aimed to bring a test data generator to Dart's ecosystem.
This will greatly simplify unit testing and especially Test-Driven Development.

This project is inspired by .NET [Autofixture](https://github.com/AutoFixture/AutoFixture) library.

This is my first Dart project. Actually, this is my "pet-project" so there are no exact plans and etc.

## Project TODO's:
- [x] Add primitive types support
- [ ] Add complex types support
  - [x] using constructor
  - [x] using factory methods
  - [x] using named constructors
  - [ ] choosing strategy to select factory: random/round robin/first/shortest/longest
  - [ ] using positional parameters
  - [ ] using default argument values where can (if can be implemented)
- [ ] Add ability to explicit register factory
- [ ] Add fixed (singleton) values support
- [ ] Add parameter overloading by name
- [ ] Add parameter overloading by type
- [ ] Add configuration layers and reusability for complex cases
- [ ] Add paramsObject and paramsObject to factory matching
- [ ] Add ability to customize context before data generation without saving settings to context
- [ ] Add paramsObject layering
- [ ] *Read autofixture sources to gather ideas and vision
- [ ] *Add examples and docs
- [ ] *Add CI/CD:
  - [ ] *build and publish to pub
  - [ ] *coverage reports
- [ ] Add nice looking readme and github repo info
- [ ] Add recursion handling (which one strategy should be used?)
- [ ] Encapsulate all errors inside library (throws only ActivatoryException)
- [ ] Add feature customization (e.g. ctor resolution strategy, default values handling and etc)
