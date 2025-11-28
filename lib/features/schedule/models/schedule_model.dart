import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String scheduleName;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAI;
  final DateTime? alarmTime;

  ScheduleModel({
    required this.id,
    required this.scheduleName,
    required this.startTime,
    required this.endTime,
    this.isAI = false,
    this.alarmTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json, String id) {
    return ScheduleModel(
      id: id,
      scheduleName: json['scheduleName'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      isAI: json['isAI'] ?? false,
      alarmTime: json['alarmTime'] != null 
          ? (json['alarmTime'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleName': scheduleName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isAI': isAI,
      'alarmTime': alarmTime != null ? Timestamp.fromDate(alarmTime!) : null,
    };
  }
}
