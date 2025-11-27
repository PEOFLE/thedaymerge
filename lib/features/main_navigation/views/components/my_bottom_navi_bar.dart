import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:thedaymerge/cores/app_color.dart';

import 'package:thedaymerge/features/main_navigation/viewmodels/navigation_viewmodel.dart';

class MyBottomNaviBar extends StatelessWidget {
  const MyBottomNaviBar({super.key});

  @override
  Widget build(BuildContext context) {

    final viewModel = context.watch<MainNavViewModel>();

    return BottomNavigationBar(
      currentIndex: viewModel.selectedIndex,
      onTap: viewModel.setIndex,
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