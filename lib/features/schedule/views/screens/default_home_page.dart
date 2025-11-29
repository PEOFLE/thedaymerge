import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/schedule/views/components/calendar_component.dart';
import 'package:thedaymerge/features/schedule/views/components/list_item_component.dart';
import 'package:thedaymerge/features/schedule/views/components/add_schedule_bottom_sheet.dart';

class DefaultHomePage extends StatefulWidget {
  const DefaultHomePage({super.key});

  @override
  State<DefaultHomePage> createState() => _DefaultHomePageState();
}

class _DefaultHomePageState extends State<DefaultHomePage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleViewModel>().fetchSchedules();
    });
  }

  Widget _buildScheduleList(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          "등록된 일정이 없습니다.",
          style: TextStyle(color: AppColor.textGrey),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Dismissible(
            key: Key(schedule.id),
            direction: DismissDirection.endToStart,
            background: Container(color: Colors.transparent),
            secondaryBackground: Container(
              margin: const EdgeInsets.symmetric(
                vertical: AppConstNumber.kSmallPadding, 
                horizontal: AppConstNumber.kLargeRadius
              ),
              decoration: BoxDecoration(
                color: AppColor.errorColor,
                borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: AppColor.white),
            ),
            onDismissed: (direction) {
              context.read<ScheduleViewModel>().deleteSchedule(schedule.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${schedule.scheduleName} 삭제됨')),
              );
            },
            child: ListItemComponent(schedule: schedule),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScheduleViewModel>();
    final schedules = viewModel.selectedDaySchedules;
    final selectedDay = viewModel.selectedDay;

    final dateHeader = DateFormat('M월 d일 EEEE', 'ko_KR').format(selectedDay);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,


      body: Column(
        children: [
          CalendarComponent(
            focusedDay: viewModel.focusedDay,
            selectedDay: viewModel.selectedDay,
            onDaySelected: (selected, focused) {
              viewModel.onDaySelected(selected, focused);
            },
            onPageChanged: (focused) {
              viewModel.onPageChanged(focused);
            },
            eventLoader: (day) {
              return viewModel.getEventsForDay(day);
            },
          ),
          const SizedBox(height: AppConstNumber.kLargeRadius),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstNumber.kLargeRadius),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateHeader,
                  style: const TextStyle(
                    fontSize: AppConstNumber.kHeaderFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                Text(
                  "${schedules.length}개",
                  style: const TextStyle(
                    fontSize: AppConstNumber.kBodyFontSize,
                    color: AppColor.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstNumber.kItemSpacing),
          Expanded(
            child: _buildScheduleList(schedules),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddScheduleBottomSheet(
              initialDate: viewModel.selectedDay,
            ),
          );
        },
        backgroundColor: AppColor.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColor.white),
      ),
    );
  }
}
