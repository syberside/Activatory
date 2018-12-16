# Activatory

This project is aimed to bring a test data generator to Dart's ecosystem.
This will greatly simplify unit testing and especially Test-Driven Development.

This project is inspired by [.NET Autofixture library](https://github.com/AutoFixture/AutoFixture).

This is my first Dart project. Actually, this is my "pet-project" so there are no exact plans and etc.

## TODO's:
- [x] Add primitive types support
- [ ] Add complex types support
  - [x] first ctor
  - [ ] factory methods
  - [ ] named constructors
  - [ ] put all together and find minimal/random way of creation
- [ ] Add implicit factory registration
- [ ] Add fixed (singleton) values support
- [ ] Add parameter overloading by name
- [ ] Add parameter overloadyng by type
  - [ ] exact match
  - [ ] any subtypes match
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
