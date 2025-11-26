import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 이미지를 받아 텍스트를 반환하는 함수
Future<String> extractTextFromImage(File imageFile) async {
  // 🔍 [로그 1] 함수 시작 및 파일 경로 확인
  print("🔍 [OCR Service] 1. 텍스트 추출 시작. 파일 경로: ${imageFile.path}");
  print("🔍 [OCR Service] 파일 존재 여부: ${await imageFile.exists()}");

  try {
    final inputImage = InputImage.fromFile(imageFile);

    // 🔍 [로그 2] 인식기 초기화
    print("🔍 [OCR Service] 2. TextRecognizer(한국어) 초기화 중...");
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

    // 🔍 [로그 3] 이미지 처리 시작
    print("🔍 [OCR Service] 3. processImage 실행 (분석 중)...");
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    // 🔍 [로그 4] 결과 확인
    print("🔍 [OCR Service] 4. 분석 완료. 텍스트 길이: ${recognizedText.text.length}");

    if (recognizedText.text.isEmpty) {
      print("🔍 [OCR Service] ⚠️ 경고: 인식된 텍스트가 없습니다 (Empty String).");
      return "텍스트를 찾지 못했습니다.";
    }

    print("🔍 [OCR Service] ✅ 성공! 추출된 텍스트(일부): ${recognizedText.text.replaceAll('\n', ' ').substring(0, recognizedText.text.length > 50 ? 50 : recognizedText.text.length)}...");
    return recognizedText.text;

  } catch (e, stackTrace) {
    // 🔍 [로그 5] 치명적 에러 발생 시
    print("🔍 [OCR Service] ❌ 치명적 오류 발생: $e");
    print("🔍 [OCR Service] 스택 트레이스: $stackTrace");
    return "OCR 오류 발생: $e";
  }
}