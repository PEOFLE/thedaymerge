# 📆 그날머지? (The Day Merge?)
### **"그날 뭐지?" 고민 말고, 스크린샷 한 장으로 "머지(Merge)" 하세요!**

<br/>

<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
<img src="https://img.shields.io/badge/Naver_Clova-03C75A?style=for-the-badge&logo=naver&logoColor=white" />

<br/>

[Github 레포지토리] &nbsp;&middot;&nbsp; [시연 영상 보러가기] &nbsp;&middot;&nbsp; [팀 노션 페이지] (추후추가예정)

</div>

<br/><br/>

## 📆 앱 소개
**"캡처해둔 약속, 일일이 캘린더에 적기 귀찮으셨죠?"**

**그날머지?** 는 메신저 대화, 예약 확정 문자 등 일정이 담긴 **스크린샷을 업로드하면 AI가 날짜와 내용을 분석하여 자동으로 캘린더에 등록**해주는 스마트 일정 관리 앱입니다.

<br/>

## ❓ 프로젝트 개요
* **개발 기간:** 2025.11.17 ~ (진행 중)
* **개발 인원:** 4명 (Team PEOFLE)
* **주요 타겟:** 약속 잡을 때마다, 채용공고가 올라올 때마다, 좋은 행사가 있을 때마다 캡처만 해두고 깜빡하는 현대인, 텍스트 입력이 귀찮은 사용자

<br/>

## 📍 프로젝트 목표
1.  **편의성 극대화:** 이미지 한 장으로 끝나는 일정 등록 경험 제공
2.  **자동화:** OCR(광학 문자 인식)과 LLM(거대 언어 모델)을 활용한 정확한 정보 추출
3.  **통합 관리:** 수동 일정과 자동 일정을 하나의 캘린더에서 직관적으로 관리

<br/>

## 👥 팀 소개: PEOFLE
> **"PEOFLE (피플): Flutter 하는 사람들 / 부캠에서부터 뭉친 우리, 대상 가자잣!!"** 🔥

| 김기혜 | 김성현 | 김여진 | 정재영 |
| :---: | :---: | :---: | :---: |
| <img src="https://via.placeholder.com/100" width="100"> | <img src="https://via.placeholder.com/100" width="100"> | <img src="https://via.placeholder.com/100" width="100"> | <img src="https://via.placeholder.com/100" width="100"> |
| **Leader / Front & Back** | **Front / Back** | **Front / Back** | **Front / Back** |
| • 프로젝트 아키텍처 설계<br>• AI/OCR 서비스 연동<br>• 캘린더 CRUD 및 알림 구현<br>• Firebase Auth/DB 연동 | • (역할을 입력하세요)<br>• (역할을 입력하세요) | • (역할을 입력하세요)<br>• (역할을 입력하세요) | • (역할을 입력하세요)<br>• (역할을 입력하세요) |

<br/>

## 🖥️ 주요 기능

| **1. AI 스크린샷 분석** | **2. 스마트 캘린더** | **3. 수동 관리 & 알림** |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/200x400?text=AI+Upload" width="200" /> | <img src="https://via.placeholder.com/200x400?text=Calendar" width="200" /> | <img src="https://via.placeholder.com/200x400?text=Add+Schedule" width="200" /> |
| **이미지 To 일정**<br>갤러리에서 사진을 선택하면<br>OCR과 AI가 내용을 분석해<br>자동으로 등록합니다. | **월간/리스트 뷰**<br>등록된 일정을 한눈에 확인하고<br>스와이프(Swipe) 제스처로<br>손쉽게 삭제할 수 있습니다. | **커스텀 일정 추가**<br>직접 일정을 추가할 수 있으며,<br>시작 시간 전 알림(Notification)<br>을 설정할 수 있습니다. |

<br/>

## 🤡 사용 기술

### Frontend
* **Framework:** Flutter (Dart)
* **State Management:** `StatefulWidget`
* **UI Libraries:** `table_calendar`, `dotted_border`, `image_picker`
* **Notification:** `flutter_local_notifications`

### Backend & Infra
* **Platform:** Firebase
* **Auth:** Firebase Authentication (Email/Password)
* **Database:** Cloud Firestore
* **AI/ML:**
    * **OCR:** Google ML Kit (`google_mlkit_text_recognition`)
    * **LLM:** Naver HyperClova X (`Clova Studio API`)

<br/>

## 📚 레포지토리
* **Frontend:** [GitHub 주소 입력]
* **Backend:** [GitHub 주소 입력]

<br/>

## 🌳 구조 트리 (Frontend)

**Feature-first Architecture**를 채택하여 기능별로 응집도 높은 구조를 설계했습니다.

```bash
lib/
├── main.dart                  # 앱 진입점 (알림/Firebase 초기화)
├── firebase_options.dart      # Firebase 설정
├── models/                    # 데이터 모델 (Schedule)
├── theme/                     # 디자인 시스템 (AppColors)
├── services/                  # 핵심 로직 분리
│   ├── ai_service.dart        # Naver Clova API 통신
│   ├── cloud_service.dart     # Firestore CRUD
│   ├── ocr_service.dart       # 이미지 텍스트 추출
│   └── notification_service.dart # 로컬 알림 관리
└── features/                  # UI 기능 모듈
    ├── main_navigation/       # 하단 탭 관리
    ├── calendar/              # 캘린더 화면
    │   ├── screen/            # CalendarScreen
    │   └── widgets/           # ScheduleList, Dialog 등
    ├── upload/                # 업로드 화면 (AI 분석 UI)
    └── profile/               # 프로필 화면 (Auth 연동)
```

<br/>

## 📃 Backend & Data
### 💾 DataBase 구조 (Firestore)
사용자별로 독립된 컬렉션을 사용하여 데이터 보안을 유지합니다.

<br/>

## ⭐️ 향후 기대 사항
- 소셜 로그인 추가: 카카오톡, 구글 로그인 지원
- 이미지 인식 고도화: 복잡한 표나 손글씨 인식률 향상
- 일정 공유 기능: 친구나 팀원에게 일정 초대장 보내기
- 캘린더 뷰 확장: 주간(Weekly), 일간(Daily) 뷰 지원
- 알람 전송
