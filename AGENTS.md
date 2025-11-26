# AGENTS2.md

## 0. 기본 사항 **주의!!**



- model은 다음과 같이 형성해야함 

- 1. user_model
- email(String)
- passord(x)는 오직 firebase 로그인 인증 시에만 사용
- 2. schedule_model
- schedule name(String)
- start time (DateTime)
- end time (DateTime)

- 2번과 관련된 주의사항 
- start time의 yyyy mm dd와 endtime의 yyyy mm dd가 같을 시 
- 일정 표시를 해당 날짜 당일로 표시해야함
- 만약 다를 시 
- 일정 표시를 start time ~ end time으로 간주해야함.



## 1. 프로젝트 개요
이 프로젝트는 **Flutter & Firebase** 기반의 **일정 관리(Schedule) 및 AI OCR 스캔 앱**입니다.
**MVVM 패턴**과 **Provider**를 사용하여 상태를 관리하며, 기능(Feature) 단위의 디렉토리 구조를 따릅니다.
AI OCR에는 mlkit을 사용할 예정임(단 이는 백엔드 개발자가 구현하므로 여기서 구현하지 않음)

## 2. 기술 스택
- **Framework:** Flutter (Dart)
- **Backend:** Firebase (Authentication, Firestore)
- **State Management:** Provider
- **Architecture:** MVVM (Model - View - ViewModel) + Repository Pattern

## 3. 아키텍처 원칙 (Architecture Rules)

### 3.1. 계층 구조 (Layering)
1.  **View (UI):**
    - 화면을 그리는 역할만 수행합니다.
    - 비즈니스 로직을 포함하지 않습니다.
    - `context.watch/read`를 통해 ViewModel을 구독합니다.
2.  **ViewModel (State Management):**
    - `ChangeNotifier`를 상속받습니다.
    - View의 상태를 관리합니다.
    - **절대 `firebase_auth`, `cloud_firestore` 등 외부 라이브러리를 직접 import 하지 않습니다.**
    - 오직 `Repository`와 `Model`에만 의존합니다.
3.  **Repository (Data Logic):**
    - 데이터의 로드(Load), 저장(Save), 변환(Transform)을 담당합니다.
    - Firebase SDK(Firestore, Auth) 호출 코드는 이곳에 위치합니다.
    - Raw Data(Snapshot)를 앱의 도메인 `Model`로 변환하여 ViewModel에 반환합니다.
    - *참고: 복잡도를 줄이기 위해 `Data Source` 계층을 별도로 두지 않고, Repository 파일 내부에서 API 호출과 전처리를 모두 수행합니다.*

### 3.2. 의존성 주입 (DI)
- `main.dart`의 `MultiProvider`에서 모든 Repository와 ViewModel을 생성하고 주입합니다.
- ViewModel은 생성자를 통해 Repository 인스턴스를 주입받습니다.

## 4. 디렉토리 구조 (Directory Structure)

**Feature-first** 전략을 따르며, 기능별로 폴더를 응집도 있게 구성합니다.

```
./lib
├── cores //전역적이고 고정된 파일들 
│   ├── app_color.dart //미리 고정된 색상 
│   ├── app_const_number.dart //미리 고정된 수치 
│   └── firebase_options.dart 
├── features //기능 중심 분리 
│   ├── auth //로그인,회원가입,로그아웃 관련 기능 
│   │   ├── models
│   │   │   └── user_model.dart // 
│   │   ├── repositories
│   │   │   └── auth_cloud_service.dart
│   │   ├── viewmodels
│   │   │   └── auth_viewmodel.dart
│   │   └── views
│   │       ├── components
│   │       └── screens
│   │           ├── profile_page.dart
│   │           └── start_page.dart
│   ├── main_navigation
│   │   ├── viewmodels
│   │   │   └── navigation_viewmodel.dart
│   │   └── views
│   │       └── main_navigation_screen.dart
│   └── schedule
│       ├── models
│       │   └── schedule_model.dart
│       ├── repositories
│       │   ├── ai_and_ocr
│       │   │   ├── ai_service.dart
│       │   │   └── ocr_service.dart
│       │   └── save_and_load
│       │       └── cloud_service.dart
│       ├── viewmodels
│       │   └── schedule_viewmodel.dart
│       └── views
│           ├── components
│           │   ├── calendar_component.dart
│           │   └── list_item_component.dart
│           └── screens
│               ├── default_home_page.dart
│               └── upload_page.dart
├── app.dart
├── main.dart
```

## 5. 주요 기능 구현 가이드

### 5.1. 인증 (Auth)
- `main.dart` 실행 시 `AuthRepository` -> `AuthViewModel` 순으로 초기화합니다.
- `AuthGate` 위젯(`features/auth/views/auth_gate.dart`)을 사용하여 로그인 상태(`user != null`)에 따라 `LoginScreen` 또는 `MainScreen`을 자동으로 전환합니다.
- **Repository:** `Stream<User?>`를 `Stream<UserModel?>`로 매핑하여 제공합니다.

### 5.2. 네비게이션 (Navigation)
- 로그인 후 진입하는 `MainScreen`은 `IndexedStack`과 `BottomNavigationBar`를 사용합니다.
- 탭 상태는 `MainNavViewModel`에서 관리합니다.

### 5.3. 일정 및 AI (Schedule & OCR)
- **ViewModel:** `ScheduleViewModel` 하나가 두 개의 Repository(`ScheduleRepository`, `ScheduleAiRepository`)를 모두 멤버 변수로 가집니다.
- **시나리오 (OCR 업로드):**
    1. View에서 이미지 선택.
    2. ViewModel이 `ScheduleAiRepository.analyzeImage()` 호출 -> 분석된 텍스트 반환.
    3. View가 반환된 텍스트를 입력 필드에 채움.
    4. 사용자가 [저장] 클릭.
    5. ViewModel이 `ScheduleRepository.addSchedule()` 호출 -> DB 저장.
    6. ViewModel이 목록 갱신(`fetchSchedules`).
  


## 6. 코딩 컨벤션 (Coding Conventions)

- **Models:** 모든 데이터 모델은 `fromJson`과 `toJson` 메서드를 포함해야 합니다.
- **Imports:** Relative Path(`../../`) 대신 가급적 Package Path(`package:app_name/...`) 사용을 권장
- **Async/Await:** 비동기 작업 시 `FutureBuilder` 선호합니다.
- **Naming:**
    - 파일명: `snake_case` (e.g., `auth_repository.dart`)
    - 클래스명: `PascalCase` (e.g., `AuthRepository`)
    - 변수/함수명: `camelCase` (e.g., `fetchSchedules`)

