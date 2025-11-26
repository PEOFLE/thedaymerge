import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/features/schedule/views/screens/default_home_page.dart';
import 'package:thedaymerge/features/auth/views/screens/profile_page.dart';
import 'package:thedaymerge/features/schedule/views/screens/upload_page.dart';
import 'package:thedaymerge/features/main_navigation/viewmodels/navigation_viewmodel.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainNavViewModel>();
    
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: IndexedStack(
        index: viewModel.selectedIndex,
        children: [
          const DefaultHomePage(),
          const UploadPage(), // Placeholder
          const ProfilePage(), // Placeholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.selectedIndex,
        onTap: viewModel.setIndex,
        selectedItemColor: AppColor.primaryColor,
        unselectedItemColor: AppColor.textGrey,
        backgroundColor: Colors.white,
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
      ),
    );
  }
}
