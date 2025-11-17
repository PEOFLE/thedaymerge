import 'package:shared_preferences/shared_preferences.dart';

// 저장소에서 사용할 키(Key) 이름
const String schedulesKey = "my_schedules";

/// 새 일정을 리스트에 저장하는 함수
Future<void> saveSchedule(String newSchedule) async {
  // 1. SharedPreferences 인스턴스 가져오기
  final prefs = await SharedPreferences.getInstance();

  // 2. 키를 이용해 기존의 일정 목록(문자열 리스트) 불러오기
  //    (만약 저장된 게 없으면 빈 리스트 '[]' 반환)
  final List<String> currentSchedules = prefs.getStringList(schedulesKey) ?? [];

  // 3. 새 일정이 목록에 없다면 추가 (중복 저장 방지)
  if (!currentSchedules.contains(newSchedule)) {
    currentSchedules.add(newSchedule);

    // 4. 새 일정이 추가된 리스트를 다시 저장
    await prefs.setStringList(schedulesKey, currentSchedules);
  }
}

/// 저장된 모든 일정 리스트를 불러오는 함수
Future<List<String>> loadSchedules() async {
  final prefs = await SharedPreferences.getInstance();

  // 저장된 리스트를 반환 (없으면 빈 리스트 '[]' 반환)
  return prefs.getStringList(schedulesKey) ?? [];
}

Future<void> deleteSchedule(String scheduleToDelete) async {
  // 1. 저장소 인스턴스 가져오기
  final prefs = await SharedPreferences.getInstance();

  // 2. 현재 목록 불러오기
  final List<String> currentSchedules = prefs.getStringList(schedulesKey) ?? [];

  // 3. 목록에서 해당 일정 제거하기
  currentSchedules.remove(scheduleToDelete);

  // 4. 변경된 목록을 다시 저장하기
  await prefs.setStringList(schedulesKey, currentSchedules);
}