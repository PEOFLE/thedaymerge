import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:thedaymerge/app.dart';
import 'package:thedaymerge/cores/firebase_options.dart';

import 'package:thedaymerge/features/auth/repositories/auth_cloud_service.dart';
import 'package:thedaymerge/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:thedaymerge/features/schedule/repositories/save_and_load/cloud_service.dart';
import 'package:thedaymerge/features/schedule/repositories/ai_and_ocr/ai_service.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/main_navigation/viewmodels/navigation_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ko_KR', null);

  await dotenv.load(fileName: ".env");

  runApp(
    ///Provider : 변하지 않는 도구나 서비스 클래스(값만 바뀌는 느낌)
    ///ChangeNotirfierProvider : 값이 바뀌면 다시 그리라고 알림(notiryListener()호출 시)
    MultiProvider(
      providers: [
        // Auth
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            repository: context.read<AuthRepository>(),
          ),
        ),

        // Navigation
        ChangeNotifierProvider<MainNavViewModel>(
          create: (_) => MainNavViewModel(),
        ),

        // Schedule
        Provider<ScheduleRepository>(
          create: (_) => ScheduleRepository(),
        ),
        Provider<ScheduleAiRepository>(
          create: (_) => ScheduleAiRepository(),
        ),
        ChangeNotifierProvider<ScheduleViewModel>(
          create: (context) => ScheduleViewModel(
            repository: context.read<ScheduleRepository>(),
            aiRepository: context.read<ScheduleAiRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
