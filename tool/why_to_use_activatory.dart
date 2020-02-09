/// Source code for "Why to use activatory" section of README.md
import 'dart:async';
import 'dart:math';

import 'package:activatory/activatory.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() async {
  group('Attempt #1: using Random class inside test', () {
    Random _random;
    _UsersAPIMock _apiMock;
    UsersManager _manager;
    setUp(() {
      _random = new Random(DateTime.now().millisecondsSinceEpoch);
      _apiMock = new _UsersAPIMock();
      _manager = new UsersManager(_apiMock);
    });

    test('can find single user by id', () async {
      // arrange
      final userDtoItems = List.generate(
        10,
        (i) => new UserDto()
          ..id = i
          ..isActive = _random.nextBool()
          ..birthDate = new DateTime(
            _random.nextInt(100) + 1900, //1900-2000
            _random.nextInt(12),
            _random.nextInt(29), // minimal count of days in month - 28
            _random.nextInt(24),
            _random.nextInt(60),
            _random.nextInt(60),
          )
          ..name = 'username $i',
      );
      final user = userDtoItems[_random.nextInt(10)];
      final userId = new UserId(user.id);
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getById(userId);
      // assert
      expect(result, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });

    test('can find all active users', () async {
      // arrange
      final userDtoItems = List.generate(
        10,
        (i) => new UserDto()
          ..id = i
          ..isActive = false
          ..birthDate = new DateTime(
            _random.nextInt(100) + 1900, //1900-2000
            _random.nextInt(12),
            _random.nextInt(29), // minimal count of days in month - 28
            _random.nextInt(24),
            _random.nextInt(60),
            _random.nextInt(60),
          )
          ..name = 'username $i',
      );
      final user = userDtoItems[_random.nextInt(10)];
      user.isActive = true;
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getActiveUsers();
      // assert
      expect(result, hasLength(1));
      expect(result.first, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });
  });

  group('Attempt #2: using handwriten helpers', () {
    Random _random;
    _UsersAPIMock _apiMock;
    UsersManager _manager;

    setUp(() {
      _random = new Random(DateTime.now().millisecondsSinceEpoch);
      _apiMock = new _UsersAPIMock();
      _manager = new UsersManager(_apiMock);
    });

    UserDto _createRandomUserDto(int id, {bool isActive = false}) {
      return new UserDto()
        ..id = id
        ..isActive = isActive ?? _random.nextBool()
        ..birthDate = new DateTime(
          _random.nextInt(100) + 1900, //1900-2000
          _random.nextInt(12),
          _random.nextInt(29), // minimal count of days in month - 28
          _random.nextInt(24),
          _random.nextInt(60),
          _random.nextInt(60),
        )
        ..name = 'username $id';
    }

    test('can find single user by id', () async {
      // arrange
      final userDtoItems = List.generate(10, _createRandomUserDto);
      final user = userDtoItems[_random.nextInt(10)];
      final userId = new UserId(user.id);
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getById(userId);
      // assert
      expect(result, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });

    test('can find all active users', () async {
      // arrange
      final userDtoItems = List.generate(10, (i) => _createRandomUserDto(i, isActive: false));
      final user = userDtoItems[_random.nextInt(10)];
      user.isActive = true;
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getActiveUsers();
      // assert
      expect(result, hasLength(1));
      expect(result.first, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });
  });

  group('Attempt #3: using Activatory', () {
    Activatory _activatory;
    _UsersAPIMock _apiMock;
    UsersManager _manager;
    setUp(() {
      _activatory = new Activatory();
      _apiMock = new _UsersAPIMock();
      _manager = new UsersManager(_apiMock);
    });

    test('can find single item by id', () async {
      // arrange
      final userDtoItems = _activatory.getMany<UserDto>(count: 10);
      final user = _activatory.take(userDtoItems);
      final userId = new UserId(user.id);
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getById(userId);
      // assert
      expect(result, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });

    test('can find all active users', () async {
      // arrange
      final userDtoItems = _activatory.getMany<UserDto>(count: 10);
      userDtoItems.forEach((x) => x.isActive = false);
      final user = _activatory.take(userDtoItems);
      user.isActive = true;
      when(_apiMock.getAll()).thenAnswer((_) => Future.value(userDtoItems));
      // act
      final result = await _manager.getActiveUsers();
      // assert
      expect(result, hasLength(1));
      expect(result.first, predicate<UserViewModel>((x) => _isViewModelMatchUserDto(x, user)));
    });
  });
}

bool _isViewModelMatchUserDto(UserViewModel x, UserDto user) =>
    x.id.value == user.id && x.name == user.name && x.birthDate == user.birthDate;

class UserDto {
  String name;
  int id;
  bool isActive;
  DateTime birthDate;
  UserContactsDto userContacts;
}

class UserContactsDto {
  String email;
  bool notificationsEnabled;
}

class UserId {
  final int value;

  UserId(this.value);
}

class UserViewModel {
  final String name;
  final UserId id;
  final DateTime birthDate;
  final String email;

  UserViewModel(this.name, this.id, this.birthDate, this.email);
}

abstract class UsersAPI {
  Future<List<UserDto>> getAll();
}

class UsersManager {
  final UsersAPI _api;

  UsersManager(this._api);

  Future<List<UserViewModel>> getActiveUsers() async {
    final allItems = await _api.getAll();
    return allItems.where((x) => x.isActive).map(_convert).toList(growable: false);
  }

  UserViewModel _convert(UserDto x) => new UserViewModel(x.name, new UserId(x.id), x.birthDate, x.userContacts.email);

  Future<UserViewModel> getById(UserId id) async {
    final allItems = await _api.getAll();
    final userDto = allItems.firstWhere((x) => x.id == id.value);
    return _convert(userDto);
  }
}

class MailingRecipientsManager {
  final UsersAPI _api;

  MailingRecipientsManager(this._api);

  Future<List<String>> getRecipientsList() async {
    final items = await _api.getAll();
    return items.map((x) => x.userContacts.email).toList(growable: false);
  }
}

class _UsersAPIMock extends Mock implements UsersAPI {}
