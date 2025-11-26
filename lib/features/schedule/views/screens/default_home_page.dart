import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../cores/app_color.dart';
import '../../viewmodels/schedule_viewmodel.dart';
import '../components/calendar_component.dart';
import '../components/list_item_component.dart';

class DefaultHomePage extends StatefulWidget {
  const DefaultHomePage({super.key});

  @override
  State<DefaultHomePage> createState() => _DefaultHomePageState();
}

class _DefaultHomePageState extends State<DefaultHomePage> {
  
  @override
  void initState() {
    super.initState();
    // Refresh schedules when the page loads (e.g. after login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleViewModel>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel
    final viewModel = context.watch<ScheduleViewModel>();
    final schedules = viewModel.selectedDaySchedules;
    final selectedDay = viewModel.selectedDay;

    // Date Format for Header (e.g., 11월 26일 수요일)
    final dateHeader = DateFormat('M월 d일 EEEE', 'ko_KR').format(selectedDay);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          "AI 일정 관리",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            // [추가] 이벤트 로더 함수 전달 -> 캘린더에 점(마커) 표시
            eventLoader: (day) {
              return viewModel.getEventsForDay(day);
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateHeader,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textBlack,
                  ),
                ),
                Text(
                  "${schedules.length}개",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
          // TODO: Navigate to upload page or add schedule dialog
          debugPrint("Add schedule clicked");
        },
        backgroundColor: AppColor.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
