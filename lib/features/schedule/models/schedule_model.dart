import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String scheduleName;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAI;

  ScheduleModel({
    required this.id,
    required this.scheduleName,
    required this.startTime,
    required this.endTime,
    this.isAI = false,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json, String id) {
    return ScheduleModel(
      id: id,
      scheduleName: json['scheduleName'] as String,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      isAI: json['isAI'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleName': scheduleName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isAI': isAI,
    };
  }
}
