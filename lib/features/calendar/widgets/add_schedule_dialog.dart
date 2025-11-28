import 'package:flutter/material.dart';
import '../../../models/schedule.dart';
import '../../../theme/app_colors.dart';

class AddScheduleDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Schedule? initialSchedule; // 🔥 [추가] 수정할 때 받을 기존 스케줄

  const AddScheduleDialog({
    super.key,
    required this.selectedDate,
    this.initialSchedule, // 선택값 (없으면 추가 모드, 있으면 수정 모드)
  });

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  late TextEditingController _titleController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  int _alarmMinutes = 10; // 기본 10분 전

  @override
  void initState() {
    super.initState();

    // 🔥 [핵심] 기존 스케줄이 있으면 그 값으로 초기화!
    if (widget.initialSchedule != null) {
      final s = widget.initialSchedule!;
      _titleController = TextEditingController(text: s.title);
      _startTime = TimeOfDay.fromDateTime(s.startTime);
      _endTime = TimeOfDay.fromDateTime(s.endTime);
      // 알림 설정은 저장된 게 없으므로 기본값 사용 (필요 시 모델에 추가 가능)
    } else {
      _titleController = TextEditingController();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startTime = picked;
        else _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialSchedule != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditMode ? '일정 수정' : '새 일정 추가', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '일정 제목',
              labelStyle: TextStyle(color: AppColors.textGrey),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeButton('시작', _startTime, true),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              _buildTimeButton('종료', _endTime, false),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.textGrey),
              const SizedBox(width: 8),
              const Text("알림", style: TextStyle(color: AppColors.textBlack)),
              const Spacer(),
              DropdownButton<int>(
                value: _alarmMinutes,
                underline: Container(),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("정시")),
                  DropdownMenuItem(value: 10, child: Text("10분 전")),
                  DropdownMenuItem(value: 30, child: Text("30분 전")),
                  DropdownMenuItem(value: 60, child: Text("1시간 전")),
                  DropdownMenuItem(value: 1440, child: Text("1일 전")),
                ],
                onChanged: (value) => setState(() => _alarmMinutes = value!),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: AppColors.textGrey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            if (_titleController.text.isEmpty) return;

            final baseDate = widget.initialSchedule?.startTime ?? widget.selectedDate;

            final startDateTime = DateTime(
              baseDate.year, baseDate.month, baseDate.day,
              _startTime.hour, _startTime.minute,
            );
            final endDateTime = DateTime(
              baseDate.year, baseDate.month, baseDate.day,
              _endTime.hour, _endTime.minute,
            );

            String reminderText = "알림 없음";
            if (_alarmMinutes == 0) reminderText = "정시 알림";
            else if (_alarmMinutes == 10) reminderText = "10분 전";
            else if (_alarmMinutes == 30) reminderText = "30분 전";
            else if (_alarmMinutes == 60) reminderText = "1시간 전";
            else if (_alarmMinutes == 1440) reminderText = "1일 전";

            final newSchedule = Schedule(
              title: _titleController.text,
              startTime: startDateTime,
              endTime: endDateTime,
              reminder: reminderText,
              // 수정 중이면 기존 속성 유지
              isAI: widget.initialSchedule?.isAI ?? false,
              isExample: false,
            );

            Navigator.pop(context, {'schedule': newSchedule, 'alarmMinutes': _alarmMinutes});
          },
          child: Text(isEditMode ? '수정 완료' : '추가', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label, TimeOfDay time, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        TextButton(
          onPressed: () => _pickTime(isStart),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            time.format(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
        ),
      ],
    );
  }
}