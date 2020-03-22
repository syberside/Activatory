## v1.2.1
- Added unit test for \#42 issue, docs adjusted

## v1.2.0
- Implemented support of Set class
- \#45 bugfix - iterable is no more substitution for every iterable subclass

## v1.1.0
- `except` parameter added to take and takeUntyped methods
- Implemented correct activation for `Duration` type
- Changed implementation of `DateTime` factory - now it uses same range as `Duration`
- Changed implementation of `int` factory - now it can return negative number
- `Random` instance used inside `Activatory` can be now accessed from outside
- Added `useOneOf` factory overriding method to setup available collection of instances

## v1.0.1
- Code style fixes to increase scoring on pub.dev 

## v1.0.0
- Public release!

## v0.0.25
- Docs and samples update
- Key parameter is allays used as named now
- pedantic included as default analyzer config
- fromRandom constructor added
- Seed can now be provided from outside for repeatability

## v0.0.24
- README.md huge update
- Extra tests added

## v0.0.23
- Analyser options configured. Analyzer issues fixed.
- Activation contexts mismatch fixed
- Few refactorings applied
- Bug \#30 fixed

## v0.0.22
- Implemented take and takeTyped methods to select random item from Iterable
- Public API documentation improved
- Entry points refactored
- Fixed issues with list, iterable, map, Params and generic class activation. Pre configuration is not required any more.
- Removed params object and arg customization functionality
- Huge refactoring performed
- README.md project description refactored

## v0.0.21
- Bugfix and pubspec update
- Changelog sorting reverted

## v0.0.20
- Added fields and setter values activation
- Added customization for fields and setters activation

## v0.0.19
- Added default argument values usage customization
- Added per key customization

## v0.0.18
- Added getMany and getManyTyped for effortless array creation
- Added type aliases support

## v0.0.17
- Implemented ctor parameter overloading by type and (optionally) by name 

## v0.0.16
- Bugfix and documentation improvements
- Added support for Map<K,V> generating

## v0.0.15
- Const ctor supported

## v0.0.14
- Fixed wrong counting of types in recursion limiter
- Added customization mechanism for recursion limiter and array backend
- Added Null type support

## v0.0.13
- Added ctor resolution customization mechanism

## v0.0.12
- Added test for generics support with explicit overriding
- Added parameterizable custom factories support

## v0.0.11
- Added recursion handling
- Performed large refactoring

## v0.0.10
- Added custom exception type for all library internal errors

## v0.0.9
- Added effortless support for primitive types arrays generating (except of enums arrays)
- Added support for complex types array generating with explicit array registration
- Fixed enum generation bug (generated values was not real enum values from values list)

## v0.0.8
- Back-ends now can be registered and lookuped using any object as a key
- useSingleton renamed to pin, useValue renamed to pinValue

## v0.0.7
- Added ability to register generated singleton
- Added ability to register pre defined value

## v0.0.6
- Added ability to register factory explicitly

## v0.0.5
- Named arguments supported
- Complex object activation now respects default non null values

## v0.0.1-0.0.4
- Added support for primitive objects activation: int, double, String, bool, DateTime
- Added support for complex object activation by calling ctors, named ctors, factories and using positional arguments
