import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/features/main_navigation/views/components/main_app_bar.dart';

import 'package:thedaymerge/features/schedule/views/screens/default_home_page.dart';
import 'package:thedaymerge/features/auth/views/screens/profile_page.dart';
import 'package:thedaymerge/features/schedule/views/screens/upload_page.dart';
import 'package:thedaymerge/features/main_navigation/viewmodels/navigation_viewmodel.dart';
import 'package:thedaymerge/features/main_navigation/views/components/my_bottom_navi_bar.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainNavViewModel>();
    
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,

      appBar: MainAppBar(),

      body: IndexedStack(
        index: viewModel.selectedIndex,
        children: [
          const DefaultHomePage(),
          const UploadPage(), // Placeholder
          const ProfilePage(), // Placeholder
        ],
      ),
      bottomNavigationBar: MyBottomNaviBar(),
    );
  }
}



