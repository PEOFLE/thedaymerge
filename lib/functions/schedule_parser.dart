import 'package:intl/intl.dart';
import '../models/schedule.dart';

Schedule parseAiResultToSchedule(String aiResult) {
  print("\n========================================");
  print("🔍 [파서 진입] AI 원본 데이터: '$aiResult'");

  try {
    // 1. 콤마 분리
    List<String> parts = aiResult.split(',');
    print("🔍 [파서 분리] 분리된 덩어리 개수: ${parts.length}");

    if (parts.length < 3) {
      print("🚨 [파서 에러] 데이터 덩어리가 3개 미만입니다. (콤마 부족)");
      return _createErrorSchedule("데이터 분석 실패: $aiResult");
    }

    String startStr = parts[0].trim();
    String endStr = parts[1].trim();
    // 제목에 콤마가 포함될 경우를 대비해 뒷부분 합치기
    String title = parts.sublist(2).join(',').trim();

    print("🔍 [파서 추출 값 확인]");
    print("   👉 시작시간 문자열: '$startStr'");
    print("   👉 종료시간 문자열: '$endStr'");
    print("   👉 제목 문자열: '$title'");

    // 2. 날짜 변환 (여기서 에러가 가장 많이 납니다)
    DateTime? startTime = _parseDateDebug(startStr, "시작시간");
    DateTime? endTime = _parseDateDebug(endStr, "종료시간");

    // 3. 빈 값 채우기 로직
    DateTime now = DateTime.now();

    // 로직 처리 로그
    if (startTime != null && endTime != null) {
      if (endTime.isBefore(startTime)) {
        print("⚠️ [로직 보정] 종료 시간이 시작 시간보다 빠름 -> 종료를 +1시간 처리");
        endTime = startTime.add(const Duration(hours: 1));
      }
    } else if (startTime == null && endTime != null) {
      print("ℹ️ [로직 보정] 시작 시간 없음 -> 종료 1시간 전으로 설정");
      startTime = endTime.subtract(const Duration(hours: 1));
    } else if (startTime != null && endTime == null) {
      print("ℹ️ [로직 보정] 종료 시간 없음 -> 시작 1시간 후로 설정");
      endTime = startTime.add(const Duration(hours: 1));
    } else {
      print("ℹ️ [로직 보정] 둘 다 없음 -> 내일 09:00 설정");
      startTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
      endTime = startTime.add(const Duration(hours: 1));
    }

    print("✅ [파서 최종 완료]");
    print("   Title: $title");
    print("   Start: $startTime");
    print("   End  : $endTime");
    print("========================================\n");

    return Schedule(
      title: title,
      startTime: startTime!,
      endTime: endTime!,
      reminder: "10분 전",
      isAI: true,
    );

  } catch (e, stackTrace) {
    print("🚨 [파서 치명적 오류 발생]");
    print("   에러 내용: $e");
    print("   스택 트레이스: $stackTrace");
    return _createErrorSchedule("오류 발생");
  }
}

// [디버깅용] 날짜 변환 함수
DateTime? _parseDateDebug(String dateStr, String label) {
  if (dateStr == 'null' || dateStr.trim().isEmpty) {
    print("   Pass [$label]: 값이 null이거나 비어있음");
    return null;
  }

  try {
    // 특수문자 치환 로그
    String cleanStr = dateStr
        .replaceAll('-', '.')
        .replaceAll(':', '.')
        .replaceAll('/', '.')
        .replaceAll(' ', '.'); // 공백도 점으로

    // 중복 점 제거
    while (cleanStr.contains('..')) {
      cleanStr = cleanStr.replaceAll('..', '.');
    }

    print("   Run [$label] 포맷 변환 시도: '$dateStr' -> '$cleanStr'");

    // 파싱 시도
    DateTime result = DateFormat('yyyy.MM.dd.HH.mm').parse(cleanStr);
    print("   Success [$label]: $result");
    return result;

  } catch (e) {
    print("   🚨 Fail [$label] 파싱 실패!");
    print("      입력값: '$dateStr'");
    print("      에러: $e");
    return null;
  }
}

Schedule _createErrorSchedule(String title) {
  return Schedule(
    title: title,
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 1)),
    reminder: "오류",
    isAI: true,
  );
}