import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/auth/viewmodels/profile_viewmodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(context.read<AuthViewModel>()),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColor.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColor.backgroundColor,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                "AI 일정 관리",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstNumber.kHeaderFontSize),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
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
                        _buildProfileItem("이메일", viewModel.userEmail),
                        _buildProfileItem("이름", viewModel.userName),
                        _buildProfileItem("가입일", viewModel.joinDateString, isLast: true),
                      ],
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
        },
      ),
    );
  }

  Widget _buildProfileItem(String label, String? value, {bool isLast = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppConstNumber.kDefaultPadding),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppConstNumber.kBodyFontSize,
              color: AppColor.textGrey,
            ),
          ),
          const SizedBox(height: AppConstNumber.kSmallPadding),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppConstNumber.kTitleFontSize,
              fontWeight: FontWeight.w500,
              color: AppColor.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
