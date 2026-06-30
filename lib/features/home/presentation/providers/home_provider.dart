import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/auth/domain/entities/user.dart';

final userProfileProvider = FutureProvider<User?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return null;

  return User(
    uid: doc.id,
    email: doc.data()?['email'] as String? ?? '',
    displayName: doc.data()?['displayName'] as String? ?? '',
    role: doc.data()?['role'] as String? ?? 'user',
    points: doc.data()?['points'] as int? ?? 0,
    reportsCount: doc.data()?['reportsCount'] as int? ?? 0,
    currentStreak: doc.data()?['currentStreak'] as int? ?? 0,
    longestStreak: doc.data()?['longestStreak'] as int? ?? 0,
    lastActiveDate: (doc.data()?['lastActiveDate'] as Timestamp?)?.toDate(),
    lastBonusClaimed: (doc.data()?['lastBonusClaimed'] as Timestamp?)?.toDate(),
    createdAt: (doc.data()?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
});

final totalReportsProvider = FutureProvider<int>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('reports').count().get();
  return snapshot.count ?? 0;
});

final wasteTypesCountProvider = FutureProvider<int>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('reports').get();
  final types = snapshot.docs.map((doc) => doc.data()['wasteType'] as String? ?? '').toSet();
  return types.length;
});

final recentReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('reports')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }).toList();
});
