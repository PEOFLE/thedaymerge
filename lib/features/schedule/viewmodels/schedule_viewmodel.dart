import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:thedaymerge/features/schedule/models/schedule_model.dart';
import 'package:thedaymerge/features/schedule/repositories/save_and_load/cloud_service.dart';
import 'package:thedaymerge/features/schedule/repositories/ai_and_ocr/ai_service.dart';
import 'package:thedaymerge/features/schedule/repositories/notification_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleRepository _repository;
  final ScheduleAiRepository _aiRepository;
  final LocalNotificationService _notificationService = LocalNotificationService();

  // --- 1. Global Schedule State ---
  List<ScheduleModel> _allSchedules = [];
  StreamSubscription<List<ScheduleModel>>? _schedulesSubscription;
  
  // --- 2. View-specific State ---
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isAnalyzing = false;

  // --- 3. Getters ---
  DateTime get focusedDay => _focusedDay;
  DateTime get selectedDay => _selectedDay;
  bool get isAnalyzing => _isAnalyzing;
  
  List<ScheduleModel> get selectedDaySchedules => getEventsForDay(_selectedDay);

  ScheduleViewModel({
    required ScheduleRepository repository,
    required ScheduleAiRepository aiRepository,
  })  : _repository = repository,
        _aiRepository = aiRepository {
    _initNotification();
    fetchSchedules();
  }
  
  void _initNotification() async {
    await _notificationService.init();
  }

  // --- 4. Business Logic ---
  
  // Helper
  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // For Calendar
  List<ScheduleModel> getEventsForDay(DateTime day) {
    return _allSchedules.where((schedule) {
      final startDate = DateTime(schedule.startTime.year, schedule.startTime.month, schedule.startTime.day);
      final endDate = DateTime(schedule.endTime.year, schedule.endTime.month, schedule.endTime.day);
      final checkDate = DateTime(day.year, day.month, day.day);
      return checkDate.isAtSameMomentAs(startDate) || 
             checkDate.isAtSameMomentAs(endDate) ||
             (checkDate.isAfter(startDate) && checkDate.isBefore(endDate));
    }).toList();
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

  Future<void> addSchedule({required ScheduleModel schedule}) async {
    // Save to DB
    final id = await _repository.addSchedule(
      scheduleName: schedule.scheduleName,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      isAI: schedule.isAI,
      alarmTime: schedule.alarmTime,
    );
    
    // Schedule Notification if alarmTime exists
    if (schedule.alarmTime != null) {
      await _notificationService.scheduleNotification(
        id: id.hashCode, 
        title: "일정 알림: ${schedule.scheduleName}",
        body: "${DateFormat('HH:mm').format(schedule.startTime)}에 일정이 있습니다.",
        scheduledTime: schedule.alarmTime!,
      );
    }
  }

  Future<void> createSchedule({
    required String scheduleName,
    required DateTime startTime,
    required DateTime endTime,
    DateTime? alarmTime,
  }) async {
    final id = await _repository.addSchedule(
      scheduleName: scheduleName,
      startTime: startTime,
      endTime: endTime,
      isAI: false,
      alarmTime: alarmTime,
    );
    
    // Schedule Notification if alarmTime exists
    if (alarmTime != null) {
      await _notificationService.scheduleNotification(
        id: id.hashCode, 
        title: "일정 알림: $scheduleName",
        body: "${DateFormat('HH:mm').format(startTime)}에 일정이 있습니다.",
        scheduledTime: alarmTime,
      );
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _repository.deleteSchedule(scheduleId);
    // Cancel notification
    await _notificationService.cancelNotification(scheduleId.hashCode);
  }
  
  // For UploadPage
  Future<String> analyzeImage(String imagePath) async {
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      final scheduleModel = await _aiRepository.analyzeImage(imagePath);
      
      if (scheduleModel != null) {
        await addSchedule(schedule: scheduleModel);
        return "일정이 등록되었습니다: ${scheduleModel.scheduleName} (${DateFormat('M/d').format(scheduleModel.startTime)})";
      } else {
        return "분석된 일정을 찾을 수 없습니다.";
      }
    } catch (e) {
      return "분석 실패: $e";
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // For ListItemComponent
  String formatTimeString(ScheduleModel schedule) {
    bool isSameDay = schedule.startTime.year == schedule.endTime.year &&
        schedule.startTime.month == schedule.endTime.month &&
        schedule.startTime.day == schedule.endTime.day;

    if (isSameDay) {
      final startTime = DateFormat('HH:mm').format(schedule.startTime);
      final endTime = DateFormat('HH:mm').format(schedule.endTime);
      return "$startTime - $endTime";
    } else {
      final start = DateFormat('M/d HH:mm').format(schedule.startTime);
      final end = DateFormat('M/d HH:mm').format(schedule.endTime);
      return "$start - $end";
    }
  }

  @override
  void dispose() {
    _schedulesSubscription?.cancel();
    super.dispose();
  }
}
