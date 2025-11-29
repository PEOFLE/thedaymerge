import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';

/// ListItemComponent는 이제 상태를 갖지 않는 순수한 UI 위젯입니다.
class ListItemComponent extends StatelessWidget {
  final ScheduleModel schedule;

  const ListItemComponent({super.key, required this.schedule});

  String _getAlarmText() {
    if (schedule.alarmTime == null) {
      return "알림없음";
    }
    
    // 알림 시간과 시작 시간의 차이를 계산
    final difference = schedule.startTime.difference(schedule.alarmTime!);
    final minutes = difference.inMinutes;
    
    if (minutes > 0) {
      if (minutes >= 60) {
        return "${minutes ~/ 60}시간 전 알림";
      }
      return "$minutes분 전 알림";
    } else {
      // 혹시라도 알림 시간이 시작 시간과 같거나 늦은 경우 (보통 정시 알림)
      return "정시 알림";
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] 전역 ScheduleViewModel의 포매팅 메서드를 사용
    final viewModel = context.read<ScheduleViewModel>();
    final timeString = viewModel.formatTimeString(schedule);
    final alarmText = _getAlarmText();

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeString,
                      style: const TextStyle(
                        fontSize: AppConstNumber.kBodyFontSize,
                        color: AppColor.textGrey,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          schedule.alarmTime != null ? Icons.notifications_active : Icons.notifications_off,
                          size: 14,
                          color: AppColor.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alarmText,
                          style: const TextStyle(
                            fontSize: AppConstNumber.kSmallFontSize,
                            color: AppColor.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
