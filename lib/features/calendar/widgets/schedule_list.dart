import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import 'schedule_list_item.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  final Function(Schedule) onItemTap; // 상세 보기 (진짜 일정용)
  final Function(Schedule) onRemove;  // 바로 삭제 (예시용)

  const ScheduleList({
    super.key,
    required this.schedules,
    required this.onItemTap,
    required this.onRemove,
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
          onTap: () => onItemTap(schedule), // 클릭 시
          onDelete: () => onRemove(schedule), // 삭제 버튼 클릭 시
        );
      },
    );
  }
}