import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import 'schedule_list_item.dart';

class ScheduleList extends StatelessWidget {
  final List<Schedule> schedules;
  final Function(Schedule) onItemTap; // 클릭 시 (상세보기)
  final Function(Schedule) onRemove;  // 삭제 시 (스와이프 완료)

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

        // 🔥 [수정됨] Dismissible로 감싸서 스와이프 삭제 기능 추가
        return Dismissible(
          // 각 아이템을 구분하는 고유 키 (제목+시간)
          key: ValueKey('${schedule.startTime}_${schedule.title}'),

          // 오른쪽에서 왼쪽으로 밀 때만 삭제 허용
          direction: DismissDirection.endToStart,

          // 스와이프할 때 뒤에 보이는 배경 (빨간색 + 휴지통)
          background: Container(
            margin: const EdgeInsets.only(bottom: 12.0), // 카드 간격 맞춤
            padding: const EdgeInsets.only(right: 20.0),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16), // 카드 둥근 모서리 맞춤
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    '삭제',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white),
              ],
            ),
          ),

          // 스와이프가 끝났을 때 실행될 동작
          onDismissed: (direction) {
            onRemove(schedule);
          },

          // 실제 보여지는 리스트 아이템
          child: ScheduleListItem(
            schedule: schedule,
            onTap: () => onItemTap(schedule),
            onDelete: () => onRemove(schedule), // (예시 일정용 X버튼 연결 유지)
          ),
        );
      },
    );
  }
}