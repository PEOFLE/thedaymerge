import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/schedule.dart'; // 모델 import
import '../../../theme/app_colors.dart'; // 컬러 import

class ScheduleListItem extends StatelessWidget {
  final Schedule schedule;

  const ScheduleListItem({super.key, required this.schedule});

  String _formatDateTime(DateTime start, DateTime end) {
    // 예: 12월 5일 오후 02:00 - 오후 03:00
    // 날짜 포맷이 필요하므로 intl 패키지 사용
    final DateFormat datePart = DateFormat('M월 d일', 'ko_KR');
    final DateFormat timePart = DateFormat('a hh:mm', 'ko_KR');

    return '${datePart.format(start)} ${timePart.format(start)} - ${timePart.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0), // 아이템 간 간격
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
          // 제목과 AI 태그
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                schedule.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              if (schedule.isAI)
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
    );
  }
}