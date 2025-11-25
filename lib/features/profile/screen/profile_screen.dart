import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart'; // 색상 파일 import

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 정보 가져오기
    final User? user = FirebaseAuth.instance.currentUser;

    // 가입일 포맷팅 (예: 2025.11.23)
    String creationDate = '정보 없음';
    if (user?.metadata.creationTime != null) {
      // 🔥 [수정된 부분] .toLocal()을 추가하여 기기 설정(한국 시간)으로 변환
      creationDate = DateFormat('yyyy.MM.dd').format(user!.metadata.creationTime!.toLocal());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더 (아이콘 + 인사말)
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 35, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '반갑습니다!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? '게스트',
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 정보 카드
            Card(
              color: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildProfileRow('이메일', user?.email ?? '-'),
                    _buildProfileRow('이름', user?.displayName ?? '사용자'),
                    _buildProfileRow('가입일', creationDate, isLast: true), // 수정된 날짜 사용
                  ],
                ),
              ),
            ),

            const Spacer(), // 남은 공간 차지

            // 로그아웃 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('로그아웃'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 프로필 정보 한 줄을 그리는 헬퍼 위젯
  Widget _buildProfileRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 16,
                fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}