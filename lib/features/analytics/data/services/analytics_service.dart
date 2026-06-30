import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestoreInstance})
      : _firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<void> trackEvent({
    required String uid,
    required String eventName,
    Map<String, dynamic>? properties,
  }) async {
    try {
      await _firestore.collection('analytics').add({
        'uid': uid,
        'eventName': eventName,
        'properties': properties ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> trackLogin(String uid) =>
      trackEvent(uid: uid, eventName: 'login');

  Future<void> trackRegister(String uid) =>
      trackEvent(uid: uid, eventName: 'register');

  Future<void> trackReportSubmitted(String uid, {required String reportId, required String wasteType}) =>
      trackEvent(uid: uid, eventName: 'report_submitted', properties: {
        'reportId': reportId,
        'wasteType': wasteType,
      });

  Future<void> trackVote(String uid, {required String reportId, required String voteType}) =>
      trackEvent(uid: uid, eventName: 'vote', properties: {
        'reportId': reportId,
        'voteType': voteType,
      });

  Future<void> trackBadgeEarned(String uid, {required String badgeId}) =>
      trackEvent(uid: uid, eventName: 'badge_earned', properties: {
        'badgeId': badgeId,
      });

  Future<void> trackQuizCompleted(String uid, {required String quizId, required int score}) =>
      trackEvent(uid: uid, eventName: 'quiz_completed', properties: {
        'quizId': quizId,
        'score': score,
      });

  Future<void> trackArticleRead(String uid, {required String articleId}) =>
      trackEvent(uid: uid, eventName: 'article_read', properties: {
        'articleId': articleId,
      });

  Future<void> trackQuestOpen(String uid) =>
      trackEvent(uid: uid, eventName: 'quest_open');

  Future<void> trackEcoLensIdentify(String uid, {required String result}) =>
      trackEvent(uid: uid, eventName: 'ecolens_identify', properties: {
        'result': result,
      });

  Future<Map<String, dynamic>> getPlatformStats() async {
    final usersCount = await _firestore.collection('users').count().get();
    final reportsCount = await _firestore.collection('reports').count().get();

    final reportsSnapshot = await _firestore.collection('reports').get();
    int resolved = 0, verified = 0;
    for (final doc in reportsSnapshot.docs) {
      final status = doc.data()['status'] as String?;
      if (status == 'resolved') resolved++;
      if (status == 'verified') verified++;
    }

    return {
      'totalUsers': usersCount.count ?? 0,
      'totalReports': reportsCount.count ?? 0,
      'resolvedReports': resolved,
      'verifiedReports': verified,
    };
  }
}
