import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/schedule_model.dart';
import 'ocr_service.dart';

class ScheduleAiRepository {
  final OcrService _ocrService = OcrService();

  // ==========================================
  // [설정]
  // ==========================================
  static const String apiUrl = 'https://clovastudio.stream.ntruss.com/v3/tasks/oi5sjiig/chat-completions';
  static const String apiKey = ''; // ★★★ 여기에 API 키 입력 ★★★
  // ==========================================

  Future<ScheduleModel?> analyzeImage(String imagePath) async {
    // 0. API Key 확인
    if (apiKey == 'api' || apiKey.isEmpty) {
      throw Exception("API Key가 설정되지 않았습니다. ai_service.dart 파일에서 apiKey를 입력해주세요.");
    }

    // 1. OCR 수행
    final text = await _ocrService.extractTextFromImage(imagePath);
    
    if (text.startsWith("OCR 오류") || text == "텍스트를 찾지 못했습니다.") {
      throw Exception(text);
    }

    // 2. AI 분석
    final aiResult = await _getScheduleFromAI(text);
    if (aiResult.startsWith("오류") || aiResult.startsWith("서버 통신 실패") || aiResult.startsWith("AI 서비스 오류")) {
      throw Exception(aiResult);
    }

    // 3. 파싱 및 모델 생성
    return _parseAiResultToSchedule(aiResult);
  }

  Future<String> _getScheduleFromAI(String text) async {
    if (text.trim().isEmpty) {
      return "AI 분석 중지: 텍스트가 비어있습니다.";
    }

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
                  "text": text
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
          return "오류: result가 null입니다. API 응답을 확인하세요.";
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

  ScheduleModel _parseAiResultToSchedule(String aiResult) {
    try {
      // 1. 콤마(,)를 기준으로 날짜와 제목 분리
      List<String> parts = aiResult.split(',');

      if (parts.isEmpty) {
        throw Exception("데이터 형식이 올바르지 않습니다: $aiResult");
      }

      String datePart = parts[0].trim();
      String titlePart = parts.length > 1 ? parts[1].trim() : "새로운 일정";

      // 2. 날짜 포맷 통일
      datePart = datePart.replaceAll('-', '.');

      // 3. DateTime 변환
      DateTime date = DateFormat('yyyy.MM.dd').parse(datePart);

      // 4. ScheduleModel 생성
      return ScheduleModel(
        id: '', 
        scheduleName: titlePart,
        startTime: DateTime(date.year, date.month, date.day, 9, 0),
        endTime: DateTime(date.year, date.month, date.day, 10, 0),
        isAI: true, // [변경] AI로 생성됨 표시
      );

    } catch (e) {
      throw Exception("데이터 변환 실패($e). AI 응답: $aiResult");
    }
  }
}
