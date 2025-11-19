import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/schedule.dart';
import '../widgets/schedule_list.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 더미 데이터
  final List<Schedule> _schedules = [
    Schedule(
      title: '팀 미팅',
      startTime: DateTime(2025, 12, 5, 14, 0),
      endTime: DateTime(2025, 12, 5, 15, 0),
      reminder: '30분 전',
      isAI: true,
    ),
    Schedule(
      title: '프로젝트 마감',
      startTime: DateTime(2025, 12, 15, 18, 0),
      endTime: DateTime(2025, 12, 15, 19, 0),
      reminder: '1일 전',
    ),
    Schedule(
      title: '치과 예약',
      startTime: DateTime(2025, 12, 20, 10, 0),
      endTime: DateTime(2025, 12, 20, 11, 0),
      reminder: '1일 전',
      isAI: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      ///(@Seonghyeon)
      ///
      ///(삭제)앱바 부분 쓸모없다고 생각해서 뺐음-달력 크기 확보 위해-
      ///(추가)노치 부분은 피하기 위해 SafeArea() 위젯으로 포장했음
      // appBar: AppBar(
      //   title: const Text('AI 일정 관리'),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(

              ///(@Seonghyeon)
              ///
              ///(추가)캘린더 길이 조절 했음
              ///rowHeight는 달력의 열의 높이를 조정
              ///dayOfWookHeight는 월~일 부분 높이를 조정
              rowHeight: 40,
              daysOfWeekHeight: 24,
              
        
              locale: 'ko_KR',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(fontSize: 18.0),
                titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${DateFormat.M('ko_KR').format(_focusedDay)} 일정',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_schedules.length}개',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // [수정됨] Expanded로 감싸서 남은 공간을 모두 차지하게 함
            Expanded(
              child: ScheduleList(schedules: _schedules),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 일정 추가 다이얼로그 (추후 구현)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}