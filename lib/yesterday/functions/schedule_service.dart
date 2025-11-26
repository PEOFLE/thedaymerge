import 'dart:convert'; // jsonEncode, jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';

// 저장소에서 사용할 키(Key) 이름
const String schedulesKey = "my_schedules";

// [저장] 새 일정을 리스트에 저장하는 함수
Future<void> saveSchedule(Schedule newSchedule) async {
  final prefs = await SharedPreferences.getInstance();

  // 1. 기존 데이터(JSON 문자열 리스트) 불러오기
  final List<String> currentJsonList = prefs.getStringList(schedulesKey) ?? [];

  // 2. [객체 -> JSON 문자열] 변환
  Map<String, dynamic> mapData = {
    'title': newSchedule.title,
    'startTime': newSchedule.startTime.toIso8601String(),
    'endTime': newSchedule.endTime.toIso8601String(),
    'reminder': newSchedule.reminder,
    'isAI': newSchedule.isAI,
  };

  String newJsonString = jsonEncode(mapData);

  // 3. 중복 확인 후 저장
  if (!currentJsonList.contains(newJsonString)) {
    currentJsonList.add(newJsonString);
    await prefs.setStringList(schedulesKey, currentJsonList);
  }
}

// [불러오기] 저장된 모든 일정을 불러오는 함수
Future<List<Schedule>> loadSchedules() async {
  final prefs = await SharedPreferences.getInstance();

  // 1. 저장된 JSON 문자열 리스트 가져오기
  final List<String> jsonList = prefs.getStringList(schedulesKey) ?? [];

  // 2. [JSON 문자열 -> 객체] 변환
  List<Schedule> scheduleList = jsonList.map((jsonString) {
    Map<String, dynamic> mapData = jsonDecode(jsonString);

    return Schedule(
      title: mapData['title'],
      startTime: DateTime.parse(mapData['startTime']),
      endTime: DateTime.parse(mapData['endTime']),
      reminder: mapData['reminder'],
      isAI: mapData['isAI'] ?? false,
    );
  }).toList();

  return scheduleList;
}

// [삭제] 특정 일정을 삭제하는 함수
Future<void> deleteSchedule(Schedule scheduleToDelete) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> currentJsonList = prefs.getStringList(schedulesKey) ?? [];

  // 1. 삭제하려는 객체를 JSON 문자열로 똑같이 변환
  Map<String, dynamic> mapData = {
    'title': scheduleToDelete.title,
    'startTime': scheduleToDelete.startTime.toIso8601String(),
    'endTime': scheduleToDelete.endTime.toIso8601String(),
    'reminder': scheduleToDelete.reminder,
    'isAI': scheduleToDelete.isAI,
  };
  String targetJsonString = jsonEncode(mapData);

  // 2. 리스트에서 제거
  currentJsonList.remove(targetJsonString);

  // 3. 저장
  await prefs.setStringList(schedulesKey, currentJsonList);
}