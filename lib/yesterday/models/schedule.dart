class Schedule {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String reminder;
  final bool isAI; // AI가 생성한 일정인지 여부

  Schedule({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.reminder,
    this.isAI = false,
  });
}