import 'dart:mirrors';

import 'package:activatory/src/factories/ctor/argument_info.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';

class CtorInfo {
  final ClassMirror classMirror;
  final Symbol ctor;
  final List<ArgumentInfo> args;
  final CtorType type;
  final Type classType;

  CtorInfo(this.classMirror, this.ctor, this.args, this.type, this.classType);
}
