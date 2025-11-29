import 'package:shared_preferences/shared_preferences.dart';

const String schedulesKey = "my_schedules";

Future<void> saveSchedule(String newSchedule) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> currentSchedules = prefs.getStringList(schedulesKey) ?? [];

  if (!currentSchedules.contains(newSchedule)) {
    currentSchedules.add(newSchedule);
    await prefs.setStringList(schedulesKey, currentSchedules);
  }
}

Future<List<String>> loadSchedules() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(schedulesKey) ?? [];
}

Future<void> deleteSchedule(String scheduleToDelete) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> currentSchedules = prefs.getStringList(schedulesKey) ?? [];
  currentSchedules.remove(scheduleToDelete);
  await prefs.setStringList(schedulesKey, currentSchedules);
}