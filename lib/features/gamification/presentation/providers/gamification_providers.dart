import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/auth/data/models/user_model.dart';
import 'package:nahriva/features/auth/domain/entities/user.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/gamification/data/datasources/gamification_remote_data_source.dart';
import 'package:nahriva/features/gamification/domain/entities/challenge.dart';
import 'package:nahriva/features/gamification/domain/entities/streak_info.dart';
import 'package:nahriva/features/gamification/domain/entities/user_badge.dart';
import 'package:nahriva/features/gamification/domain/services/badge_definitions.dart';
import 'package:nahriva/features/gamification/domain/services/streak_service.dart';

final gamificationDataSourceProvider = Provider<GamificationRemoteDataSource>((ref) {
  return GamificationRemoteDataSource();
});

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

final streakInfoProvider = FutureProvider<StreakInfo?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(null);
  return _calculateStreak(ref, user);
});

Future<StreakInfo> _calculateStreak(Ref ref, User user) async {
  final service = ref.watch(streakServiceProvider);
  final dataSource = ref.watch(gamificationDataSourceProvider);

  final result = service.calculateStreak(
    lastActiveDate: user.lastActiveDate,
    currentStreak: user.currentStreak,
    longestStreak: user.longestStreak,
  );

  await dataSource.updateStreak(user.uid, result.currentStreak, result.longestStreak);
  return result;
}

final canClaimDailyBonusProvider = FutureProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Future.value(false);
  return _checkDailyBonus(ref, user);
});

Future<bool> _checkDailyBonus(Ref ref, User user) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final lastClaimed = user.lastBonusClaimed;
  if (lastClaimed == null) return true;
  final claimedDay = DateTime(lastClaimed.year, lastClaimed.month, lastClaimed.day);
  return today != claimedDay;
}

final claimDailyBonusProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final dataSource = ref.watch(gamificationDataSourceProvider);
  final newPoints = user.points + StreakService.dailyBonusPoints;
  await dataSource.claimDailyBonus(user.uid, newPoints);
  ref.invalidate(userProfileProvider);
  ref.invalidate(canClaimDailyBonusProvider);
});

final badgesProvider = FutureProvider<List<UserBadge>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final dataSource = ref.watch(gamificationDataSourceProvider);
  final existingBadgeIds = await dataSource.getUserBadgeIds(user.uid);
  final reportsCount = await _getUserReportsCount(user.uid);
  final trustScore = await _getUserTrustScore(user.uid);

  final now = DateTime.now();
  return BadgeCatalog.allBadges.map((def) {
    final isUnlocked = existingBadgeIds.contains(def.id);
    return UserBadge(
      id: def.id,
      name: def.name,
      description: def.description,
      icon: def.icon,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? now : null,
      progress: def.progress(reportsCount, user.points, trustScore),
    );
  }).toList();
});

Future<int> _getUserReportsCount(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('reports')
      .where('userId', isEqualTo: uid)
      .count()
      .get();
  return snapshot.count ?? 0;
}

Future<double> _getUserTrustScore(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('reports')
      .where('userId', isEqualTo: uid)
      .get();
  if (snapshot.docs.isEmpty) return 0;

  double totalScore = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();
    final votes = data['votes'] as Map<String, dynamic>? ?? {};
    int total = 0;
    votes.forEach((key, value) {
      total += (value as int?) ?? 0;
    });
    totalScore += 50 + total;
  }
  return totalScore / snapshot.docs.length;
}

final checkNewBadgesProvider = Provider<AsyncValue<List<UserBadge>>>((ref) {
  final badgesAsync = ref.watch(badgesProvider);
  return badgesAsync;
});

final leaderboardProvider = FutureProvider<List<UserModel>>((ref) async {
  final dataSource = ref.watch(gamificationDataSourceProvider);
  return dataSource.getLeaderboard(limit: 50);
});

final challengesProvider = FutureProvider<List<Challenge>>((ref) async {
  final dataSource = ref.watch(gamificationDataSourceProvider);
  final challengeData = await dataSource.getChallenges();

  if (challengeData.isNotEmpty) {
    return challengeData.map((data) {
      return Challenge(
        id: data['id'] as String,
        title: data['title'] as String? ?? 'Challenge',
        description: data['description'] as String? ?? '',
        target: data['target'] as int? ?? 1,
        progress: data['progress'] as int? ?? 0,
        rewardPoints: data['rewardPoints'] as int? ?? 0,
        expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      );
    }).toList();
  }

  return _defaultChallenges(ref);
});

List<Challenge> _defaultChallenges(Ref ref) {
  final now = DateTime.now();
  return [
    Challenge(
      id: 'report_5_week',
      title: 'Week Warrior',
      description: 'Submit 5 environmental reports this week',
      target: 5,
      rewardPoints: 30,
      expiresAt: now.add(Duration(days: 7 - now.weekday)),
    ),
    Challenge(
      id: 'ecolens_3',
      title: 'AI Explorer',
      description: 'Identify 3 waste items using EcoLens',
      target: 3,
      rewardPoints: 20,
      expiresAt: now.add(Duration(days: 7 - now.weekday)),
    ),
    Challenge(
      id: 'upvotes_10',
      title: 'Community Voice',
      description: 'Receive 10 upvotes on your reports',
      target: 10,
      rewardPoints: 25,
      expiresAt: now.add(Duration(days: 7 - now.weekday)),
    ),
  ];
}

final checkAndAwardBadgesProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;

  final dataSource = ref.watch(gamificationDataSourceProvider);
  final existingBadgeIds = await dataSource.getUserBadgeIds(user.uid);
  final reportsCount = await _getUserReportsCount(user.uid);
  final trustScore = await _getUserTrustScore(user.uid);

  final newBadges = BadgeCatalog.checkNewBadges(
    reportsCount: reportsCount,
    points: user.points,
    trustScore: trustScore,
    existingBadgeIds: existingBadgeIds,
  );

  for (final badge in newBadges) {
    await dataSource.awardBadge(user.uid, badge.id);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .add({
      'title': 'Badge Earned: ${badge.name}',
      'body': badge.description,
      'type': 'badge',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  if (newBadges.isNotEmpty) {
    ref.invalidate(badgesProvider);
  }
});

final userProfileProvider = FutureProvider<User?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!doc.exists) return null;

  final data = doc.data()!;
  return User(
    uid: doc.id,
    email: data['email'] as String? ?? '',
    displayName: data['displayName'] as String? ?? '',
    role: data['role'] as String? ?? 'user',
    points: data['points'] as int? ?? 0,
    reportsCount: data['reportsCount'] as int? ?? 0,
    currentStreak: data['currentStreak'] as int? ?? 0,
    longestStreak: data['longestStreak'] as int? ?? 0,
    lastActiveDate: (data['lastActiveDate'] as Timestamp?)?.toDate(),
    lastBonusClaimed: (data['lastBonusClaimed'] as Timestamp?)?.toDate(),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
});
