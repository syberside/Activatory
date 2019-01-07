import 'dart:mirrors';

import 'package:activatory/src/argument_info.dart';

class CtorInfo {
  final ClassMirror _classMirror;
  final Symbol _ctor;
  final List<ArgumentInfo> _args;

  CtorInfo(this._classMirror, this._ctor, this._args);

  List<ArgumentInfo> get args => _args;
  ClassMirror get classMirror => _classMirror;
  Symbol get ctor => _ctor;
}