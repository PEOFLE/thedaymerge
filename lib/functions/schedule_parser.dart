import 'package:intl/intl.dart';
import '../models/schedule.dart';

/// 문자열을 분석하여 Schedule 객체로 변환하는 도구
/// 입력 예시: "2025.12.25,크리스마스 파티"
Schedule parseAiResultToSchedule(String aiResult) {
  try {
    // 1. 콤마(,)를 기준으로 날짜와 제목을 나눕니다.
    List<String> parts = aiResult.split(',');

    if (parts.isEmpty) {
      throw Exception("데이터 형식이 올바르지 않습니다.");
    }

    String datePart = parts[0].trim(); // 예: "2025.12.25"
    String titlePart = parts.length > 1 ? parts[1].trim() : "새로운 일정"; // 제목이 없으면 기본값

    // 2. 날짜 포맷 통일 (하이픈(-)을 점(.)으로 변경하여 처리)
    //    AI가 가끔 "2025-12-25"로 줄 수도 있기 때문입니다.
    datePart = datePart.replaceAll('-', '.');

    // 3. 문자열을 DateTime 객체로 변환
    DateTime date = DateFormat('yyyy.MM.dd').parse(datePart);

    // 4. Schedule 객체 생성 및 반환
    //    시간은 AI가 알려주지 않으므로, 기본값(09:00 ~ 10:00)으로 설정합니다.
    return Schedule(
      title: titlePart,
      startTime: DateTime(date.year, date.month, date.day, 9, 0),
      endTime: DateTime(date.year, date.month, date.day, 10, 0),
      reminder: "10분 전",
      isAI: true, // AI가 만든 일정임을 표시
    );

  } catch (e) {
    // 파싱 중 에러가 나면(날짜 형식이 이상하거나 등) 호출한 곳으로 에러를 던집니다.
    throw Exception("데이터 변환 실패: $e");
  }
}