import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. 시간대 초기화
    tz.initializeTimeZones();
    // 한국 시간대('Asia/Seoul')를 기본으로 설정!
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // 2. 안드로이드 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // 기본 앱 아이콘 사용

    // 3. iOS 설정
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // 4. 통합 설정
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // 5. 권한 요청 함수
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // Android 13 이상 알림 권한 요청
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  // 🔔 알림 예약 함수
  Future<void> scheduleNotification({
    required int id, // 알림 고유 ID
    required String title,
    required DateTime scheduledTime,
  }) async {
    // 현재 시간보다 이전이면 알림 예약 불가 (바로 종료)
    if (scheduledTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '일정 알림', // 알림 제목
      '$title 일정이 곧 시작됩니다!', // 알림 내용
      tz.TZDateTime.from(scheduledTime, tz.local), // 시간대 적용
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_channel', // 채널 ID
          '일정 알림', // 채널 이름
          channelDescription: '일정 시작 전 알림을 보냅니다.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true, // 앱이 켜져있을 때도 알림 표시
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🗑️ 알림 취소 함수 (일정 삭제 시 사용)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}