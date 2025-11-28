import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/router_config.dart';


/// MaterialApp의 시작점 및 go_router 설정
/// go_router은 페이지 이동을 도와주는 라이브러리임
/// lib/cores/router_config.dart 참고 .
/// 클릭 이벤트에 따라 go_router가 작동해서
/// 해당 페이지로 이동시키는 역할을 하는 것이고 그걸 위해 여기서 선언하는 것임
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  ///라우터 !!!
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {

    ///_router가 널 이라면 새로 만들어야하지만,
    ///_router가 이미 존재한다면 그 놈으로 그냥 서라.
    if (_router == null) {
      _router = createRouter(context);
    } else {
      // 아무것도 안함
    }

    ///본래 MaterialApp인데 라우터 기능을 쓰기 위해서
    ///.router가 붙음
    return MaterialApp.router(

      ///라우터 설정
      routerConfig: _router,

      ///디버그 배너를 보여줄거냐? : 아니
      debugShowCheckedModeBanner: false,

      title: 'The Day Merge',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
        useMaterial3: true,
      ),

      ///어라라, 어느 페이지로 가는지 안적혀있는데용???
      ///-> lib/cores/router_config.dart 에 시작 페이지 어디 갈지 정의되어있음.
    );
  }
}
