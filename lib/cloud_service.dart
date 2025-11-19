import 'package:cloud_firestore/cloud_firestore.dart';

// 서버 저장
Future<int> saveCalendarEventsToCloud({
  required String userId,
  required List<Map<String, dynamic>> eventList,
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

    for (var eventData in eventList) {
      String uniqueId = "${eventData['start']}_${eventData['title']}";
      uniqueId = uniqueId.replaceAll('/', '_');
      DocumentReference docRef = collectionRef.doc(uniqueId);

      Map<String, dynamic> dataToSave = Map.from(eventData);

      dataToSave['saved_at'] = FieldValue.serverTimestamp();
      batch.set(docRef, dataToSave); // set은 없으면 생성, 있으면 덮어쓰기 함
      count++;

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

// 서버 불러오기
Future<List<Map<String, dynamic>>> loadCalendarEventsFromCloud({
  required String userId,
}) async {
  final db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> loadedEvents = [];

  try {
    QuerySnapshot snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('calendar_data') // 저장된 곳과 같은 이름
        .orderBy('saved_at', descending: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      loadedEvents.add({
        "start": data['start'] ?? "",
        "title": data['title'] ?? "제목 없음",
        "description": data['description'] ?? "",
      });
    }

    return loadedEvents;
  } catch (e) {
    return [];
  }
}