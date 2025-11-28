import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/auth/views/screens/profile_page.dart';
import 'package:thedaymerge/features/auth/views/screens/start_page.dart';
import 'package:thedaymerge/features/main_navigation/views/screens/main_navigation_screen.dart';
import 'package:thedaymerge/features/schedule/views/screens/default_home_page.dart';
import 'package:thedaymerge/features/schedule/views/screens/upload_page.dart';

/// GoRouter 객체를 생성하여 반환하는 함수입니다.
/// main.dart 등에서 호출하여 앱의 라우터 설정을 담당합니다.
GoRouter createRouter(BuildContext context) {

  /// Provider를 통해 AuthViewModel(로그인 상태 관리자)을 가져옵니다.
  /// read를 쓰는 이유는 여기서 상태를 '구독(watch)'해서 화면을 다시 그리는 게 아니라,
  /// 단지 객체를 참조해서 라우터 설정에 넘겨주기 위함입니다.
  final authViewModel = context.read<AuthViewModel>();

  return GoRouter(

    /// 앱이 처음 실행될 때 시작할 경로입니다. (루트 경로 = 홈 화면)
    initialLocation: '/',

    /// [중요] refreshListenable 설명
    /// 질문하신 TODO 부분입니다.
    /// 이 속성은 "누구를 감시하다가, 그 친구가 변하면 라우팅을 다시 검사(refresh)할까요?"라고 묻는 것입니다.
    /// 즉, authViewModel에서 notifyListeners()가 호출될 때마다(로그인/로그아웃 시),
    /// 아래의 redirect 로직이 자동으로 다시 실행됩니다.
    refreshListenable: authViewModel,

    /// [중요] redirect 설명
    /// 페이지 이동이 일어날 때마다 "검문소" 역할을 합니다.
    /// 현재 유저의 상태를 보고 페이지를 강제로 이동시킬지 결정합니다.
    redirect: (context, state) {
      // 1. 현재 로그인되어 있는지 확인 (user 객체가 있으면 로그인 된 것)
      final isLoggedIn = authViewModel.user != null;

      // 2. 현재 유저가 이동하려는 곳이 '/login' 페이지인지 확인
      final isLoggingIn = state.uri.toString() == '/login';

      // [케이스 1] 로그인을 안 했는데, 로그인 페이지가 아닌 곳(홈, 프로필 등)을 가려고 할 때
      // -> 강제로 로그인 페이지('/login')로 쫓아냅니다.
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // [케이스 2] 이미 로그인을 했는데, 굳이 로그인 페이지('/login')에 있을 때
      // -> 홈 화면('/')으로 보내버립니다.
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      // [케이스 3] 그 외의 경우 (정상적인 접근)
      // -> null을 리턴하면 원래 가려던 곳으로 가게 둡니다.
      return null;
    },

    /// 실제 경로(Route)들을 정의하는 배열입니다.
    routes: [

      /// 1. 로그인 페이지 라우트
      /// path: '/login'으로 오면 StartPage를 보여줍니다.
      GoRoute(
        path: '/login',
        builder: (context, state) => const StartPage(),
      ),

      /// 2. 하단 탭바(Bottom Navigation)를 위한 쉘 라우트
      /// StatefulShellRoute를 쓰면 탭을 이동해도 각 탭의 상태(스크롤 위치, 입력 값 등)가 유지됩니다.
      StatefulShellRoute.indexedStack(
        // navigationShell은 현재 어떤 탭이 선택되었는지 등을 관리하는 객체입니다.
        // 이걸 MainNavigationScreen에 넘겨서 BottomNavigationBar와 연결합니다.
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },

        // 각각의 탭(Branch)을 정의합니다.
        branches: [
          // 첫 번째 탭 (홈)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DefaultHomePage(),
              ),
            ],
          ),

          // 두 번째 탭 (업로드)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/upload',
                builder: (context, state) => const UploadPage(),
              ),
            ],
          ),

          // 세 번째 탭 (프로필)
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
