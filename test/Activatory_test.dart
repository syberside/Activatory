import 'package:Activatory/Activatory.dart';
import 'package:test/test.dart';

void main() {
  Activatory _activatory;
  setUp(() {
    _activatory = new Activatory();
  });

  group('Can generate primitive types', () {
    var types = [String, int, bool, DateTime, double];
    for(var type in types){
      test(type, () {
        var result = _activatory.get(type);
        expect(result, allOf([
          isNotNull
        ]));
        expect(result.runtimeType, same(type));
      });
    }
  });

  group('Can create complex object', (){

    test('with empty ctor',(){
      var result = _activatory.getTyped<NotRegistered>();
      expect(result, isNotNull);
      expect(result.intField, isNull);
    });

    test('with primitives only in ctor',(){
      var result = _activatory.getTyped<PrimitiveComplexObject>();
      expect(result, isNotNull);
      expect(result.dateTimeField, isNotNull);
      expect(result.boolField, isNotNull);
      expect(result.doubleField, isNotNull);
      expect(result.stringField, isNotNull);
      expect(result.intField, isNotNull);
    });
  });
}

class NotRegistered{
  int intField;
}

class PrimitiveComplexObject{
  int _intField;
  int get intField => _intField;

  String _stringField;
  String get stringField => _stringField;

  double _doubleField;
  double get doubleField => _doubleField;

  bool _boolField;
  bool get boolField => _boolField;

  DateTime _dateTimeField;
  DateTime get dateTimeField => _dateTimeField;

  PrimitiveComplexObject(
      this._intField, this._stringField, this._doubleField,
      this._boolField, this._dateTimeField);
}