import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';

class CalendarComponent extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<ScheduleModel> Function(DateTime)? eventLoader; // [추가] 이벤트 로더

  const CalendarComponent({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<ScheduleModel>(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      eventLoader: eventLoader, // [연결] 이벤트 로더 연결
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColor.textBlack,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppColor.textBlack),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppColor.textBlack),
      ),
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.transparent, 
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
            color: AppColor.textBlack
        ),
        defaultTextStyle: TextStyle(color: AppColor.textBlack),
        weekendTextStyle: TextStyle(color: AppColor.textBlack),
        
        // [추가] 마커 스타일 커스터마이징
        markerDecoration: BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1, // 마커 최대 1개만 표시 (깔끔하게)
      ),
      daysOfWeekHeight: 30,
    );
  }
}
