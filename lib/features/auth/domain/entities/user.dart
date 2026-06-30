class User {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final int points;
  final int reportsCount;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime? lastBonusClaimed;
  final DateTime createdAt;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'user',
    this.points = 0,
    this.reportsCount = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.lastBonusClaimed,
    required this.createdAt,
  });

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    int? points,
    int? reportsCount,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? lastBonusClaimed,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      points: points ?? this.points,
      reportsCount: reportsCount ?? this.reportsCount,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lastBonusClaimed: lastBonusClaimed ?? this.lastBonusClaimed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
