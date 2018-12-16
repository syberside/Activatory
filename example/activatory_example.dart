import 'package:Activatory/src/activatory.dart';

main() {
  var activatory = new Activatory();

  // We can create primitive types
  print('Int: ${activatory.getTyped<int>()}');
  print('String: ${activatory.getTyped<String>()}');
  print('DateTime: ${activatory.getTyped<DateTime>()}');
  print('Bool: ${activatory.getTyped<bool>()}');

  //We can create complex types
  var complexClassInstance = activatory.getTyped<SomeComplexClass>();
  print('Complex.String: ${complexClassInstance.stringField}');

  //And yes, we can create them recursively
  var moreComplexClassInstance = activatory.getTyped<MoreComplexClass>();
  print('MoreComplex.DateTime: ${moreComplexClassInstance.dateTimeField}');
  print('MoreComplex.Complex.String: ${moreComplexClassInstance.someComplexClass.stringField}');
}

class SomeComplexClass{
  String _stringField;
  String get stringField => _stringField;

  SomeComplexClass(this._stringField);
}

class MoreComplexClass{
  DateTime _dateTimeField;
  DateTime get dateTimeField => _dateTimeField;

  SomeComplexClass _someComplexField;
  SomeComplexClass get someComplexClass => _someComplexField;

  MoreComplexClass(this._dateTimeField, this._someComplexField);
}
