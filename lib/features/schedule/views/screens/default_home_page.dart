import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/schedule/views/components/calendar_component.dart';
import 'package:thedaymerge/features/schedule/views/components/list_item_component.dart';

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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScheduleViewModel>();
    final schedules = viewModel.selectedDaySchedules;
    final selectedDay = viewModel.selectedDay;

    final dateHeader = DateFormat('M월 d일 EEEE', 'ko_KR').format(selectedDay);

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
            child: schedules.isEmpty
                ? const Center(
                    child: Text(
                      "등록된 일정이 없습니다.",
                      style: TextStyle(color: AppColor.textGrey),
                    ),
                  )
                : ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return ListItemComponent(schedule: schedules[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("Add schedule clicked");
        },
        backgroundColor: AppColor.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColor.white),
      ),
    );
  }
}
