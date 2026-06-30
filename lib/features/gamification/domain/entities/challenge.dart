class Challenge {
  final String id;
  final String title;
  final String description;
  final int target;
  final int progress;
  final int rewardPoints;
  final DateTime expiresAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    this.progress = 0,
    this.rewardPoints = 0,
    required this.expiresAt,
  });

  bool get isCompleted => progress >= target;
  double get progressFraction => (progress / target).clamp(0.0, 1.0);
}
