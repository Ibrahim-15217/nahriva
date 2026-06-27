class User {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final int points;
  final int reportsCount;
  final DateTime createdAt;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = 'user',
    this.points = 0,
    this.reportsCount = 0,
    required this.createdAt,
  });

  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? role,
    int? points,
    int? reportsCount,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      points: points ?? this.points,
      reportsCount: reportsCount ?? this.reportsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
