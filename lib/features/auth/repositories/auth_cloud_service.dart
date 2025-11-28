import 'package:firebase_auth/firebase_auth.dart';
import 'package:thedaymerge/features/auth/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 순서 2 & 3: Auth에서 계정 생성하고 -> 바로 UserModel로 만들어서 리턴!
  Future<UserModel> signUp({required String email, required String password}) async {
    // 1. Firebase Auth에 "계정 만들어줘" 요청
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;

    // 2. 만들어진 계정에서 정보 뽑아내기 (이메일, UID, 가입일)
    return UserModel(
      uid: user.uid,
      email: user.email!,
      // 여기서 메타데이터(가입일)를 바로 가져옴
      joinDate: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;

    return UserModel(
      uid: user.uid,
      email: user.email!,
      joinDate: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  // (참고: 로그인 유지 기능을 위해 현재 유저 가져오는 함수)
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
        uid: user.uid,
        email: user.email!,
        joinDate: user.metadata.creationTime ?? DateTime.now()
    );
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}