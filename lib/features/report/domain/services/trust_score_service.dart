class TrustScoreService {
  static const int verifiedThreshold = 30;
  static const int resolvedThreshold = 70;

  static int calculateTrustScore({
    required Map<String, int> votes,
    required Map<String, int> voterReputation,
  }) {
    double score = 50;

    for (final entry in votes.entries) {
      final reputation = voterReputation[entry.key] ?? 0;
      final weight = 1 + (reputation / 100);
      score += entry.value * weight;
    }

    return score.round().clamp(0, 100);
  }

  static String determineStatus(int trustScore) {
    if (trustScore >= resolvedThreshold) return 'resolved';
    if (trustScore >= verifiedThreshold) return 'verified';
    return 'pending';
  }
}
