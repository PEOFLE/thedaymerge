import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/features/main_navigation/views/main_navigation_screen.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'screens/start_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthViewModel vm) => vm.user);

    if (user != null) {
      return const MainNavigationScreen();
    } else {
      return const StartPage();
    }
  }
}
