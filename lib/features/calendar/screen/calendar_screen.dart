import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/schedule.dart';
import '../../../theme/app_colors.dart';
import '../widgets/schedule_list.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Schedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      // 🔥 예시 일정 1개만 추가
      setState(() {
        _schedules = [
          Schedule(
            title: '팀 미팅 (예시)',
            startTime: DateTime.now().add(const Duration(hours: 2)),
            endTime: DateTime.now().add(const Duration(hours: 3)),
            reminder: '30분 전',
            isAI: true,
          ),
        ];
        _isLoading = false;
      });
      // "첫 방문 아님"으로 저장
      await prefs.setBool('isFirstRun', false);
    } else {
      // 두 번째 방문부터는 빈 리스트
      setState(() {
        _schedules = [];
        _isLoading = false;
      });
    }
  }

  void _removeSchedule(Schedule schedule) {
    setState(() {
      _schedules.remove(schedule);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('일정이 삭제되었습니다.'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 일정 관리'),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.textBlack,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.white),
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat.M('ko_KR').format(_focusedDay)} 일정',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_schedules.length}개',
                  style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ScheduleList(
              schedules: _schedules,
              onRemove: _removeSchedule,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 일정 추가 기능
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}