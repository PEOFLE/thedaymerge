import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../controller/upload_controller.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color hintColor = Colors.grey[600]!;
    final Color primaryColor = Theme.of(context).primaryColor; // 테마색
    final Color lightPinkBg = Colors.pink[50]!.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 일정 관리'),
      ),
      body: SingleChildScrollView( // 스크롤 가능하게
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '스크린샷 업로드',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '일정이 포함된 스크린샷을 업로드하면 AI가 자동으로 일정을 생성합니다.',
              style: TextStyle(color: hintColor, fontSize: 15),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => handleUploadProcess(context),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [8, 4],
                color: Colors.pink[100]!,
                strokeWidth: 2,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightPinkBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, size: 48, color: primaryColor),
                      const SizedBox(height: 16),
                      const Text(
                        '클릭하여 이미지 선택',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PNG, JPG, JPEG 파일을 지원합니다',
                        style: TextStyle(color: hintColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '💡 팁',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '• 이메일, 메시지, 카카오톡 등의 스크린샷을 업로드하세요.\n'
                  '• 날짜, 시간, 장소가 명확하게 보이는 이미지가 좋습니다.\n'
                  '• AI가 텍스트를 인식하여 자동으로 일정을 생성합니다.',
              style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}