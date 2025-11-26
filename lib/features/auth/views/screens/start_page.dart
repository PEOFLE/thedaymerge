import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/auth/viewmodels/start_viewmodel.dart';

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
                    Container(
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
                                borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColor.textGrey),
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
                                borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColor.textGrey),
                            ),
                          ),
                          const SizedBox(height: AppConstNumber.kDefaultPadding),
                          if (viewModel.isLoading)
                            const CircularProgressIndicator(color: AppColor.primaryColor)
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              height: AppConstNumber.kButtonHeight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final error = await viewModel.login();
                                  if (error != null && context.mounted) {
                                    _showErrorSnackBar(context, error);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "로그인",
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: AppConstNumber.kTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstNumber.kMediumPadding),
                            SizedBox(
                              width: double.infinity,
                              height: AppConstNumber.kButtonHeight,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final error = await viewModel.signUp();
                                  if (error != null && context.mounted) {
                                    _showErrorSnackBar(context, error);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColor.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                                  ),
                                ),
                                child: const Text(
                                  "회원가입",
                                  style: TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: AppConstNumber.kTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          );
        },
      ),
    );
  }
}
