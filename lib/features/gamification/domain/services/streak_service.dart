import 'package:nahriva/features/gamification/domain/entities/streak_info.dart';

class StreakService {
  static const int dailyBonusPoints = 5;
  static const int maxStreakDays = 30;

  StreakInfo calculateStreak({
    required DateTime? lastActiveDate,
    required int currentStreak,
    required int longestStreak,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = lastActiveDate != null
        ? DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day)
        : null;

    if (lastActive == null) {
      return const StreakInfo(currentStreak: 1, longestStreak: 1);
    }

    final difference = today.difference(lastActive).inDays;

    if (difference == 0) {
      return StreakInfo(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        loginBonusClaimedToday: true,
      );
    }

    if (difference == 1) {
      final newStreak = currentStreak + 1;
      return StreakInfo(
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      );
    }

    return const StreakInfo(currentStreak: 1, longestStreak: 1);
  }

  StreakInfo claimDailyLoginBonus(StreakInfo current) {
    if (current.loginBonusClaimedToday) return current;
    return StreakInfo(
      currentStreak: current.currentStreak,
      longestStreak: current.longestStreak,
      loginBonusClaimedToday: true,
    );
  }

  String getStreakEmoji(int streak) {
    if (streak >= 21) return '🔥';
    if (streak >= 14) return '💪';
    if (streak >= 7) return '⭐';
    if (streak >= 3) return '✨';
    return '🌱';
  }
}
