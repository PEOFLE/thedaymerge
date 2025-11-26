import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../cores/app_color.dart';
import '../../viewmodels/schedule_viewmodel.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        
        final viewModel = context.read<ScheduleViewModel>();
        
        // [수정] analyzeImage가 에러 메시지 또는 성공 메시지를 String으로 반환함
        final result = await viewModel.analyzeImage(image.path);
        
        if (!mounted) return;
        
        // 결과 메시지를 스낵바로 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: result.startsWith("일정이 등록되었습니다") 
                ? AppColor.primaryColor 
                : Colors.redAccent, // 성공/실패에 따라 색상 구분
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미지 선택 중 오류: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = context.select((ScheduleViewModel vm) => vm.isAnalyzing);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "AI 일정 관리",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "스크린샷 업로드",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "일정이 포함된 스크린샷을 업로드하면 AI가 자동으로 일정을 생성합니다.",
              style: TextStyle(
                fontSize: 14,
                color: AppColor.textGrey,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: isAnalyzing ? null : _pickImage,
              child: DottedBorder(
                color: AppColor.primaryColor.withOpacity(0.5),
                strokeWidth: 2,
                dashPattern: const [8, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isAnalyzing 
                      ? const Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_rounded, 
                              size: 40, 
                              color: AppColor.primaryColor.withOpacity(0.8)
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "클릭하여 이미지 선택",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColor.textBlack,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "PNG, JPG, JPEG 파일을 지원합니다",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColor.textGrey,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: const [
                Text("💡", style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  "팁",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipText("이메일, 메시지, 카카오톡 등의 스크린샷을 업로드하세요."),
            _buildTipText("날짜, 시간, 장소가 명확하게 보이는 이미지가 좋습니다."),
            _buildTipText("AI가 텍스트를 인식하여 자동으로 일정을 생성합니다."),
          ],
        ),
      ),
    );
  }

  Widget _buildTipText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppColor.textGrey)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColor.textGrey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
