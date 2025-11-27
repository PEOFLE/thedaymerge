import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

import 'package:thedaymerge/features/schedule/views/components/page_header.dart';
import 'package:thedaymerge/features/main_navigation/views/components/main_app_bar.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/schedule/views/components/image_upload_box.dart';
import 'package:thedaymerge/features/schedule/views/components/tips_section.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final viewModel = context.read<ScheduleViewModel>();
    final result = await viewModel.pickAndAnalyzeImage();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: result.startsWith("일정이 등록되었습니다") 
            ? AppColor.primaryColor 
            : AppColor.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = context.select((ScheduleViewModel vm) => vm.isAnalyzing);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: const MainAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstNumber.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [수정] PageHeader 컴포넌트 사용
            const PageHeader(
              title: "스크린샷 업로드",
              subtitle: "일정이 포함된 스크린샷을 업로드하면 AI가 자동으로 일정을 생성합니다.",
            ),
            const SizedBox(height: AppConstNumber.kLargePadding),
            
            // [수정] ImageUploadBox 컴포넌트 사용
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
