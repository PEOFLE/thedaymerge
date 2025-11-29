import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:thedaymerge/cores/app_color.dart';
import 'package:thedaymerge/cores/app_const_number.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';
import 'package:thedaymerge/features/schedule/viewmodels/add_schedule_viewmodel.dart';

class AddScheduleBottomSheet extends StatelessWidget {
  final DateTime initialDate;

  const AddScheduleBottomSheet({super.key, required this.initialDate});

  @override
  Widget build(BuildContext context) {
    // 뷰모델의 스코프를 이 바텀시트로 한정
    return ChangeNotifierProvider(
      create: (_) => AddScheduleViewModel(initialDate: initialDate),
      child: const _AddScheduleForm(),
    );
  }
}

class _AddScheduleForm extends StatefulWidget {
  const _AddScheduleForm();

  @override
  State<_AddScheduleForm> createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends State<_AddScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context, bool isStart) async {
    final viewModel = context.read<AddScheduleViewModel>();
    final initial = isStart ? viewModel.startTime : viewModel.endTime;
    
    // 1. 날짜 선택
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );
    
    if (date == null) return;
    if (!mounted) return;

    // 2. 시간 선택
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    
    if (time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // 3. ViewModel 업데이트
    if (isStart) {
      viewModel.updateStartTime(newDateTime);
    } else {
      viewModel.updateEndTime(newDateTime);
    }
  }

  void _saveSchedule(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final addVm = context.read<AddScheduleViewModel>();
    
    // 유효성 검사 로직은 ViewModel에 위임
    final error = addVm.validateTimes();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColor.errorColor,
        ),
      );
      return;
    }

    // 실제 데이터 생성은 Global ViewModel(ScheduleViewModel)에 요청
    context.read<ScheduleViewModel>().createSchedule(
      scheduleName: _nameController.text,
      startTime: addVm.startTime,
      endTime: addVm.endTime,
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstNumber.kDefaultPadding,
        AppConstNumber.kDefaultPadding,
        AppConstNumber.kDefaultPadding,
        bottomInset + AppConstNumber.kDefaultPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstNumber.kLargeRadius),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstNumber.kMediumPadding),
            
            _buildTitleInput(),
            const SizedBox(height: AppConstNumber.kMediumPadding),
            
            _buildTimeSelectionRow(context),
            const SizedBox(height: AppConstNumber.kLargePadding),
            
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      "새 일정 추가",
      style: TextStyle(
        fontSize: AppConstNumber.kHeaderFontSize,
        fontWeight: FontWeight.bold,
        color: AppColor.textBlack,
      ),
    );
  }

  Widget _buildTitleInput() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: "일정 이름",
        filled: true,
        fillColor: AppColor.inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstNumber.kMediumPadding,
          vertical: AppConstNumber.kMediumPadding,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '일정 이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildTimeSelectionRow(BuildContext context) {
    // ViewModel 상태 구독
    final viewModel = context.watch<AddScheduleViewModel>();

    return Row(
      children: [
        Expanded(
          child: _buildDateTimePickerItem(
            context: context,
            label: "시작", 
            dateTime: viewModel.startTime, 
            isStart: true,
          ),
        ),
        const SizedBox(width: AppConstNumber.kMediumPadding),
        Expanded(
          child: _buildDateTimePickerItem(
            context: context,
            label: "종료", 
            dateTime: viewModel.endTime, 
            isStart: false,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickerItem({
    required BuildContext context,
    required String label,
    required DateTime dateTime,
    required bool isStart,
  }) {
    return InkWell(
      onTap: () => _pickDateTime(context, isStart),
      borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstNumber.kSmallPadding,
          horizontal: AppConstNumber.kMediumPadding,
        ),
        decoration: BoxDecoration(
          color: AppColor.inputFillColor,
          borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
        ),
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
              DateFormat('M/d HH:mm').format(dateTime),
              style: const TextStyle(
                fontSize: AppConstNumber.kBodyFontSize,
                fontWeight: FontWeight.bold,
                color: AppColor.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _saveSchedule(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.primaryColor,
        minimumSize: const Size.fromHeight(AppConstNumber.kButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstNumber.kDefaultRadius),
        ),
        elevation: 0,
      ),
      child: const Text(
        "저장",
        style: TextStyle(
          fontSize: AppConstNumber.kTitleFontSize,
          fontWeight: FontWeight.bold,
          color: AppColor.white,
        ),
      ),
    );
  }
}
