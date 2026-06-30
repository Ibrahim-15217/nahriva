import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nahriva/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.role,
    super.points,
    super.reportsCount,
    super.currentStreak,
    super.longestStreak,
    super.lastActiveDate,
    super.lastBonusClaimed,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
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
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'points': points,
      'reportsCount': reportsCount,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      if (lastActiveDate != null) 'lastActiveDate': Timestamp.fromDate(lastActiveDate!),
      if (lastBonusClaimed != null) 'lastBonusClaimed': Timestamp.fromDate(lastBonusClaimed!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
