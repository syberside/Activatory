
## v0.0.18
- Bugfix and pubspec update
- Changelog sorting reverted

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
