import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';

/// ListItemComponent는 이제 상태를 갖지 않는 순수한 UI 위젯입니다.
class ListItemComponent extends StatelessWidget {
  final ScheduleModel schedule;

  const ListItemComponent({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // [수정] 전역 ScheduleViewModel의 포매팅 메서드를 사용
    final viewModel = context.read<ScheduleViewModel>();
    final timeString = viewModel.formatTimeString(schedule);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstNumber.kSmallPadding, horizontal: AppConstNumber.kLargeRadius),
      padding: const EdgeInsets.all(AppConstNumber.kMediumPadding),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor,
            blurRadius: AppConstNumber.kSmallRadius,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppConstNumber.kListItemVerticalBarWidth,
            height: AppConstNumber.kIconSizeM,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(AppConstNumber.kXSmallRadius),
            ),
          ),
          const SizedBox(width: AppConstNumber.kDefaultRadius),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (schedule.isAI) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.aiTagBackgroundColor,
                          borderRadius: BorderRadius.circular(AppConstNumber.kSmallRadius),
                        ),
                        child: const Text(
                          "AI",
                          style: TextStyle(
                            fontSize: AppConstNumber.kXSmallFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColor.aiTagTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstNumber.kSmallPadding),
                    ],
                    Expanded(
                      child: Text(
                        schedule.scheduleName,
                        style: const TextStyle(
                          fontSize: AppConstNumber.kTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstNumber.kXSmallPadding),
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: AppConstNumber.kBodyFontSize,
                    color: AppColor.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
