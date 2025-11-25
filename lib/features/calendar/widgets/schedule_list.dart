import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import 'schedule_list_item.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;

  // 부모 위젯으로 삭제 이벤트를 전달하는 콜백 함수
  final Function(Schedule)? onDelete;

  const ScheduleList({
    super.key,
    required this.schedules,
    this.onDelete,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];

        // 스와이프 삭제 기능 적용 (Dismissible)
        return Dismissible(
          key: Key('${schedule.startTime}_${schedule.title}'), // 고유 키
          direction: DismissDirection.endToStart, // 오른쪽 -> 왼쪽 스와이프

          // 스와이프 배경 (빨간색 + 휴지통 아이콘)
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          // 스와이프 완료 시 실행
          onDismissed: (direction) {
            if (onDelete != null) {
              onDelete!(schedule);
            }
          },

          // 실제 리스트 아이템 위젯
          child: ScheduleListItem(schedule: schedule),
        );
      },
    );
  }
}