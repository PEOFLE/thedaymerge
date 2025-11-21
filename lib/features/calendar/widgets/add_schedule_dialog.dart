import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/schedule.dart';
import '../../../theme/app_colors.dart';

class AddScheduleDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddScheduleDialog({super.key, required this.selectedDate});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _titleController = TextEditingController();

  // 기본 시간 설정 (현재 시간 ~ 1시간 뒤)
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // 시계 색상 핑크로
            ),
          ),
          child: child!,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('새 일정 추가', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 제목 입력
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: '일정 제목',
              labelStyle: const TextStyle(color: AppColors.textGrey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),

          // 2. 시간 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeButton('시작', _startTime, true),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              _buildTimeButton('종료', _endTime, false),
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

            // 날짜와 시간을 합쳐서 DateTime 생성
            final startDateTime = DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              _startTime.hour,
              _startTime.minute,
            );
            final endDateTime = DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
              _endTime.hour,
              _endTime.minute,
            );

            // 입력된 정보로 Schedule 객체 생성해서 돌려주기
            final newSchedule = Schedule(
              title: _titleController.text,
              startTime: startDateTime,
              endTime: endDateTime,
              reminder: '설정 안 함', // 기본값
              isAI: false, // 직접 추가했으므로 AI 아님
              isExample: false, // 진짜 데이터
            );

            Navigator.pop(context, newSchedule);
          },
          child: const Text('추가', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack
            ),
          ),
        ),
      ],
    );
  }
}