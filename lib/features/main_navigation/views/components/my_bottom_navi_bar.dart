import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:thedaymerge/cores/app_color.dart';

class MyBottomNaviBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MyBottomNaviBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      selectedItemColor: AppColor.primaryColor,
      unselectedItemColor: AppColor.textGrey,
      backgroundColor: AppColor.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "캘린더",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.upload),
          label: "업로드",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "프로필",
        ),
      ],
    );
  }
}
