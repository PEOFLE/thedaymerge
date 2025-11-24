import 'package:flutter/material.dart';

class LoadingOverlay {
  /// 로딩창 띄우기
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 바깥 부분을 터치해도 닫히지 않음 (중요!)
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // 로딩바 색상 (흰색)
        ),
      ),
    );
  }

  /// 로딩창 끄기
  static void hide(BuildContext context) {
    // 팝업이 떠있는지 확인하고 닫기
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}