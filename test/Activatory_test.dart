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

  test('On unknown type throws',(){
    expect(()=> _activatory.get(NotRegistered), throwsA(isInstanceOf<Exception>()));
  });
}

class NotRegistered{}