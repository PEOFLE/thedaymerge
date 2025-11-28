import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';

class AddScheduleDialog extends StatefulWidget {
  final DateTime selectedDay;

  const AddScheduleDialog({super.key, required this.selectedDay});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final TextEditingController _titleController = TextEditingController();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _hasAlarm = false; // [Modification] Alarm toggle state

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty) return;

    final startDateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
      _endTime.hour,
      _endTime.minute,
    );

    final newSchedule = ScheduleModel(
      id: '', // Firestore will generate ID
      scheduleName: _titleController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      isAI: false,
      //hasAlarm: _hasAlarm, // [Modification] Include alarm flag
    );

    context.read<ScheduleViewModel>().addSchedule(schedule: newSchedule);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColor.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstNumber.kLargeRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstNumber.kDefaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "새 일정 추가",
              style: TextStyle(
                fontSize: AppConstNumber.kHeaderFontSize,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack,
              ),
            ),
            const SizedBox(height: AppConstNumber.kLargePadding),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "일정 제목",
                hintStyle: TextStyle(color: AppColor.textGrey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.textGrey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.textBlack),
                ),
              ),
            ),
            const SizedBox(height: AppConstNumber.kLargePadding),
            
            // Time selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeSelector("시작", _startTime, true),
                const Icon(Icons.arrow_forward, color: AppColor.textGrey, size: 16),
                _buildTimeSelector("종료", _endTime, false),
              ],
            ),
            
            const SizedBox(height: AppConstNumber.kMediumPadding),
            
            // [Modification] Alarm toggle UI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "알림 설정",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.textBlack,
                  ),
                ),
                Switch(
                  value: _hasAlarm,
                  activeColor: AppColor.primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      _hasAlarm = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: AppConstNumber.kLargePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소", style: TextStyle(color: AppColor.textGrey)),
                ),
                const SizedBox(width: AppConstNumber.kSmallPadding),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "추가",
                    style: TextStyle(color: AppColor.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, bool isStart) {
    return GestureDetector(
      onTap: () => _selectTime(context, isStart),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppConstNumber.kSmallFontSize,
              color: AppColor.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time.format(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}
