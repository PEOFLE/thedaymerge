import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/schedule.dart';
import '../../../functions/schedule_service.dart';
import '../../../functions/cloud_service.dart';
import '../../../theme/app_colors.dart';
import '../widgets/schedule_list.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // --- 상태 변수 ---
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Schedule> _allSchedules = [];     // 전체 일정 (캘린더 마커용)
  List<Schedule> _visibleSchedules = []; // 선택된 날짜의 일정 (리스트 표시용)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _syncData(); // 화면 진입 시 데이터 동기화 시작
  }

  // ===========================================================================
  // [Logic] 데이터 처리 및 동기화
  // ===========================================================================

  /// 서버 <-> 로컬 <-> 화면 동기화 프로세스
  Future<void> _syncData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. 로컬 데이터 우선 로드 (빠른 UI 표시)
      await _loadLocalData();

      // 2. 로그인 유저 체크
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 3. 서버 데이터 가져오기
      final cloudData = await loadCalendarEventsFromCloud(userId: user.uid);

      // 4. 서버 데이터가 있다면 로컬에 병합 후 재로딩
      if (cloudData.isNotEmpty) {
        await _mergeCloudDataToLocal(cloudData);
        await _loadLocalData();
      }
    } catch (e) {
      print("동기화 오류: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 로컬 저장소에서 데이터를 불러와 상태를 갱신합니다.
  Future<void> _loadLocalData() async {
    final localData = await loadSchedules();
    if (mounted) {
      setState(() {
        _allSchedules = localData;
        _updateVisibleSchedules(); // 현재 선택된 날짜 리스트 갱신
      });
    }
  }

  /// 서버 데이터를 로컬 저장소에 저장(병합)합니다.
  Future<void> _mergeCloudDataToLocal(List<Schedule> cloudData) async {
    for (var schedule in cloudData) {
      await saveSchedule(schedule); // 서비스 내부에서 중복 체크 수행
    }
  }

  /// 일정을 삭제합니다. (로컬 삭제 -> 화면 갱신)
  Future<void> _deleteItem(Schedule schedule) async {
    await deleteSchedule(schedule);

    setState(() {
      _allSchedules.remove(schedule);
      _visibleSchedules.remove(schedule);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("일정이 삭제되었습니다.")),
    );
  }

  /// 날짜 선택 시 하단 리스트를 필터링합니다.
  void _updateVisibleSchedules() {
    if (_selectedDay == null) return;

    setState(() {
      _visibleSchedules = _allSchedules.where((schedule) {
        return isSameDay(schedule.startTime, _selectedDay);
      }).toList();

      // 시간순 정렬
      _visibleSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  /// 특정 날짜의 이벤트를 반환합니다. (캘린더 마커 표시용)
  List<Schedule> _getEventsForDay(DateTime day) {
    return _allSchedules.where((schedule) {
      return isSameDay(schedule.startTime, day);
    }).toList();
  }

  // ===========================================================================
  // [UI] 화면 구성
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTableCalendar(), // 1. 캘린더 위젯
          const SizedBox(height: 16),
          _buildDateHeader(),    // 2. 날짜 정보 헤더
          const SizedBox(height: 8),
          _buildScheduleList(),  // 3. 일정 리스트
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('AI 일정 관리'),
      actions: [
        IconButton(
          icon: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh),
          onPressed: _isLoading ? null : _syncData,
        )
      ],
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar<Schedule>(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      eventLoader: _getEventsForDay, // 마커(점) 표시 함수 연결

      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
      ),

      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Color(0xFF9FA8DA), shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Expanded(
      child: ScheduleList(
        schedules: _visibleSchedules,
        onDelete: _deleteItem, // 삭제 로직 연결
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("업로드 탭에서 일정을 추가해주세요!")),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}