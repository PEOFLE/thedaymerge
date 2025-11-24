import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/schedule.dart';
import '../../../functions/schedule_service.dart';
import '../../../theme/app_colors.dart';

void showScheduleConfirmDialog(BuildContext context, Schedule schedule) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("🗓️ 일정 분석 완료"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("제목: ${schedule.title}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("일시: ${DateFormat('yyyy.MM.dd HH:mm').format(schedule.startTime)}"),
          const SizedBox(height: 16),
          const Text("이대로 저장하시겠습니까?", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("취소", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await saveSchedule(schedule);
            if (context.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ 일정이 저장되었습니다.")),
              );
            }
          },
          child: const Text("저장"),
        ),
      ],
    ),
  );
}