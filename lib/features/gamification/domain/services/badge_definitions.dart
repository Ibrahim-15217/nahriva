class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool Function(int reportsCount, int points, double trustScore) condition;

  BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.condition,
  });

  double progress(int reportsCount, int points, double trustScore) {
    switch (id) {
      case 'first_report':
        return (reportsCount >= 1) ? 1.0 : reportsCount / 1.0;
      case 'reporter_10':
        return (reportsCount >= 10) ? 1.0 : reportsCount / 10.0;
      case 'reporter_50':
        return (reportsCount >= 50) ? 1.0 : reportsCount / 50.0;
      case 'trusted_reporter':
        return (trustScore >= 80) ? 1.0 : trustScore / 80.0;
      case 'eco_champion':
        return (points >= 200) ? 1.0 : points / 200.0;
      case 'streak_7':
        return (reportsCount >= 1) ? 1.0 : 0.0;
      default:
        return 0.0;
    }
  }
}

class BadgeCatalog {
  static final List<BadgeDefinition> allBadges = [
    BadgeDefinition(
      id: 'first_report',
      name: 'First Report',
      description: 'Submit your first environmental report',
      icon: '🪴',
      condition: (r, p, t) => r >= 1,
    ),
    BadgeDefinition(
      id: 'reporter_10',
      name: 'Green Reporter',
      description: 'Submit 10 environmental reports',
      icon: '📋',
      condition: (r, p, t) => r >= 10,
    ),
    BadgeDefinition(
      id: 'reporter_50',
      name: 'Eco Guardian',
      description: 'Submit 50 environmental reports',
      icon: '🛡️',
      condition: (r, p, t) => r >= 50,
    ),
    BadgeDefinition(
      id: 'trusted_reporter',
      name: 'Trusted Reporter',
      description: 'Achieve a trust score of 80+',
      icon: '⭐',
      condition: (r, p, t) => t >= 80,
    ),
    BadgeDefinition(
      id: 'eco_champion',
      name: 'Eco Champion',
      description: 'Earn 200 GreenPoints',
      icon: '🏆',
      condition: (r, p, t) => p >= 200,
    ),
  ];

  static Map<String, BadgeDefinition> get badgeMap {
    return {for (final b in allBadges) b.id: b};
  }

  static List<BadgeDefinition> checkNewBadges({
    required int reportsCount,
    required int points,
    required double trustScore,
    required List<String> existingBadgeIds,
  }) {
    return allBadges.where((badge) {
      if (existingBadgeIds.contains(badge.id)) return false;
      return badge.condition(reportsCount, points, trustScore);
    }).toList();
  }
}
