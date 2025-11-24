import 'dart:convert';
import 'package:http/http.dart' as http;

// ==========================================
// [설정]
// ==========================================
const String apiUrl = 'https://clovastudio.stream.ntruss.com/v3/tasks/oi5sjiig/chat-completions';
const String apiKey = 'api'; // ★★★ 여기에 API 키 입력 ★★★,
// ==========================================


Future<String> getScheduleFromAI(String text) async {

  // 1. 디버깅 코드 (입력값 검사)
  if (text.trim().isEmpty || text == "텍스트를 찾지 못했습니다." || text.startsWith("OCR 오류")) {
    return "AI 분석 중지: OCR에서 유효한 텍스트를 받지 못했습니다.";
  }

  // 2. 디버깅 코드 (콘솔 출력)
  print("==========================================");
  print("[AI 서비스] 네이버로 전송하는 OCR 텍스트 원본:");
  print(text);
  print("==========================================");


  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-NCP-CLOVASTUDIO-REQUEST-ID': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      // 단순 문자열(String) 구조 유지
      body: jsonEncode({
        "messages": [
          {
            "role": "system",
            "content": [
              {
                "type": "text",
                "text" : "너는 일정 추출 전문 AI야. 사용자의 입력에서 날짜와 이벤트를 추출해서 'YYYY.MM.DD,카테고리' 형식으로만 답변해."
              }
            ]
          },
          {
            "role": "user",
            "content": [
            {
              "type": "text",
              "text": text // OCR 텍스트
            }
          ]
          }
        ],
        "topP": 0.8,
        "topK": 0,
        "maxTokens": 256,
        "temperature": 0.0,
        "repeatPenalty": 1.0,
        "includeAiFilters": true
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(responseBody);

      if (data['result'] == null) {
        return "오류: result가 null입니다. (API Body 구조 확인 필요)\n$responseBody";
      }

      if (data['status']['code'] == '20000') {
        return data['result']['message']['content'];
      } else {
        return "네이버 오류: ${data['status']['message']}";
      }
    } else {
      return "서버 통신 실패 (${response.statusCode}): ${utf8.decode(response.bodyBytes)}";
    }
  } catch (e) {
    return "AI 서비스 오류: $e";
  }
}