import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/schedule.dart';
import '../../../functions/cloud_service.dart';
import '../../../functions/notification_service.dart';
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
  DateTime? _selectedDay;

  List<Schedule> _allSchedules = [];
  List<Schedule> _visibleSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeData();
  }

  Future<void> _initializeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _checkAndLoadExample(user.uid);
      await _syncData(user.uid);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAndLoadExample(String userId) async {
    bool hasSeen = await checkTutorialStatus(userId);
    if (!hasSeen) {
      if (mounted) {
        setState(() {
          _allSchedules.add(
            Schedule(
              title: '팀 미팅 (예시 - X 버튼으로 삭제)',
              startTime: DateTime.now().add(const Duration(hours: 2)),
              endTime: DateTime.now().add(const Duration(hours: 3)),
              reminder: '30분 전',
              isAI: true,
              isExample: true,
            ),
          );
          _updateVisibleSchedules();
        });
      }
    }
  }

  Future<void> _syncData(String userId) async {
    if (!mounted) return;
    try {
      final List<Schedule> cloudSchedules = await loadCalendarEventsFromCloud(userId: userId);
      if (mounted) {
        setState(() {
          final examples = _allSchedules.where((s) => s.isExample).toList();
          _allSchedules = [...examples, ...cloudSchedules];
          _updateVisibleSchedules();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("동기화 오류: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // [Logic 3] 일정 추가
  Future<void> _addSchedule() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(selectedDate: _selectedDay ?? DateTime.now()),
    );

    if (result != null && result is Map) {
      _processNewSchedule(result['schedule'], result['alarmMinutes']);
    }
  }

  // [Logic 4] 일정 수정 🔥 [추가된 부분]
  Future<void> _editSchedule(Schedule oldSchedule) async {
    // 수정 팝업 띄우기 (기존 정보 전달)
    final result = await showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        selectedDate: oldSchedule.startTime,
        initialSchedule: oldSchedule,
      ),
    );

    if (result != null && result is Map) {
      final Schedule newSchedule = result['schedule'];
      final int alarmMinutes = result['alarmMinutes'];

      // 1. 기존 일정 삭제 (서버, 알림, 로컬)
      await _removeSchedule(oldSchedule, skipSnackBar: true); // 스낵바 없이 조용히 삭제

      // 2. 새 일정 추가 (서버, 알림, 로컬)
      await _processNewSchedule(newSchedule, alarmMinutes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 수정되었습니다!')),
      );
    }
  }

  // 일정 추가/수정 공통 처리 함수
  Future<void> _processNewSchedule(Schedule newSchedule, int alarmMinutes) async {
    // 화면 갱신
    setState(() {
      _allSchedules.add(newSchedule);
      _updateVisibleSchedules();
    });

    // 알림 예약
    DateTime alarmTime = newSchedule.startTime.subtract(Duration(minutes: alarmMinutes));
    int notificationId = newSchedule.startTime.millisecondsSinceEpoch ~/ 1000;
    await NotificationService().scheduleNotification(
      id: notificationId,
      title: newSchedule.title,
      scheduledTime: alarmTime,
    );

    // 서버 저장
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await saveCalendarEventsToCloud(
          userId: user.uid,
          eventList: [newSchedule],
        );
      } catch (e) {
        print("서버 저장 실패: $e");
      }
    }
  }

  // [Logic 5] 일정 삭제 (수정 시에도 사용됨)
  Future<void> _removeSchedule(Schedule schedule, {bool skipSnackBar = false}) async {
    // 화면 삭제
    setState(() {
      _allSchedules.remove(schedule);
      _updateVisibleSchedules();
    });

    if (!schedule.isExample && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }

    // 알림 취소
    int notificationId = schedule.startTime.millisecondsSinceEpoch ~/ 1000;
    await NotificationService().cancelNotification(notificationId);

    // 서버 삭제
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (schedule.isExample) {
        await markTutorialAsSeen(user.uid);
      } else {
        try {
          await deleteCalendarEventFromCloud(userId: user.uid, schedule: schedule);
        } catch (e) {
          print("서버 삭제 실패: $e");
        }
      }
    }

    if (!skipSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 삭제되었습니다.'), duration: Duration(milliseconds: 1500)),
      );
    }
  }

  void _updateVisibleSchedules() {
    if (_selectedDay == null) return;
    setState(() {
      _visibleSchedules = _allSchedules.where((schedule) {
        return isSameDay(schedule.startTime, _selectedDay);
      }).toList();
      _visibleSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  List<Schedule> _getEventsForDay(DateTime day) {
    return _allSchedules.where((schedule) => isSameDay(schedule.startTime, day)).toList();
  }

  // ===========================================================================
  // [UI] 화면 구성
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그날머지?', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            const SizedBox(height: 8),
            _buildTableCalendar(),
            const SizedBox(height: 16),
            _buildDateHeader(),
            const SizedBox(height: 8),
            _buildScheduleList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar<Schedule>(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      eventLoader: _getEventsForDay,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: AppColors.textBlack, shape: BoxShape.circle),
        todayTextStyle: TextStyle(color: Colors.white),
        markerDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
      ),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _updateVisibleSchedules();
        }
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
    );
  }

  Widget _buildDateHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDay != null
                ? DateFormat('M월 d일 EEEE', 'ko_KR').format(_selectedDay!)
                : '날짜를 선택하세요',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${_visibleSchedules.length}개',
            style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Expanded(
      child: ScheduleList(
        schedules: _visibleSchedules,
        onItemTap: _showScheduleDetail,
        onRemove: _removeSchedule,
      ),
    );
  }

  // 🔥 [수정] 상세 팝업에 '수정' 버튼 추가
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
            // 🔥 예시가 아닐 때만 수정 버튼 표시
            if (!schedule.isExample)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫고
                  _editSchedule(schedule);     // 수정 화면 열기
                },
                child: const Text('수정', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
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
}