import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/schedule/viewmodels/upload_viewmodel.dart';

/// 비즈니스 로직이 분리되었으므로 StatelessWidget으로 전환
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  // 이미지 선택 및 분석 로직을 ViewModel에 위임
  Future<void> _pickImage(BuildContext context) async {
    final uploadViewModel = context.read<UploadViewModel>();
    final result = await uploadViewModel.pickAndAnalyzeImage();

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
    // UploadViewModel을 이 위젯 내에서 로컬로 제공
    return ChangeNotifierProvider(
      create: (context) => UploadViewModel(context.read<ScheduleViewModel>()),
      builder: (context, child) {
        // isAnalyzing 상태는 ScheduleViewModel에서 계속 관찰
        final isAnalyzing = context.select((ScheduleViewModel vm) => vm.isAnalyzing);

        return Scaffold(
          backgroundColor: AppColor.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColor.backgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text(
              "AI 일정 관리",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConstNumber.kHeaderFontSize),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstNumber.kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstNumber.kLargeRadius),
                const Text(
                  "스크린샷 업로드",
                  style: TextStyle(
                    fontSize: AppConstNumber.kPageTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                const SizedBox(height: AppConstNumber.kSmallPadding),
                const Text(
                  "일정이 포함된 스크린샷을 업로드하면 AI가 자동으로 일정을 생성합니다.",
                  style: TextStyle(
                    fontSize: AppConstNumber.kBodyFontSize,
                    color: AppColor.textGrey,
                  ),
                ),
                const SizedBox(height: AppConstNumber.kLargePadding),
                GestureDetector(
                  onTap: isAnalyzing ? null : () => _pickImage(context),
                  child: DottedBorder(
                    color: AppColor.primaryColor.withOpacity(0.5),
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(AppConstNumber.kDefaultRadius),
                    child: Container(
                      width: double.infinity,
                      height: AppConstNumber.kUploadBoxHeight,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
                      ),
                      child: isAnalyzing 
                          ? const Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_rounded, 
                                  size: AppConstNumber.kIconSizeM, 
                                  color: AppColor.primaryColor.withOpacity(0.8)
                                ),
                                const SizedBox(height: AppConstNumber.kMediumPadding),
                                const Text(
                                  "클릭하여 이미지 선택",
                                  style: TextStyle(
                                    fontSize: AppConstNumber.kTitleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.textBlack,
                                  ),
                                ),
                                const SizedBox(height: AppConstNumber.kSmallPadding),
                                const Text(
                                  "PNG, JPG, JPEG 파일을 지원합니다",
                                  style: TextStyle(
                                    fontSize: AppConstNumber.kSmallFontSize,
                                    color: AppColor.textGrey,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstNumber.kXLargePadding),
                Row(
                  children: const [
                    Text("💡", style: TextStyle(fontSize: AppConstNumber.kHeaderFontSize)),
                    SizedBox(width: AppConstNumber.kSmallPadding),
                    Text(
                      "팁",
                      style: TextStyle(
                        fontSize: AppConstNumber.kHeaderFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textBlack,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstNumber.kMediumPadding),
                _buildTipText("이메일, 메시지, 카카오톡 등의 스크린샷을 업로드하세요."),
                _buildTipText("날짜, 시간, 장소가 명확하게 보이는 이미지가 좋습니다."),
                _buildTipText("AI가 텍스트를 인식하여 자동으로 일정을 생성합니다."),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstNumber.kSmallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: AppColor.textGrey)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppConstNumber.kBodyFontSize,
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
