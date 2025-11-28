import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/features/main_navigation/views/components/main_app_bar.dart';

import 'package:thedaymerge/features/main_navigation/views/components/my_bottom_navi_bar.dart';

class MainNavigationScreen extends StatelessWidget {

  final StatefulNavigationShell navigationShell;


  ///router_config.dart에서 써먹음
  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,

      appBar: MainAppBar(),

      body: navigationShell,

      bottomNavigationBar: MyBottomNaviBar(navigationShell: navigationShell),
    );
  }
}
