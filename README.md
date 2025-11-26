# thedaymerge (labs branch)

### 작성자 : 김성현
### 이걸 만든 이유 : 그날머지 리펙토링 실험실 (불안정판)

## (MVVM아키텍쳐 패턴 + repositories + 기능중심 전략)

- MVVM(model view viewmodel로 분리함)
- *model == 데이터구조 
- *view == 오직 UI(혹은 UI관련 로직만 !) (**viewmodel에 바인딩 됨!)
- *viewmodel == 비즈니스 로직 (view와 서비스 사이 중계)
- 서비스는 repositories에 들어감 
- 전체적인 구조는 기능별로 나눠진 형태(features중심)

## 디렉토리 구조도
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

## MVVM을 위한 Provider 패키지 
- 플러터에서는 이와 같은 아키텍쳐 패턴을 위한 라이브러리가 있음 
- Provider을 이용하여 view와 viewmodel을 바인딩 가능 
- 객체로 불러올 필요없이 자동으로 변경사항이 감지되고 업데이트 됨






끝




