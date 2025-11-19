import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import 'schedule_list_item.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;

  const ScheduleList({super.key, required this.schedules});

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        // ScheduleListItem 위젯 사용
        return ScheduleListItem(schedule: schedules[index]);
      },
    );
  }
}