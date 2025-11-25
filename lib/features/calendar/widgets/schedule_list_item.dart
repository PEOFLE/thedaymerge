import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/schedule.dart';
import '../../../theme/app_colors.dart';

class ScheduleListItem extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onTap;    // 카드 클릭 시 (상세보기 - 실제 일정용)
  final VoidCallback onDelete; // X 버튼 클릭 시 (바로삭제 - 예시 일정용)

  const ScheduleListItem({
    super.key,
    required this.schedule,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDateTime(DateTime start, DateTime end) {
    final DateFormat datePart = DateFormat('M월 d일', 'ko_KR');
    final DateFormat timePart = DateFormat('a h:mm', 'ko_KR'); // hh -> h (01시 말고 1시로 표시)
    return '${datePart.format(start)} ${timePart.format(start)} - ${timePart.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 🔥 [로직 반영] 예시가 아닐 때만 카드 클릭 가능 (상세보기)
      onTap: schedule.isExample ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 행 (제목 + AI 태그 + 삭제 버튼)
            Row(
              children: [
                // 제목 (긴 제목 대응을 위해 Expanded 사용)
                Expanded(
                  child: Text(
                    schedule.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // AI 태그 (isAI가 true일 때만 표시)
                if (schedule.isAI) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.aiTagBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: AppColors.aiTagText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                // 🔥 [로직 반영] 예시 데이터일 때만 X 버튼 표시
                if (schedule.isExample)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textGrey),
                    padding: EdgeInsets.zero, // 패딩 제거해서 간격 좁히기
                    constraints: const BoxConstraints(), // 최소 크기 제약 제거
                    onPressed: onDelete, // X 누르면 바로 삭제 콜백 실행
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 시간 정보
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(schedule.startTime, schedule.endTime),
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // 알림 정보
            Row(
              children: [
                const Icon(Icons.notifications_none, size: 16, color: AppColors.textGrey),
                const SizedBox(width: 4),
                Text(
                  schedule.reminder,
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}