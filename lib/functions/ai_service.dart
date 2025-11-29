import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

// [설정]
const String apiUrl = 'https://clovastudio.stream.ntruss.com/v2/tasks/n2bk22se/chat-completions';
String get apiKey => dotenv.env['CLOVA_API_KEY'] ?? '';

Future<String> getScheduleFromAI(String text) async {
  if (text.trim().isEmpty || text.contains("텍스트를 찾지 못했습니다") || text.startsWith("OCR 오류")) {
    return "AI 분석 중지: 유효한 텍스트 없음";
  }

  DateTime now = DateTime.now();

  String dayOfWeek = DateFormat('EEEE').format(now);
  String today = "${DateFormat('yyyy.MM.dd').format(now)} ($dayOfWeek)";

  // 내일 날짜도 요일 포함
  DateTime tmr = now.add(const Duration(days: 1));
  String tomorrow = "${DateFormat('yyyy.MM.dd').format(tmr)} (${DateFormat('EEEE').format(tmr)})";

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-NCP-CLOVASTUDIO-REQUEST-ID': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      body: jsonEncode({
        "messages": [
          {
            "role": "system",
            "content": "너는 일정 추출 AI야. \n"
                "입력에서 '시작시간,종료시간,내용'을 콤마(,)로 구분해 출력해.\n"
                "**기준일(오늘): $today**\n"
                "**내일: $tomorrow**\n"
                "\n"
                "**[제약 사항]**\n"
                "1. 시간 포맷: YYYY.MM.DD.HH.mm (없으면 null)\n"
                "2. **내용 압축**: 문장에서 시간, 장소, 조사(은/는/이/가/에서)를 모두 삭제하고 **핵심 명사(이벤트명)**만 남겨.\n"
                "3. 출력 형식: \"YYYY.MM.DD.HH.mm,YYYY.MM.DD.HH.mm,내용\"\n"
                "4. 오직 결과 데이터 한 줄만 출력해.\n"
                "\n"
                "**[예시]**\n"
                "입력: 내일 오후 2시에 강남역에서 팀 기획 회의 진행합니다.\n"
                "출력: (내일날짜).14.00,null,팀 기획 회의"
          },
          {
            "role": "user",
            "content": text
          }
        ],
        "topP": 0.8,
        "topK": 0,
        "maxTokens": 500,
        "temperature": 0.1, // 창의성 최소화 (포맷 준수 위해)
        "repeatPenalty": 1.0,
        "includeAiFilters": true
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);
      print(data);

      if (data['status']['code'] == '20000') {
        return data['result']['message']['content'];
      } else {
        throw Exception("네이버 API 오류: ${data['status']['message']}");
      }
    } else {
      throw Exception("서버 통신 실패: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("AI 서비스 오류: $e");
  }
}