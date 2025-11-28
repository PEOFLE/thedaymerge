import 'package:flutter/material.dart';
import 'package:thedaymerge/features/auth/models/user_model.dart';
import 'package:thedaymerge/features/auth/repositories/auth_cloud_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  // 내 정보 담을 변수
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  // ★ 생성자에서 복잡한 리스너(Stream) 삭제함!
  // 대신 앱 켤 때 "로그인 되어있나?" 한번만 확인
  AuthViewModel({required AuthRepository repository}) : _repository = repository {
    _user = _repository.getCurrentUser();
  }

  // 순서 1 -> 4 흐름
  Future<String?> signUp() async {
    _isLoading = true;
    notifyListeners();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // [순서 1] 이메일, 비번 입력 후 버튼 클릭됨

      // [순서 2~3] 레포지토리야, 가서 계정 만들고 그 정보 바로 가져와!
      // (await 때문에 정보가 올 때까지 다음 줄로 안 넘어감)
      UserModel newUser = await _repository.signUp(email: email, password: password);

      // [순서 4] 가져온 정보를 내 변수(_user)에 저장!
      _user = newUser;
      _isLoading = false;
      // "화면아, _user 변수에 값 들어왔으니까 화면 갱신해!"라고 알림
      notifyListeners();

      return null; // 성공
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      // 에러 메시지를 바로 리턴해버림!
      if (e.toString().contains('email-already-in-use')) {
        return "이미 가입된 이메일입니다.";
      } else if (e.toString().contains('weak-password')) {
        return "비밀번호는 6자리 이상이어야 합니다.";
      } else {
        return "오류 발생: 잠시 후 다시 시도해주세요.";
      }
    }
  }

  Future<String?> signIn() async {
    _isLoading = true;
    notifyListeners();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // [순서 1] 이메일, 비번 입력 후 버튼 클릭됨

      // [순서 2~3] 레포지토리야, 가서 계정 만들고 그 정보 바로 가져와!
      // (await 때문에 정보가 올 때까지 다음 줄로 안 넘어감)
      UserModel newUser = await _repository.signIn(email: email, password: password);

      // [순서 4] 가져온 정보를 내 변수(_user)에 저장!
      _user = newUser;
      _isLoading = false;

      // "화면아, _user 변수에 값 들어왔으니까 화면 갱신해!"라고 알림
      notifyListeners();

      return null; // 성공
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "실패: ${e.toString()}";
    }
  }

  Future<void> singOut() async {

    await _repository.logout();
    emailController.clear();
    passwordController.clear();
    _user = null;
    notifyListeners();
  }

// ... 로그아웃 등 나머지 로직 ...
}