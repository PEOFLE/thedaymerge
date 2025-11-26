import 'package:flutter/material.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

/// 프로필 화면에서 "이메일", "이름" 등 한 항목을 표시하는 재사용 가능한 위젯
class ProfileInfoItem extends StatelessWidget {
  final String label;
  final String? value;

  const ProfileInfoItem({
    super.key,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    // 값이 없으면 아무것도 렌더링하지 않음
    if (value == null || value!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
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
          value!,
          style: const TextStyle(
            fontSize: AppConstNumber.kTitleFontSize,
            fontWeight: FontWeight.w500,
            color: AppColor.textBlack,
          ),
        ),
      ],
    );
  }
}
