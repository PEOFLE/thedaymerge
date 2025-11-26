import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thedaymerge/features/schedule/viewmodels/schedule_viewmodel.dart';

class UploadViewModel extends ChangeNotifier {
  final ScheduleViewModel _scheduleViewModel;
  final ImagePicker _picker = ImagePicker();

  UploadViewModel(this._scheduleViewModel);

  /// 이미지 선택 및 분석을 처리하는 비즈니스 로직
  Future<String> pickAndAnalyzeImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // 이미지 분석은 ScheduleViewModel에 위임
        return await _scheduleViewModel.analyzeImage(image.path);
      } else {
        return "이미지 선택이 취소되었습니다.";
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return "이미지 선택 중 오류가 발생했습니다: $e";
    }
  }
}
