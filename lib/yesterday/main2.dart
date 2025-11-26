import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:thedaymerge/yesterday/features/main_navigation/screen/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await initializeDateFormatting();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    // 초기화 실패 시 에러 화면 표시
    debugPrint("Initialization Error: $e");
    debugPrint(stackTrace.toString());
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "앱 초기화 중 오류가 발생했습니다.\n\n$e",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 일정 관리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // AppColor를 사용하여 전체 테마 적용
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryColor,
          primary: AppColor.primaryColor,
          background: AppColor.backgroundColor,
        ),
        scaffoldBackgroundColor: AppColor.backgroundColor,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.backgroundColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColor.textBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColor.textBlack),
        ),
      ),
      // 앱이 시작되면 AuthGate가 로그인 여부를 판단합니다.
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
        // 1. 로딩 중일 때
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            ),
          );
        }

        // 2. 로그인이 되어 있다면? -> 메인 화면(캘린더)으로 이동!
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // 3. 로그인이 안 되어 있다면? -> 로그인 페이지 보여줌
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

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final pw = _passwordController.text.trim();
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pw);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공! 환영합니다.')));

    } on FirebaseAuthException catch (e) {
      _showError('회원가입 실패: ${e.message}');
    } catch (e) {
      _showError('오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final pw = _passwordController.text.trim();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pw);

      // 로그인 성공 시 AuthGate가 감지하여 자동으로 화면을 전환합니다.
    } on FirebaseAuthException {
      _showError('로그인 실패: 아이디나 비밀번호를 확인해주세요.');
    } catch (e) {
      _showError('오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColor.textBlack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 AppBar 제거 및 SafeArea 적용
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 64, color: AppColor.primaryColor),
                const SizedBox(height: 24),
                const Text(
                  '다시 오신 것을 환영합니다!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColor.white,
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
                      TextField(
                        controller: _passwordController,
                        decoration: _inputDecoration('비밀번호', Icons.lock_outline),
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),

                      if (_isLoading)
                        const CircularProgressIndicator(color: AppColor.primaryColor)
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
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
                              foregroundColor: AppColor.primaryColor,
                              side: const BorderSide(color: AppColor.primaryColor),
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
      prefixIcon: Icon(icon, color: AppColor.textGrey),
      labelStyle: const TextStyle(color: AppColor.textGrey),
      filled: true,
      fillColor: AppColor.backgroundColor,
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
        borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5),
      ),
      floatingLabelStyle: const TextStyle(color: AppColor.primaryColor),
    );
  }
}
