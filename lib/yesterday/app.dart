import 'package:flutter/material.dart';
import 'package:thedaymerge/yesterday/features/main_navigation/screen/main_navigation_screen.dart';
import 'package:thedaymerge/yesterday/theme/app_theme.dart'; // 테마 파일 (별도 생성 필요)
import 'package:intl/date_symbol_data_local.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 캘린더 한글화를 위해 초기화
    initializeDateFormatting('ko_KR');

    return MaterialApp(
      title: 'AI 일정 관리',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // lib/theme/app_theme.dart 에서 정의
      home: const MainNavigationScreen(),
    );
  }
}