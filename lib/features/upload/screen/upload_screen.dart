import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 모델 & 서비스 import
import '../../../models/schedule.dart'; // 🔥 Schedule 모델 추가
import '../../../functions/ocr_service.dart';
import '../../../functions/ai_service.dart';
import '../../../functions/cloud_service.dart'; // 🔥 firebase_service 대신 cloud_service 사용
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
      _showErrorDialog("알 수 없는 오류가 발생했습니다: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // 📝 AI가 준 문자열을 분석해서 Firebase에 저장하는 함수
  Future<void> _parseAndSaveSchedule(String aiResult) async {
    try {
      // 예: "2025.12.25,크리스마스 파티" -> 쉼표로 분리
      final parts = aiResult.split(',');
      if (parts.length < 2) {
        throw Exception("AI 응답 형식이 올바르지 않습니다.");
      }

      final dateString = parts[0].trim(); // 2025.12.25
      final title = parts[1].trim();      // 크리스마스 파티

      // 날짜 파싱
      final date = DateFormat('yyyy.MM.dd').parse(dateString);

      // 시간은 임의 설정 (오전 9시 ~ 10시)
      final startTime = DateTime(date.year, date.month, date.day, 9, 0);
      final endTime = DateTime(date.year, date.month, date.day, 10, 0);

      // 현재 로그인한 유저 ID 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("로그인이 필요합니다.");
        return;
      }

      // 🔥 [핵심 수정] Map 대신 Schedule 객체 생성
      final newSchedule = Schedule(
        title: title,
        startTime: startTime,
        endTime: endTime,
        reminder: 'AI 자동 생성',
        isAI: true,
        isExample: false,
      );

      // 4. Firebase Firestore에 저장 (cloud_service.dart 함수 사용)
      // 팀원 코드가 List<Schedule>을 받도록 수정되었으므로 리스트에 담아 전달
      await saveCalendarEventsToCloud(
        userId: user.uid,
        eventList: [newSchedule], // parameter 이름: eventList
      );

      // 5. 성공 알림
      if (!mounted) return;
      _showSuccessDialog(title, dateString);

    } catch (e) {
      _showErrorDialog("일정 생성 중 오류가 발생했습니다.\n($e)");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("오류"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("확인"),
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