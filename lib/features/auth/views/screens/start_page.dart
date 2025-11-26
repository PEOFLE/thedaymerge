import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/auth/viewmodels/start_viewmodel.dart';
import 'package:thedaymerge/features/auth/views/components/auth_form.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StartViewModel(context.read<AuthViewModel>()),
      child: Consumer<StartViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColor.backgroundColor,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstNumber.kDefaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: AppConstNumber.kIconSizeL,
                      color: AppColor.primaryColor,
                    ),
                    const SizedBox(height: AppConstNumber.kDefaultPadding),
                    const Text(
                      "다시 오신 것을 환영합니다!",
                      style: TextStyle(
                        fontSize: AppConstNumber.kSubHeaderFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack,
                      ),
                    ),
                    const SizedBox(height: AppConstNumber.kLargePadding),
                    
                    // [수정] AuthForm 컴포넌트 사용
                    AuthForm(
                      emailController: viewModel.emailController,
                      passwordController: viewModel.passwordController,
                      isLoading: viewModel.isLoading,
                      onLogin: () async {
                        final error = await viewModel.login();
                        if (error != null && context.mounted) {
                          _showErrorSnackBar(context, error);
                        }
                      },
                      onSignUp: () async {
                        final error = await viewModel.signUp();
                        if (error != null && context.mounted) {
                          _showErrorSnackBar(context, error);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
