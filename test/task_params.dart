import 'package:activatory/activatory.dart';
import 'package:mockito/mockito.dart';

import 'test-classes.dart';

class TaskMock extends Mock implements Task {}

class TaskParams extends Params<Task> {
  Value<int> _id;
  Value<String> _title;
  Value<bool> _isRecurrent;
  Value<bool> _isTemplate;
  Value<DateTime> _dueDate;

  TaskParams({
    Value<int> id,
    Value<String> title,
    Value<bool> isRecurrent,
    Value<bool> isTemplate,
    Value<DateTime> dueDate = const NullValue<DateTime>(),
  }) {
    _id = id;
    _title = title;
    _isRecurrent = isRecurrent;
    _isTemplate = isTemplate;
    _dueDate = dueDate;
  }

  @override
  Task resolve(ActivationContext ctx) {
    return new TaskStub(
      get(_id, ctx),
      get(_title, ctx),
      get(_isRecurrent, ctx),
      get(_isTemplate, ctx),
      get(_dueDate, ctx),
    );
  }
}

class TaskStub implements Task {
  final int _id;
  final String _title;
  final bool _isRecurrent;
  final bool _isTemplate;
  final DateTime _dueDate;

  TaskStub(this._id, this._title, this._isRecurrent, this._isTemplate, this._dueDate);

  @override
  DateTime get dueDate => _dueDate;

  @override
  int get id => _id;

  @override
  bool get isRecurrent => _isRecurrent;

  @override
  bool get isTemplate => _isTemplate;

  @override
  String get title => _title;
}
