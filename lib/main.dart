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
//import 'package:thedaymerge/features/main_navigation/viewmodels/navigation_viewmodel.dart';


/// main - app의 시작점
/// 여기서 하는 일 : 파이어베이스 초기화 하기
/// Provider 라는 MVVM아키텍쳐 패턴을 위한 의존성 주입하기
///
void main() async {

  ///가장 처음 앱을 초기화 하기 위한 문장
  WidgetsFlutterBinding.ensureInitialized();

  /// 파이어베이스를 현재 플랫폼(Ios,Android, web 등등 )에 맞게 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ///언어 형식을 한국어로 초기화
  await initializeDateFormatting('ko_KR', null);


  ///apiKey를 깃허브에 올리는것을 막기 위해
  ///.env파일에 저장해놓고 불러옴
  ///.env 파일은 ignore 되어있음
  await dotenv.load(fileName: ".env");


  ///앱을  실행하라는 구문임 (고정)
  runApp(
    ///Provider : 변하지 않는 도구나 서비스 클래스(값만 바뀌는 느낌)
    ///ChangeNotirfierProvider : 값이 바뀌면 다시 그리라고 알림(notiryListener()호출 시)
    ///
    /// Provider가 여러개라 Multi로 감쌈
    MultiProvider(
      providers: [
        /// Auth 상태를 담당하는 애들 (전역적으로 쓸 수 있도록 여기다가 선언)
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            repository: context.read<AuthRepository>(),
          ),
        ),

        /// Schedule 상태를 담당하는 애들 (전역적으로 쓸 수 있도록 여기다가 선언)
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

      ///app.dart의 MyApp을 실행.
      child: const MyApp(),
    ),
  );
}
