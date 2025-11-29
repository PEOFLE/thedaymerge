import 'package:flutter/material.dart';

class AddScheduleViewModel extends ChangeNotifier {
  late DateTime _startTime;
  late DateTime _endTime;
  
  // 알림 옵션 (null = 없음, 정수 = 몇 분 전, -1 = 즉시)
  int? _alarmOffsetMinutes;

  DateTime get startTime => _startTime;
  DateTime get endTime => _endTime;
  int? get alarmOffsetMinutes => _alarmOffsetMinutes;

  AddScheduleViewModel({required DateTime initialDate}) {
    _initializeTimes(initialDate);
  }

  void _initializeTimes(DateTime initialDate) {
    final now = DateTime.now();
    _startTime = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
      now.hour,
      now.minute,
    );
    _endTime = _startTime.add(const Duration(hours: 1));
  }

  void updateStartTime(DateTime newTime) {
    _startTime = newTime;
    // 시작 시간이 변경되었을 때, 종료 시간이 시작 시간보다 빠르면 1시간 뒤로 자동 조정
    if (_endTime.isBefore(_startTime)) {
      _endTime = _startTime.add(const Duration(hours: 1));
    }
    notifyListeners();
  }

  void updateEndTime(DateTime newTime) {
    _endTime = newTime;
    notifyListeners();
  }
  
  void updateAlarmOffset(int? minutes) {
    _alarmOffsetMinutes = minutes;
    notifyListeners();
  }

  /// 유효성 검사: 실패 시 에러 메시지 반환, 성공 시 null 반환
  String? validateTimes() {
    if (_endTime.isBefore(_startTime)) {
      return '종료 시간이 시작 시간보다 빠를 수 없습니다.';
    }
    return null;
  }
  
  /// 실제 알람 시간 계산 (startTime - offset)
  DateTime? get calculatedAlarmTime {
    if (_alarmOffsetMinutes == null) return null;
    // -1인 경우 즉시 알림 (현재 시간 + 5초 여유)
    if (_alarmOffsetMinutes == -1) {
      return DateTime.now().add(const Duration(seconds: 5));
    }
    return _startTime.subtract(Duration(minutes: _alarmOffsetMinutes!));
  }
}
