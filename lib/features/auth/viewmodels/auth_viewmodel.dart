import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/features/auth/models/user_model.dart';
import 'package:thedaymerge/features/auth/repositories/auth_cloud_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  // --- 1. Global Auth State ---
  UserModel? _user;
  StreamSubscription<UserModel?>? _userSubscription;
  UserModel? get user => _user;

  // --- 2. View-specific State (for StartPage & ProfilePage) ---
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel({required AuthRepository repository}) : _repository = repository {
    _userSubscription = _repository.user.listen((newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  // --- 3. View-specific Getters (for ProfilePage) ---
  String get userEmail => _user?.email ?? "이메일 없음";
  String? get userName => _user?.name;
  String? get joinDateString {
    if (_user?.joinDate != null) {
      return DateFormat('yyyy.MM.dd').format(_user!.joinDate!);
    }
    return null;
  }

  // --- 4. Business Logic ---
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// 로그인
  Future<String?> login() async {
    final email = emailController.text;
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) return "이메일과 비밀번호를 입력해주세요.";

    _setLoading(true);
    try {
      await _repository.login(email: email, password: password);
      return null;
    } catch (e) {
      return "로그인 실패: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// 회원가입
  Future<String?> signUp() async {
    final email = emailController.text;
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) return "이메일과 비밀번호를 입력해주세요.";

    _setLoading(true);
    try {
      await _repository.signUp(email: email, password: password);
      return null;
    } catch (e) {
      return "회원가입 실패: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }
  
  /// 로그아웃
  Future<void> logout() async {
    await _repository.logout();
    // 로그아웃 시 컨트롤러 초기화
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
