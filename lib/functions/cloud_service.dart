import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart'; // [수정] 모델 클래스 가져오기

// -----------------------------------------------------------------------------
// [서버 저장 함수]
// 설명: Schedule 객체 리스트를 받아서 -> Map으로 변환 후 -> Firestore에 저장
// -----------------------------------------------------------------------------
Future<int> saveCalendarEventsToCloud({
  required String userId,
  required List<Schedule> eventList, // [변경] 입력 타입: Schedule 리스트
}) async {
  if (eventList.isEmpty) return 0;

  final db = FirebaseFirestore.instance;
  try {
    final collectionRef = db
        .collection('users')
        .doc(userId)
        .collection('calendar_data');

    WriteBatch batch = db.batch();
    int count = 0;

    // 반복문: Schedule 객체를 하나씩 꺼내서 처리
    for (var schedule in eventList) {

      // 1. 고유 ID 생성 (시간_제목)
      //    객체의 startTime을 문자열로 바꿔서 ID 재료로 사용
      String startString = schedule.startTime.toIso8601String();
      String uniqueId = "${startString}_${schedule.title}";
      uniqueId = uniqueId.replaceAll('/', '_'); // 특수문자 제거

      DocumentReference docRef = collectionRef.doc(uniqueId);

      // 2. [객체 -> Map 변환] (서버가 이해하는 언어로 번역)
      //    Schedule 클래스에는 없는 'saved_at' 같은 서버 전용 필드도 여기서 추가
      Map<String, dynamic> dataToSave = {
        "title": schedule.title,
        "start": startString,
        "end": schedule.endTime.toIso8601String(),
        "description": schedule.reminder, // reminder를 description 필드에 매핑
        "isAI": schedule.isAI,
        "saved_at": FieldValue.serverTimestamp(), // 저장된 시간 (서버 기준)
      };

      batch.set(docRef, dataToSave); // 덮어쓰기 모드
      count++;

      // 배치 처리 (500개 제한)
      if (count % 500 == 0) {
        await batch.commit();
        batch = db.batch();
      }
    }

    if (count % 500 != 0) await batch.commit();

    return count;
  } catch (e) {
    throw Exception("저장 중 오류 발생: $e");
  }
}

// -----------------------------------------------------------------------------
// [서버 불러오기 함수]
// 설명: Firestore에서 Map을 가져와서 -> Schedule 객체로 조립 후 -> 반환
// -----------------------------------------------------------------------------
Future<List<Schedule>> loadCalendarEventsFromCloud({
  required String userId,
}) async {
  final db = FirebaseFirestore.instance;
  List<Schedule> loadedEvents = []; // [변경] 반환할 리스트 타입

  try {
    QuerySnapshot snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('calendar_data')
        .orderBy('saved_at', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    for (var doc in snapshot.docs) {
      // 1. 서버에서 날아온 데이터 (Map)
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // 2. [Map -> 객체 조립] (앱이 이해하는 언어로 번역)
      //    데이터가 비어있거나 깨져있을 경우를 대비해 ??(null check) 사용
      loadedEvents.add(
        Schedule(
          title: data['title'] ?? "제목 없음",
          // 문자열로 저장된 날짜를 다시 DateTime으로 복구
          startTime: DateTime.tryParse(data['start'] ?? "") ?? DateTime.now(),
          endTime: DateTime.tryParse(data['end'] ?? "") ?? DateTime.now(),
          reminder: data['description'] ?? "", // DB의 description을 reminder로 연결
          isAI: data['isAI'] ?? false,
        ),
      );
    }

    return loadedEvents;
  } catch (e) {
    print("불러오기 에러: $e");
    return []; // 에러 나면 빈 리스트 반환
  }
}