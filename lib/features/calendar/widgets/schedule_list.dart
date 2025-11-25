import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import 'schedule_list_item.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  final Function(Schedule) onItemTap; // 상세 보기 (클릭 시)
  final Function(Schedule) onRemove;  // 삭제 (스와이프 또는 X버튼 클릭 시)

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

        // 🔥 [팀원 코드 반영] Dismissible로 감싸서 스와이프 기능 추가
        return Dismissible(
          // 각 아이템을 구분하는 고유 키 (시간_제목)
          key: Key('${schedule.startTime}_${schedule.title}'),
          direction: DismissDirection.endToStart, // 오른쪽 -> 왼쪽 스와이프만 허용

          // 스와이프 할 때 뒤에 보이는 빨간 배경 (휴지통)
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

          // 스와이프가 끝났을 때 실행될 동작 -> onRemove 호출
          onDismissed: (direction) {
            onRemove(schedule);
          },

          // 실제 보여지는 리스트 아이템 (기존 로직 유지)
          child: ScheduleListItem(
            schedule: schedule,
            onTap: () => onItemTap(schedule), // 클릭 시 상세 보기
            onDelete: () => onRemove(schedule), // (예시 일정용) X 버튼 클릭 시 삭제
          ),
        );
      },
    );
  }
}