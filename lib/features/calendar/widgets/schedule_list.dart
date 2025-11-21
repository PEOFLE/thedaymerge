import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import 'schedule_list_item.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  // 🔥 어떤 스케줄을 삭제할지 알려주는 함수
  final Function(Schedule) onRemove;

  const ScheduleList({
    super.key,
    required this.schedules,
    required this.onRemove, // 필수값
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          '등록된 일정이 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return ScheduleListItem(
          schedule: schedule,
          // 🔥 삭제 버튼 누르면 -> 부모(CalendarScreen)에게 "이거 지워줘!"라고 요청
          onDelete: () => onRemove(schedule),
        );
      },
    );
  }
}