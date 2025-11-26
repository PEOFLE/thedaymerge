import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';

class ListItemViewModel extends ChangeNotifier {
  final ScheduleModel schedule;

  ListItemViewModel(this.schedule);

  /// 일정의 시작과 종료 시간을 포맷팅하여 문자열로 반환하는 비즈니스 로직
  String get timeString {
    // 시작일과 종료일이 같은 날인지 확인
    bool isSameDay = schedule.startTime.year == schedule.endTime.year &&
        schedule.startTime.month == schedule.endTime.month &&
        schedule.startTime.day == schedule.endTime.day;

    if (isSameDay) {
      // 같은 날이면 "HH:mm - HH:mm" 형식
      final startTime = DateFormat('HH:mm').format(schedule.startTime);
      final endTime = DateFormat('HH:mm').format(schedule.endTime);
      return "$startTime - $endTime";
    } else {
      // 다른 날이면 "M/d HH:mm - M/d HH:mm" 형식
      final start = DateFormat('M/d HH:mm').format(schedule.startTime);
      final end = DateFormat('M/d HH:mm').format(schedule.endTime);
      return "$start - $end";
    }
  }
}
