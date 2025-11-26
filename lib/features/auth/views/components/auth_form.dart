import 'package:flutter/material.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

/// 이메일/비밀번호 입력 필드와 로그인/회원가입 버튼을 포함하는 폼 위젯
class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstNumber.kDefaultPadding),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(AppConstNumber.kLargeRadius),
      ),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "이메일",
              filled: true,
              fillColor: AppColor.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.email_outlined, color: AppColor.textGrey),
            ),
          ),
          const SizedBox(height: AppConstNumber.kMediumPadding),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "비밀번호",
              filled: true,
              fillColor: AppColor.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColor.textGrey),
            ),
          ),
          const SizedBox(height: AppConstNumber.kDefaultPadding),
          if (isLoading)
            const CircularProgressIndicator(color: AppColor.primaryColor)
          else
            Column(
              children: [
                _buildAuthButton(
                  text: "로그인",
                  onPressed: onLogin,
                  isPrimary: true,
                ),
                const SizedBox(height: AppConstNumber.kMediumPadding),
                _buildAuthButton(
                  text: "회원가입",
                  onPressed: onSignUp,
                  isPrimary: false,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 로그인/회원가입 버튼을 생성하는 내부 위젯
  Widget _buildAuthButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppConstNumber.kButtonHeight,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                ),
                elevation: 0,
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColor.white,
                  fontSize: AppConstNumber.kTitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColor.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: AppConstNumber.kTitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
