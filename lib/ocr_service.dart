import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 이미지를 받아 텍스트를 반환하는 함수 (이미 lowerCamelCase)
Future<String> extractTextFromImage(File imageFile) async {
  try {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    if (recognizedText.text.isEmpty) {
      return "텍스트를 찾지 못했습니다.";
    }
    return recognizedText.text;

  } catch (e) {
    return "OCR 오류 발생: $e";
  }
}