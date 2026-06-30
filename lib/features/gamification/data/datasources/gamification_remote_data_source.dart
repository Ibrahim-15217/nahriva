import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nahriva/features/auth/data/models/user_model.dart';

class GamificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  GamificationRemoteDataSource({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<List<UserModel>> getLeaderboard({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('points', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  Future<void> updatePoints(String uid, int points) async {
    await _firestore.collection('users').doc(uid).update({'points': points});
  }

  Future<void> updateReportsCount(String uid, int count) async {
    await _firestore.collection('users').doc(uid).update({'reportsCount': count});
  }

  Future<void> awardBadge(String uid, String badgeId) async {
    await _firestore.collection('users').doc(uid).collection('badges').doc(badgeId).set({
      'badgeId': badgeId,
      'unlockedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getUserBadgeIds(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('badges')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> updateStreak(String uid, int current, int longest) async {
    await _firestore.collection('users').doc(uid).update({
      'currentStreak': current,
      'longestStreak': longest,
      'lastActiveDate': Timestamp.now(),
    });
  }

  Future<void> claimDailyBonus(String uid, int points) async {
    await _firestore.collection('users').doc(uid).update({
      'points': points,
      'lastBonusClaimed': Timestamp.now(),
    });
  }

  Future<Map<String, dynamic>?> getStreakData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getChallenges() async {
    final snapshot = await _firestore.collection('challenges').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateChallengeProgress(String uid, String challengeId, int progress) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('challengeProgress')
        .doc(challengeId)
        .set({'progress': progress, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
