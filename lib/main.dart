import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'functions/notification_service.dart';

import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'features/main_navigation/screen/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 서비스 초기화
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // 날짜 포맷팅 초기화
  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '그날머지?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.textBlack),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (FirebaseAuth.instance.currentUser != null) {
          return const MainNavigationScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _passwordErrorText; // 🔥 비밀번호 빨간 에러 메시지용 변수

  // 🔥 [핵심 1] 비밀번호 유효성 검사 함수
  bool _validatePassword() {
    final pw = _passwordController.text.trim();
    String? errorMsg;

    if (pw.isEmpty) {
      errorMsg = '비밀번호를 입력해주세요.';
    } else if (pw.length < 6) {
      errorMsg = '6자리 이상 입력해주세요.';
    } else if (!RegExp(r'[0-9]').hasMatch(pw)) {
      errorMsg = '숫자를 포함해야 합니다.'; // 숫자 체크
    } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw)) {
      errorMsg = '특수문자(기호)를 포함해야 합니다.'; // 특수문자 체크
    }

    setState(() {
      _passwordErrorText = errorMsg;
    });

    return errorMsg == null; // 에러가 없으면 true 반환 (통과)
  }

  // 🔥 [핵심 2] Firebase 에러를 한국어로 변환하는 함수
  String _getFriendlyError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email': return '이메일 형식이 올바르지 않습니다.';
        case 'user-not-found': return '가입되지 않은 이메일입니다.';
        case 'wrong-password': return '비밀번호가 틀렸습니다.';
        case 'email-already-in-use': return '이미 가입된 이메일입니다.';
        case 'weak-password': return '비밀번호 보안이 취약합니다.';
        case 'operation-not-allowed': return '로그인 방식이 비활성화되었습니다.';
        case 'user-disabled': return '정지된 계정입니다.';
        case 'too-many-requests': return '잠시 후 다시 시도해주세요.';
        case 'network-request-failed': return '네트워크 연결을 확인해주세요.';
        case 'invalid-credential': return '인증 정보가 틀렸습니다.';
        default: return '오류가 발생했습니다. (${e.code})';
      }
    }
    return '알 수 없는 오류가 발생했습니다.';
  }

  Future<void> _signUp() async {
    // 1. 회원가입 시에는 비밀번호 규칙을 엄격하게 검사
    if (!_validatePassword()) return;

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final pw = _passwordController.text.trim();
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pw);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공! 환영합니다.')));

    } catch (e) {
      // 2. 에러 발생 시 한국어 메시지 출력
      _showError(_getFriendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    // 로그인 시에는 굳이 복잡한 규칙 검사보다 입력 여부만 확인하거나 바로 시도
    if (_passwordController.text.trim().isEmpty) {
      _showError("비밀번호를 입력해주세요.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final pw = _passwordController.text.trim();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pw);
    } catch (e) {
      // 3. 로그인 실패 시에도 한국어 메시지
      _showError(_getFriendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent, // 에러 느낌 나게 색상 변경
        behavior: SnackBarBehavior.floating, // 좀 더 예쁘게 띄우기
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 24),

                const Text(
                  '환영합니다!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: _inputDecoration('이메일', Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // 🔥 [핵심 3] 비밀번호 필드에 errorText 연결
                      TextField(
                        controller: _passwordController,
                        decoration: _inputDecoration('비밀번호', Icons.lock_outline).copyWith(
                          errorText: _passwordErrorText, // 여기에 에러 메시지가 들어감
                          errorStyle: const TextStyle(color: Colors.redAccent), // 빨간 글씨
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          // 사용자가 다시 타이핑을 시작하면 빨간 에러를 지워줌 (UX 향상)
                          if (_passwordErrorText != null) {
                            setState(() {
                              _passwordErrorText = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      if (_isLoading)
                        const CircularProgressIndicator(color: AppColors.primary)
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('로그인'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _signUp,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('회원가입'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textGrey),
      labelStyle: const TextStyle(color: AppColors.textGrey),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      // errorBorder: 에러 상태일 때 테두리 색상 (빨강)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      floatingLabelStyle: const TextStyle(color: AppColors.primary),
    );
  }
}