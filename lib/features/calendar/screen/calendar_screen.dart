import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/schedule.dart';
import '../../../theme/app_colors.dart';
import '../widgets/schedule_list.dart';

import '../widgets/add_schedule_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // null 대신 초기값 설정

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
      setState(() {
        _schedules = [
          Schedule(
            title: '팀 미팅 (예시 - X 버튼으로 삭제)',
            startTime: DateTime.now().add(const Duration(hours: 2)),
            endTime: DateTime.now().add(const Duration(hours: 3)),
            reminder: '30분 전',
            isAI: true,
            isExample: true,
          ),
        ];
        _isLoading = false;
      });
      await prefs.setBool('isFirstRun', false);
    } else {
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

    if (!schedule.isExample && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('일정이 삭제되었습니다.'),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _addSchedule() async {
    // 팝업 띄우고 결과 기다리기
    final newSchedule = await showDialog<Schedule>(
      context: context,
      builder: (context) => AddScheduleDialog(selectedDate: _selectedDay),
    );

    // 입력하고 '추가' 버튼을 눌렀다면 (null이 아니라면)
    if (newSchedule != null) {
      setState(() {
        _schedules.add(newSchedule);
        // 날짜순 정렬 (선택사항)
        _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 일정이 추가되었습니다!')),
      );
    }
  }

  void _showScheduleDetail(Schedule schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dateFormat = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');
        final timeFormat = DateFormat('a h:mm', 'ko_KR');

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(schedule.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.calendar_today, dateFormat.format(schedule.startTime)),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.access_time,
                  '${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)}'),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.notifications_none, schedule.reminder),
              if (schedule.isAI) ...[
                const SizedBox(height: 8),
                _buildDetailRow(Icons.auto_awesome, 'AI 자동 생성됨'),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기', style: TextStyle(color: AppColors.textGrey)),
            ),
            TextButton(
              onPressed: () => _removeSchedule(schedule),
              child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textGrey),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const SizedBox(height: 16),
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
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                onItemTap: _showScheduleDetail,
                onRemove: _removeSchedule,
              ),
            ),
          ],
        ),
      ),
      // 🔥 [연결 완료] 버튼 누르면 _addSchedule 실행
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}