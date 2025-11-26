import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';

class ListItemComponent extends StatelessWidget {
  final ScheduleModel schedule;

  const ListItemComponent({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    String timeString;
    
    bool isSameDay = schedule.startTime.year == schedule.endTime.year &&
        schedule.startTime.month == schedule.endTime.month &&
        schedule.startTime.day == schedule.endTime.day;

    if (isSameDay) {
      final startTime = DateFormat('HH:mm').format(schedule.startTime);
      final endTime = DateFormat('HH:mm').format(schedule.endTime);
      timeString = "$startTime - $endTime";
    } else {
      final start = DateFormat('M/d HH:mm').format(schedule.startTime);
      final end = DateFormat('M/d HH:mm').format(schedule.endTime);
      timeString = "$start - $end";
    }

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
