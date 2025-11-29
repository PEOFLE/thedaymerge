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
import '../../../functions/schedule_parser.dart'; // [중요] 파서 import 확인!
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
    if (kIsWeb) {
      _showErrorDialog("모바일 환경에서 실행해주세요! 📱");
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

      // 2. AI에게 일정 분석 요청 (문자열 받기)
      final String aiResult = await getScheduleFromAI(extractedText);

      if (aiResult.startsWith("AI 서비스 오류") || aiResult.startsWith("오류")) {
        _showErrorDialog("AI 분석에 실패했습니다.\n$aiResult");
        return;
      }

      // 3. AI 결과 파싱 및 저장
      await _parseAndSaveSchedule(aiResult);

    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("Unsupported operation")) {
        errorMessage = "이 기기에서는 지원하지 않는 기능입니다.";
      }
      _showErrorDialog("오류가 발생했습니다.\n\n$errorMessage");
      print("🔍 상세 에러 로그: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // 📝 [핵심 수정] 파서 함수를 호출하여 처리하도록 변경
  Future<void> _parseAndSaveSchedule(String aiResult) async {
    try {
      // 1. 파서 함수 호출!
      final Schedule newSchedule = parseAiResultToSchedule(aiResult);

      // 2. 파서가 에러 스케줄을 반환했는지 확인
      if (newSchedule.reminder == "오류") {
        throw FormatException("AI가 날짜를 인식하지 못했습니다.");
      }

      // 3. 유저 확인 및 저장
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("로그인이 필요합니다. 다시 로그인해주세요.");
        return;
      }

      // 저장
      await saveCalendarEventsToCloud(
        userId: user.uid,
        eventList: [newSchedule],
      );

      if (!mounted) return;

      // 성공 메시지
      _showSuccessDialog(
          newSchedule.title,
          DateFormat('yyyy년 M월 d일 HH:mm').format(newSchedule.startTime)
      );

    } catch (e) {
      print("❌ [UploadScreen] 저장 실패: $e");
      _showErrorDialog(_getFriendlyErrorMessage(e));
    }
  }

  String _getFriendlyErrorMessage(dynamic error) {
    String msg = error.toString();
    if (msg.contains("AI가 날짜를 인식하지 못했습니다")) return "날짜 정보를 찾을 수 없습니다.\n이미지를 다시 확인해주세요.";
    if (msg.contains("SocketException")) return "인터넷 연결을 확인해주세요.";
    return "일정 생성 중 문제가 발생했습니다.\n($msg)";
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
            Text("알림", style: TextStyle(fontWeight: FontWeight.bold)),
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
            Text("등록 성공!"),
          ],
        ),
        content: Text("'$title'\n$date\n\n캘린더에 등록되었습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
              Text("AI가 일정을 분석 중입니다..."),
              SizedBox(height: 8),
              Text("잠시만 기다려 주세요!", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
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
                '일정이 포함된 이미지를 올리면 AI가 분석하여 캘린더에 등록합니다.',
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
                          '터치하여 이미지 업로드',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}