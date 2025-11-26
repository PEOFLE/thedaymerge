import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import '../repositories/save_and_load/cloud_service.dart';
import '../repositories/ai_and_ocr/ai_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository _repository;
  final ScheduleAiRepository _aiRepository;

  List<ScheduleModel> _allSchedules = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  bool _isAnalyzing = false;

  StreamSubscription<List<ScheduleModel>>? _schedulesSubscription;

  ScheduleViewModel({
    required ScheduleRepository repository,
    required ScheduleAiRepository aiRepository,
  })  : _repository = repository,
        _aiRepository = aiRepository {
    fetchSchedules();
  }

  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  bool get isAnalyzing => _isAnalyzing;
  
  List<ScheduleModel> get selectedDaySchedules {
    return getEventsForDay(_selectedDay);
  }

  /// 특정 날짜의 일정 목록을 반환 (Calendar Marker용)
  List<ScheduleModel> getEventsForDay(DateTime day) {
    return _allSchedules.where((schedule) {
      return isSameDay(schedule.startTime, day) ||
             (schedule.startTime.isBefore(day) && schedule.endTime.isAfter(day)) ||
             isSameDay(schedule.endTime, day);
    }).toList();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void fetchSchedules() {
    _schedulesSubscription?.cancel();
    _schedulesSubscription = _repository.getSchedules().listen((schedules) {
      _allSchedules = schedules;
      notifyListeners();
    });
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      notifyListeners();
    }
  }
  
  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  Future<void> addSchedule(String name, DateTime start, DateTime end) async {
    await _repository.addSchedule(
      scheduleName: name,
      startTime: start,
      endTime: end,
    );
  }

  // [수정] 반환 타입을 String? -> String으로 변경하여 에러 메시지를 확실히 전달
  Future<String> analyzeImage(String imagePath) async {
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      final scheduleModel = await _aiRepository.analyzeImage(imagePath);
      
      if (scheduleModel != null) {
        // AI 분석 성공 시 자동으로 일정 등록
        await addSchedule(
          scheduleModel.scheduleName,
          scheduleModel.startTime,
          scheduleModel.endTime,
        );
        
        _isAnalyzing = false;
        notifyListeners();
        return "일정이 등록되었습니다: ${scheduleModel.scheduleName} (${DateFormat('M/d').format(scheduleModel.startTime)})";
      } else {
        _isAnalyzing = false;
        notifyListeners();
        return "일정을 찾을 수 없습니다.";
      }
    } catch (e) {
      _isAnalyzing = false;
      notifyListeners();
      // 에러 메시지를 반환하여 UI에서 표시
      return "분석 실패: $e";
    }
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    super.dispose();
  }
}
