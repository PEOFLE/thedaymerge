import 'package:flutter/material.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

/// 앱 전반에서 사용되는 공통 AppBar 위젯
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  
  const MainAppBar({
    super.key,
    this.title = "그날머지?", // 기본 타이틀 설정
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppConstNumber.kHeaderFontSize,
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
