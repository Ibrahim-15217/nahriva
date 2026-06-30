class UserProgress {
  final String id;
  final String type;
  final bool completed;
  final int score;
  final DateTime? completedAt;

  const UserProgress({
    required this.id,
    required this.type,
    this.completed = false,
    this.score = 0,
    this.completedAt,
  });
}
