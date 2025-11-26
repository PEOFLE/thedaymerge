import 'package:flutter/material.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';

class StartViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StartViewModel(this._authViewModel);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 로그인 비즈니스 로직
  Future<String?> login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return "이메일과 비밀번호를 입력해주세요.";
    }

    _setLoading(true);
    try {
      await _authViewModel.login(email, password);
      return null; // 성공 시 null 반환
    } catch (e) {
      return "로그인 실패: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  /// 회원가입 비즈니스 로직
  Future<String?> signUp() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return "이메일과 비밀번호를 입력해주세요.";
    }

    _setLoading(true);
    try {
      await _authViewModel.signUp(email, password);
      return null; // 성공 시 null 반환
    } catch (e) {
      return "회원가입 실패: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
