import 'package:flutter/material.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/auth/views/components/auth_form.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});


  @override
  Widget build(BuildContext context) {
    // [수정] 전역 AuthViewModel을 직접 사용


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


              ///auth_form.dart의 AuthForm 위젯.
              ///위 파일을 보셈!!!
              AuthForm(),

            ],
          ),
        ),
      ),
    );
  }
}
