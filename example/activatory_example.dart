import 'package:activatory/src/activatory.dart';

main() {
  var activatory = new Activatory();

  // We can create primitive types
  print('Int: ${activatory.getTyped<int>()}');
  print('String: ${activatory.getTyped<String>()}');
  print('DateTime: ${activatory.getTyped<DateTime>()}');
  print('Bool: ${activatory.getTyped<bool>()}');
  print('TestEnum: ${activatory.getTyped<TestEnum>()}');

  //We can create complex types
  var complexClassInstance = activatory.getTyped<SomeComplexClass>();
  print('Complex.String: ${complexClassInstance.stringField}');

  //And yes, we can create them recursively
  var moreComplexClassInstance = activatory.getTyped<MoreComplexClass>();
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
