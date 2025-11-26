import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/features/auth/models/user_model.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  ProfileViewModel(this._authViewModel) {
    // AuthViewModel의 상태 변경(예: 유저 정보 업데이트)을 감지하여
    // 이 ViewModel을 구독하는 UI도 갱신하도록 리스너를 추가합니다.
    _authViewModel.addListener(notifyListeners);
  }

  // AuthViewModel로부터 현재 유저 정보를 가져옵니다.
  UserModel? get _user => _authViewModel.user;

  // --- View에 바인딩될 데이터 ---
  
  String get userEmail => _user?.email ?? "이메일 없음";
  
  String? get userName => _user?.name;

  String? get joinDateString {
    if (_user?.joinDate != null) {
      // 날짜 포매팅 비즈니스 로직
      return DateFormat('yyyy.MM.dd').format(_user!.joinDate!);
    }
    return null;
  }

  // --- View가 호출할 비즈니스 로직 ---

  Future<void> logout() async {
    await _authViewModel.logout();
  }

  // 리스너를 제거하여 메모리 누수를 방지합니다.
  @override
  void dispose() {
    _authViewModel.removeListener(notifyListeners);
    super.dispose();
  }
}
