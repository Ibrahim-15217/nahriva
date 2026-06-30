import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSource({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getNotifications(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  Future<int> getUnreadCount(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  static String typeIcon(String type) {
    switch (type) {
      case 'badge': return '🏆';
      case 'report_verified': return '✅';
      case 'report_resolved': return '🔄';
      case 'points': return '⭐';
      case 'challenge': return '🎯';
      case 'streak': return '🔥';
      default: return '📬';
    }
  }
}
