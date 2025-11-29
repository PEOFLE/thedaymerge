import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

import 'package:thedaymerge/features/schedule/views/components/page_header.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/schedule/views/components/image_upload_box.dart';
import 'package:thedaymerge/features/schedule/views/components/tips_section.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (!context.mounted) return;

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("이미지 선택이 취소되었습니다."),
            backgroundColor: AppColor.textGrey,
          ),
        );
        return;
      }

      final viewModel = context.read<ScheduleViewModel>();
      final result = await viewModel.analyzeImage(image.path);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.startsWith("일정이 등록되었습니다") 
              ? AppColor.primaryColor 
              : AppColor.errorColor,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("오류 발생: $e"),
          backgroundColor: AppColor.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = context.select((ScheduleViewModel vm) => vm.isAnalyzing);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstNumber.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: "스크린샷 업로드",
              subtitle: "일정이 포함된 스크린샷을 업로드하면 AI가 자동으로 일정을 생성합니다.",
            ),
            const SizedBox(height: AppConstNumber.kLargePadding),
            
            ImageUploadBox(
              isAnalyzing: isAnalyzing,
              onTap: () => _pickImage(context),
            ),
            const SizedBox(height: AppConstNumber.kXLargePadding),
            
            const TipsSection(),
          ],
        ),
      ),
    );
  }
}
