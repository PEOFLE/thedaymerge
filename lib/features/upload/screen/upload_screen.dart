import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 모델 & 서비스 import
import '../../../models/schedule.dart';
import '../../../functions/ocr_service.dart';
import '../../../functions/ai_service.dart';
import '../../../functions/cloud_service.dart';
import '../../../theme/app_colors.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isAnalyzing = false; // 분석 중 로딩 상태

  // 📸 이미지 선택 및 AI 분석 프로세스 함수
  Future<void> _pickAndAnalyzeImage() async {
    // 🔥 [1단계] 웹(Chrome)인지 먼저 확인!
    // 웹에서는 파일 시스템(dart:io)과 OCR이 작동하지 않으므로 미리 막습니다.
    if (kIsWeb) {
      _showErrorDialog(
          "현재 웹(브라우저) 환경에서는\n이미지 분석 기능을 사용할 수 없습니다.\n\n"
              "실제 기기에서 실행해주세요! 📱"
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // 1. OCR로 텍스트 추출
      final File imageFile = File(image.path);
      final String extractedText = await extractTextFromImage(imageFile);

      if (extractedText.startsWith("OCR 오류") || extractedText == "텍스트를 찾지 못했습니다.") {
        _showErrorDialog("글자를 찾을 수 없습니다. 더 선명한 이미지를 사용해주세요.");
        return;
      }

      // 2. AI에게 일정 분석 요청
      final String aiResult = await getScheduleFromAI(extractedText);

      if (aiResult.startsWith("AI 서비스 오류") || aiResult.startsWith("오류")) {
        _showErrorDialog("AI 분석에 실패했습니다.\n$aiResult");
        return;
      }

      // 3. AI 결과 파싱 및 저장
      await _parseAndSaveSchedule(aiResult);

    } catch (e) {
      // 🔥 [2단계] 에러 메시지 예쁘게 다듬기
      String errorMessage = e.toString();

      // 개발자용 에러 메시지가 포함되어 있다면 친절하게 변경
      if (errorMessage.contains("Unsupported operation") || errorMessage.contains("_Namespace")) {
        errorMessage = "이 기기에서는 지원하지 않는 기능입니다.\n모바일 환경에서 실행해주세요.";
      }

      _showErrorDialog("오류가 발생했습니다.\n\n$errorMessage");
      print("🔍 상세 에러 로그: $e"); // 개발자는 로그로 확인
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // 📝 AI 결과를 분석해서 저장하는 함수 (똑똑해진 버전)
  Future<void> _parseAndSaveSchedule(String aiResult) async {
    try {
      // 1. 기본적인 응답 검사
      if (aiResult.contains("실패") || aiResult.contains("오류")) {
        throw FormatException("AI_ANALYSIS_FAILED"); // 사용자 정의 에러 코드
      }

      if (!aiResult.contains(',')) {
        throw FormatException("INVALID_FORMAT");
      }

      final parts = aiResult.split(',');
      // 제목이 없는 경우 방지
      if (parts.length < 2) {
        throw FormatException("INVALID_FORMAT");
      }

      String dateString = parts[0].trim(); // 날짜 부분 (예: 2025/11/14)
      final title = parts.sublist(1).join(',').trim(); // 제목 부분 (쉼표가 제목에 있을 수도 있으니 join)

      // 2. 🔥 [핵심] 날짜 파싱 로직 강화 (숫자만 추출)
      // "2025. 11. 14." -> [2025, 11, 14]
      // "11/14" -> [11, 14]
      final numbers = RegExp(r'\d+').allMatches(dateString)
          .map((m) => int.parse(m.group(0)!))
          .toList();

      DateTime date;
      final now = DateTime.now();

      if (numbers.length == 3) {
        // [연, 월, 일] 다 있는 경우
        date = DateTime(numbers[0], numbers[1], numbers[2]);
      } else if (numbers.length == 2) {
        // [월, 일] 만 있는 경우 -> 현재 연도 혹은 내년으로 추측
        // 만약 지금이 12월인데 1월 일정이면 내년으로 잡는 로직 추가 가능
        int year = now.year;
        if (numbers[0] < now.month) year++; // (선택사항) 과거 달이면 내년으로

        date = DateTime(year, numbers[0], numbers[1]);
      } else {
        // 숫자가 1개거나 없으면 에러
        throw FormatException("DATE_PARSE_ERROR");
      }

      // 3. 시간 설정 (기본값: 오전 9시 ~ 10시)
      // (추후 AI가 시간까지 주면 여기를 수정하면 됩니다)
      final startTime = DateTime(date.year, date.month, date.day, 9, 0);
      final endTime = DateTime(date.year, date.month, date.day, 10, 0);

      // 4. 유저 확인 및 저장
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("로그인이 필요합니다. 다시 로그인해주세요.");
        return;
      }

      final newSchedule = Schedule(
        title: title.isEmpty ? "제목 없는 일정" : title, // 제목 없으면 기본값
        startTime: startTime,
        endTime: endTime,
        reminder: 'AI 자동 생성',
        isAI: true,
        isExample: false,
      );

      // 저장
      await saveCalendarEventsToCloud(
        userId: user.uid,
        eventList: [newSchedule],
      );

      if (!mounted) return;
      _showSuccessDialog(newSchedule.title, DateFormat('yyyy년 M월 d일').format(date));

    } catch (e) {
      print("❌ [UploadScreen] 에러 상세: $e"); // 개발자용 로그
      // 🔥 사용자에게는 예쁜 메시지 보여주기
      _showErrorDialog(_getFriendlyErrorMessage(e));
    }
  }

  // 🗣️ 외계어 에러를 친절한 한글로 바꿔주는 번역기
  String _getFriendlyErrorMessage(dynamic error) {
    String msg = error.toString();

    if (msg.contains("AI_ANALYSIS_FAILED")) {
      return "AI가 이미지를 분석하는 데 실패했습니다.\n다른 이미지를 시도해보세요.";
    }
    if (msg.contains("INVALID_FORMAT") || msg.contains("DATE_PARSE_ERROR")) {
      return "날짜를 정확히 인식하지 못했습니다.\n날짜가 잘 보이는 선명한 이미지를 사용해주세요.";
    }
    if (msg.contains("FormatException")) {
      return "이미지의 글씨가 너무 흐릿하거나\n날짜 형식이 복잡해서 읽을 수 없습니다.";
    }
    if (msg.contains("SocketException") || msg.contains("Network")) {
      return "인터넷 연결이 불안정합니다.\n와이파이 또는 데이터를 확인해주세요.";
    }

    // 그 외 알 수 없는 에러
    return "일정을 생성하는 중 문제가 발생했습니다.\n다시 시도해주세요.";
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 8),
            Text("잠시만요!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("확인", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary),
            SizedBox(width: 8),
            Text("일정 등록 성공!"),
          ],
        ),
        content: Text("'$title' 일정이\n$date 캘린더에 등록되었습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("확인", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 20),
              Text("이미지에서 텍스트를 읽고 있어요..."),
              SizedBox(height: 8),
              Text("잠시만 기다려 주세요!", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // AppBar 삭제 요청 반영 -> SafeArea 적용
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'AI 자동 일정 생성',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '일정이 포함된 이미지를 선택하면 AI가 자동으로 분석하여 캘린더에 등록해줍니다.',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: _pickAndAnalyzeImage,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [8, 4],
                  color: AppColors.primary.withOpacity(0.5),
                  strokeWidth: 2,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.primary),
                        SizedBox(height: 16),
                        Text(
                          '클릭하여 이미지 선택',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text( '💡 팁', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '• 날짜와 일정 내용이 선명하게 보이는 이미지가 좋습니다.\n'
                    '• 카카오톡 대화 캡처, 예약 확정 문자 등을 올려보세요.',
                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}