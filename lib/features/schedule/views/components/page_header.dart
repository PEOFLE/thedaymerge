import 'package:flutter/material.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

/// 페이지 상단에 제목과 설명을 표시하는 공통 컴포넌트
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstNumber.kLargeRadius),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppConstNumber.kPageTitleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColor.textBlack,
          ),
        ),
        const SizedBox(height: AppConstNumber.kSmallPadding),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: AppConstNumber.kBodyFontSize,
            color: AppColor.textGrey,
          ),
        ),
      ],
    );
  }
}
