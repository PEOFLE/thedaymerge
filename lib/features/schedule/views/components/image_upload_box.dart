import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

/// 이미지 업로드를 위한 점선 박스 UI 컴포넌트
class ImageUploadBox extends StatelessWidget {
  final bool isAnalyzing;
  final VoidCallback? onTap;

  const ImageUploadBox({
    super.key,
    required this.isAnalyzing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: DottedBorder(
        color: AppColor.primaryColor.withAlpha(80),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(AppConstNumber.kDefaultRadius),
        child: Container(
          width: double.infinity,
          height: AppConstNumber.kUploadBoxHeight,
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withAlpha(20),
            borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
          ),
          child: isAnalyzing
              ? const Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
              : _buildUploadPrompt(),
        ),
      ),
    );
  }

  /// "클릭하여 이미지 선택" 프롬프트 UI
  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.upload_rounded,
          size: AppConstNumber.kIconSizeM,
          color: AppColor.primaryColor.withAlpha(80),
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
    );
  }
}
