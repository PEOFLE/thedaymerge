import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/auth/views/screens/profile_page.dart';
import 'package:thedaymerge/features/auth/views/screens/start_page.dart';
import 'package:thedaymerge/features/main_navigation/views/screens/main_navigation_screen.dart';
import 'package:thedaymerge/features/schedule/views/screens/default_home_page.dart';
import 'package:thedaymerge/features/schedule/views/screens/upload_page.dart';

/// 도라에몽 어디로든 문 마냥 라우터 설정하는 것들.
GoRouter createRouter(BuildContext context) {

  ///로 그인 , 로그아웃등의 상태변화가 일어나면 페이지가 바껴야하잖음
  /// 그래서 이렇게 auth 상태변화를 감지하는 구문을 쓰는것임
  final authViewModel = context.read<AuthViewModel>();

  return GoRouter(

    ///초기 화면은 /(루트)로 함니다
    initialLocation: '/',

    /// TODO(@seonghyeon) : 뭔지 모르겠음
    refreshListenable: authViewModel,

    redirect: (context, state) {
      final isLoggedIn = authViewModel.user != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [

      /// "/login"으로 가라는 말은 StartPage()로 가라는 말입니다 ~
      GoRoute(
        path: '/login',
        builder: (context, state) => const StartPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DefaultHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/upload',
                builder: (context, state) => const UploadPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
