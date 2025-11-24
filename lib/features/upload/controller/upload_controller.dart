import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../functions/ocr_service.dart';
import '../../../functions/ai_service.dart';
import '../../../functions/schedule_parser.dart';
import '../../common/widgets/loading_overlay.dart';
import '../widgets/schedule_confirm_dialog.dart';

// [Controller] 이미지 선택 -> 분석 -> 팝업까지의 흐름을 제어함
Future<void> handleUploadProcess(BuildContext context) async {
  // 1. 갤러리에서 이미지 선택
  final picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  // 이미지를 선택하지 않고 취소했을 경우 종료
  if (pickedFile == null) return;

  // 2. 로딩 시작 (화면 터치 방지)
  if (!context.mounted) return;
  LoadingOverlay.show(context);

  try {
    File imageFile = File(pickedFile.path);

    // [Step 1] OCR: 이미지에서 글자 추출
    String ocrText = await extractTextFromImage(imageFile);

    // OCR 실패 시 예외 처리
    if (ocrText.startsWith("OCR 오류") || ocrText.contains("찾지 못했습니다")) {
      throw Exception("이미지에서 글자를 인식할 수 없습니다.");
    }

    // [Step 2] AI: 글자를 분석하여 일정 정보 추출
    String aiResultString = await getScheduleFromAI(ocrText);

    // [Step 3] Parser: 문자열을 Schedule 객체로 변환
    final schedule = parseAiResultToSchedule(aiResultString);

    // 3. 로딩 종료
    if (context.mounted) LoadingOverlay.hide(context);

    // 4. 결과 확인 팝업 띄우기 (위젯 호출)
    if (context.mounted) {
      showScheduleConfirmDialog(context, schedule);
    }

  } catch (e) {
    // 에러 발생 시 처리
    if (context.mounted) {
      LoadingOverlay.hide(context); // 로딩 끄기

      // 에러 메시지 사용자에게 보여주기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류: ${e.toString().replaceAll('Exception: ', '')}")),
      );
    }
  }
}