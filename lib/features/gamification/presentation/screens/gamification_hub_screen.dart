import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/auth/data/models/user_model.dart';
import 'package:nahriva/features/gamification/domain/entities/challenge.dart';
import 'package:nahriva/features/gamification/domain/entities/user_badge.dart';
import 'package:nahriva/features/gamification/domain/services/streak_service.dart';
import 'package:nahriva/features/gamification/presentation/widgets/challenge_card.dart';
import 'package:nahriva/features/gamification/presentation/providers/gamification_providers.dart';
import 'package:nahriva/features/gamification/presentation/widgets/badge_card.dart';
import 'package:nahriva/features/gamification/presentation/widgets/leaderboard_tile.dart';


class GamificationHubScreen extends ConsumerStatefulWidget {
  const GamificationHubScreen({super.key});

  @override
  ConsumerState<GamificationHubScreen> createState() => _GamificationHubScreenState();
}

class _GamificationHubScreenState extends ConsumerState<GamificationHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDailyBonus());
  }

  Future<void> _checkDailyBonus() async {
    final canClaim = await ref.read(canClaimDailyBonusProvider.future);
    if (!canClaim || !mounted) return;

    final claimed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.local_fire_department, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            const Text('Daily Login Bonus!'),
          ],
        ),
        content: Text(
          'Log in streak bonus! Claim your ${StreakService.dailyBonusPoints} GreenPoints.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Claim!'),
          ),
        ],
      ),
    );

    if (claimed == true && mounted) {
      await ref.read(claimDailyBonusProvider.future);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProfileProvider);
    final badgesAsync = ref.watch(badgesProvider);
    final streakAsync = ref.watch(streakInfoProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final challengesAsync = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenQuest'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(badgesProvider);
          ref.invalidate(streakInfoProvider);
          ref.invalidate(leaderboardProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPointsCard(context, isDark, userAsync),
              const SizedBox(height: 16),
              _buildStreakCard(context, isDark, streakAsync),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Badges', Icons.emoji_events),
              const SizedBox(height: 8),
              _buildBadgesList(context, isDark, badgesAsync),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Challenges', Icons.flag_outlined),
              const SizedBox(height: 8),
              _buildChallengesList(context, isDark, challengesAsync),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Leaderboard', Icons.leaderboard),
              const SizedBox(height: 8),
              _buildLeaderboardPreview(context, isDark, leaderboardAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, bool isDark, AsyncValue<dynamic> userAsync) {
    return userAsync.when(
      data: (user) {
        final points = user?.points ?? 0;
        final reportsCount = user?.reportsCount ?? 0;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primaryDark.withValues(alpha: 0.8), AppColors.secondaryDark.withValues(alpha: 0.6)]
                  : [AppColors.primaryLight, AppColors.secondaryLight],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.eco, size: 36, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GreenPoints', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$reportsCount reports submitted',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(height: 100, child: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildStreakCard(BuildContext context, bool isDark, AsyncValue<dynamic> streakAsync) {
    return streakAsync.when(
      data: (streak) {
        final currentStreak = streak?.currentStreak ?? 0;
        final longestStreak = streak?.longestStreak ?? 0;
        final emoji = StreakService().getStreakEmoji(currentStreak);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day $currentStreak Streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Longest: $longestStreak days',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesList(BuildContext context, bool isDark, AsyncValue<List<UserBadge>> badgesAsync) {
    return badgesAsync.when(
      data: (badges) {
        if (badges.isEmpty) {
          return const Padding(padding: EdgeInsets.all(16), child: Text('No badges yet'));
        }
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) => BadgeCard(badge: badges[index]),
          ),
        );
      },
      loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
    );
  }

  Widget _buildChallengesList(BuildContext context, bool isDark, AsyncValue<List<Challenge>> challengesAsync) {
    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.construction, size: 40, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('No challenges available', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              ],
            ),
          );
        }
        return Column(children: challenges.map((c) => ChallengeCard(challenge: c)).toList());
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
    );
  }

  Widget _buildLeaderboardPreview(BuildContext context, bool isDark, AsyncValue<List<UserModel>> leaderboardAsync) {
    return leaderboardAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Padding(padding: EdgeInsets.all(16), child: Text('No users yet'));
        }
        final top3 = users.take(3).toList();
        return Column(
          children: [
            ...top3.asMap().entries.map((entry) => LeaderboardTile(user: entry.value, rank: entry.key + 1)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showFullLeaderboard(context, users),
              icon: const Icon(Icons.leaderboard),
              label: const Text('See full leaderboard'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
    );
  }

  void _showFullLeaderboard(BuildContext context, List<UserModel> users) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Leaderboard')),
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          itemBuilder: (context, index) => LeaderboardTile(user: users[index], rank: index + 1),
        ),
      ),
    ));
  }
}
