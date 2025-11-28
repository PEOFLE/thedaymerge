import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';

/// 이메일/비밀번호 입력 필드와 로그인/회원가입 버튼을 포함하는 폼 위젯
class AuthForm extends StatelessWidget {
  const AuthForm({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();

    return Container(
      padding: const EdgeInsets.all(AppConstNumber.kDefaultPadding),

      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(AppConstNumber.kLargeRadius),
      ),

      child: Column(
        children: [
          TextField(
            controller: viewModel.emailController,
            decoration: InputDecoration(
              hintText: "이메일",
              filled: true,
              fillColor: AppColor.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstNumber.kDefaultRadius,
                ),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: AppColor.textGrey,
              ),
            ),
          ),

          const SizedBox(height: AppConstNumber.kMediumPadding),

          TextField(
            controller: viewModel.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "비밀번호",
              filled: true,
              fillColor: AppColor.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstNumber.kDefaultRadius,
                ),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColor.textGrey,
              ),
            ),
          ),

          const SizedBox(height: AppConstNumber.kDefaultPadding),

          if (viewModel.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            )
          else
            Column(
              children: [
                AuthButton(
                  text: "로그인",
                  onPressed: () async {
                    // 1. 함수 실행 결과를 바로 변수(error)에 받음
                    final error = await viewModel.signIn();

                    // 2. error가 null이 아니면(=에러가 있으면) 스낵바 띄움
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error), // 받아온 에러 메시지 그대로 출력
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  isPrimary: true,
                ),
                const SizedBox(height: AppConstNumber.kMediumPadding),
                AuthButton(
                  text: "회원가입",
                  onPressed: () async {
                    // 1. 함수 실행 결과를 바로 변수(error)에 받음
                    final error = await viewModel.signUp();

                    // 2. error가 null이 아니면(=에러가 있으면) 스낵바 띄움
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error), // 받아온 에러 메시지 그대로 출력
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  isPrimary: false,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstNumber.kButtonHeight,
      child: ElevatedButton(
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
      ),
    );
  }
}
