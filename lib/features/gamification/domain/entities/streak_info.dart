class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final bool loginBonusClaimedToday;

  const StreakInfo({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.loginBonusClaimedToday = false,
  });
}
