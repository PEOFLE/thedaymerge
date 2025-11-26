import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../cores/app_color.dart';
import '../../models/schedule_model.dart';

class ListItemComponent extends StatelessWidget {
  final ScheduleModel schedule;

  const ListItemComponent({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    String timeString;
    
    // Check if start and end are on the same day
    bool isSameDay = schedule.startTime.year == schedule.endTime.year &&
        schedule.startTime.month == schedule.endTime.month &&
        schedule.startTime.day == schedule.endTime.day;

    if (isSameDay) {
      final startTime = DateFormat('HH:mm').format(schedule.startTime);
      final endTime = DateFormat('HH:mm').format(schedule.endTime);
      timeString = "$startTime - $endTime";
    } else {
      final start = DateFormat('M/d HH:mm').format(schedule.startTime);
      final end = DateFormat('M/d HH:mm').format(schedule.endTime);
      timeString = "$start - $end";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (schedule.isAI) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1BEE7), // Light purple
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "AI",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B1FA2), // Deep purple
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        schedule.scheduleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeString,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
