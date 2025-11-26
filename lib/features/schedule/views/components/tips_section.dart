import 'package:flutter/material.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';

/// UploadPage에서 사용되는 팁 섹션 공통 컴포넌트
class TipsSection extends StatelessWidget {
  const TipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  /// 팁 한 줄을 구성하는 내부 위젯
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
