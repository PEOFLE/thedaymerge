import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thedaymerge/features/schedule/models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Stream<List<ScheduleModel>> getSchedules() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScheduleModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addSchedule({
    required String scheduleName,
    required DateTime startTime,
    required DateTime endTime,
    bool isAI = false,
  }) async {
    final uid = _userId;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('schedules').add({
      'scheduleName': scheduleName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isAI': isAI,
    });
  }

  Future<void> deleteSchedule(String scheduleId) async {
    final uid = _userId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .doc(scheduleId)
        .delete();
  }
}
