import 'dart:mirrors';

import 'package:activatory/src/argument_info.dart';

class CtorInfo {
  final ClassMirror _classMirror;
  final Symbol _ctor;
  final List<ArgumentInfo> _args;
  final CtorType _type;
  final Type _classType;

  CtorInfo(this._classMirror, this._ctor, this._args, this._type, this._classType);

  List<ArgumentInfo> get args => _args;
  ClassMirror get classMirror => _classMirror;
  Symbol get ctor => _ctor;
  CtorType get type => _type;
  Type get classType => _classType;
}

enum CtorType{
  Default,
  Named
}