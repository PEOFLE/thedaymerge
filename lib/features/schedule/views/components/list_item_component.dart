import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';
import 'package:thedaymerge/features/schedule/viewmodels/list_item_viewmodel.dart';

class ListItemComponent extends StatelessWidget {
  final ScheduleModel schedule;

  const ListItemComponent({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // 각 리스트 아이템에 독립적인 ViewModel을 제공
    return ChangeNotifierProvider(
      create: (_) => ListItemViewModel(schedule),
      child: Consumer<ListItemViewModel>(
        builder: (context, viewModel, child) {
          // UI는 ViewModel의 데이터를 사용해 그려지기만 함
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
                          if (viewModel.schedule.isAI) ...[
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
                              viewModel.schedule.scheduleName,
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
                        viewModel.timeString, // ViewModel의 포맷팅된 시간 문자열 사용
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
        },
      ),
    );
  }
}
