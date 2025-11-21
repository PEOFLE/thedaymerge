import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/schedule.dart';
import '../../../theme/app_colors.dart';

class ScheduleListItem extends StatelessWidget {
  final Schedule schedule;
  // 🔥 삭제 버튼을 눌렀을 때 실행될 함수를 전달받음
  final VoidCallback onDelete;

  const ScheduleListItem({
    super.key,
    required this.schedule,
    required this.onDelete, // 필수값으로 변경
  });

  String _formatDateTime(DateTime start, DateTime end) {
    final DateFormat datePart = DateFormat('M월 d일', 'ko_KR');
    final DateFormat timePart = DateFormat('a h:mm', 'ko_KR');
    return '${datePart.format(start)} ${timePart.format(start)} - ${timePart.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // 제목, AI 태그, 삭제 버튼
          Row(
            children: [
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
              // 🔥 삭제 아이콘 버튼 추가
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppColors.textGrey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // 아이콘 패딩 최소화
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),

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
    );
  }
}