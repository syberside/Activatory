import 'package:activatory/src/activatory.dart';

main() {
  var activatory = new Activatory();

  // We can create primitive types
  print('Int: ${activatory.get<int>()}');
  print('String: ${activatory.get<String>()}');
  print('DateTime: ${activatory.get<DateTime>()}');
  print('Bool: ${activatory.get<bool>()}');
  print('TestEnum: ${activatory.get<TestEnum>()}');

  //We can create complex types
  var complexClassInstance = activatory.get<SomeComplexClass>();
  print('Complex.String: ${complexClassInstance.stringField}');

  //And yes, we can create them recursively
  var moreComplexClassInstance = activatory.get<MoreComplexClass>();
  print('MoreComplex.DateTime: ${moreComplexClassInstance.dateTimeField}');
  print('MoreComplex.Complex.String: ${moreComplexClassInstance.someComplexClass.stringField}');

  //See activatory_test.dart for full feature list
}

class MoreComplexClass {
  DateTime _dateTimeField;
  SomeComplexClass _someComplexField;

  MoreComplexClass(this._dateTimeField, this._someComplexField);

  DateTime get dateTimeField => _dateTimeField;

  SomeComplexClass get someComplexClass => _someComplexField;
}

class SomeComplexClass {
  String _stringField;

  SomeComplexClass(this._stringField);

  String get stringField => _stringField;
}

enum TestEnum { A, B, C }
