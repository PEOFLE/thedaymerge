class Schedule {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String reminder;
  final bool isAI;
  final bool isExample;

  Schedule({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.reminder,
    this.isAI = false,
    this.isExample = false,
  });
}