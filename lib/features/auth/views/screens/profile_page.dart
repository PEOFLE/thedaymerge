import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/main_navigation/views/components/main_app_bar.dart';
import 'package:thedaymerge/features/auth/views/components/profile_info_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // [수정] 전역 AuthViewModel을 직접 사용
    final viewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstNumber.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstNumber.kLargeRadius),
            const Text(
              "프로필",
              style: TextStyle(
                fontSize: AppConstNumber.kPageTitleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack,
              ),
            ),
            const SizedBox(height: AppConstNumber.kLargeRadius),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstNumber.kDefaultPadding),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(AppConstNumber.kLargeRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor,
                    blurRadius: AppConstNumber.kShadowBlurRadius,
                    offset: const Offset(0, AppConstNumber.kShadowOffsetY),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileInfoItem(label: "이메일", value: viewModel.userEmail),
                  const SizedBox(height: AppConstNumber.kDefaultPadding),
                  ProfileInfoItem(label: "이름", value: viewModel.userName),
                  const SizedBox(height: AppConstNumber.kDefaultPadding),
                  ProfileInfoItem(label: "가입일", value: viewModel.joinDateString),
                ].where((widget) => widget is! SizedBox || (widget.height != AppConstNumber.kDefaultPadding && widget.height != 0)).toList(),
              ),
            ),
            const SizedBox(height: AppConstNumber.kXLargePadding),
            SizedBox(
              width: double.infinity,
              height: AppConstNumber.kButtonHeight,
              child: ElevatedButton(
                onPressed: viewModel.logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "로그아웃",
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: AppConstNumber.kTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
