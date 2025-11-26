import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_cloud_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _user;
  StreamSubscription<UserModel?>? _userSubscription;

  AuthViewModel({required AuthRepository repository}) : _repository = repository {
    _userSubscription = _repository.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    await _repository.login(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _repository.signUp(email: email, password: password);
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
