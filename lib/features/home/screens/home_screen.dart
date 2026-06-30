import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/home/presentation/providers/home_provider.dart';
import 'package:nahriva/features/home/presentation/widgets/impact_summary.dart';
import 'package:nahriva/features/home/presentation/widgets/quest_progress.dart';
import 'package:nahriva/features/home/presentation/widgets/quick_actions.dart';
import 'package:nahriva/features/home/presentation/widgets/recent_reports_feed.dart';
import 'package:nahriva/features/home/presentation/widgets/welcome_card.dart';
import 'package:nahriva/features/gamification/presentation/screens/gamification_hub_screen.dart';
import 'package:nahriva/features/education/presentation/screens/education_hub_screen.dart';
import 'package:nahriva/features/home/screens/home_shell.dart';
import 'package:nahriva/features/notifications/presentation/providers/notification_providers.dart';
import 'package:nahriva/features/notifications/presentation/screens/notification_screen.dart';
import 'package:nahriva/features/gamification/presentation/providers/gamification_providers.dart' hide userProfileProvider;
import 'package:nahriva/features/report/presentation/screens/submit_report_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final totalReportsAsync = ref.watch(totalReportsProvider);
    final wasteTypesAsync = ref.watch(wasteTypesCountProvider);
    final recentReportsAsync = ref.watch(recentReportsProvider);

    final unreadCountAsync = ref.watch(unreadCountProvider);
    ref.watch(checkAndAwardBadgesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nahriva'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
              ),
              unreadCountAsync.when(
                data: (count) => count > 0
                    ? Positioned(
                        right: 6, top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(ref),
        child: ListView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
          children: [
            userAsync.when(
              loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => _ErrorCard(message: 'Could not load profile'),
              data: (user) => user != null
                  ? WelcomeCard(displayName: user.displayName, points: user.points)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
              totalReportsAsync.when(
              loading: () => ImpactSummary(totalReports: 0, wasteTypes: 0),
              error: (_, _) => ImpactSummary(totalReports: 0, wasteTypes: 0),
              data: (total) => wasteTypesAsync.when(
                loading: () => ImpactSummary(totalReports: total, wasteTypes: 0),
                error: (_, _) => ImpactSummary(totalReports: total, wasteTypes: 0),
                data: (types) => ImpactSummary(totalReports: total, wasteTypes: types),
              ),
            ),
            const SizedBox(height: 16),
            QuickActions(
              onSubmitReport: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
              onScanEcoLens: () => _goToTab(context, 1),
              onViewMap: () => _goToTab(context, 2),
              onOpenQuest: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GamificationHubScreen())),
              onOpenLearn: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EducationHubScreen())),
            ),
            const SizedBox(height: 16),
            userAsync.when(
              loading: () => const SizedBox(),
              error: (_, _) => const SizedBox(),
              data: (user) => user != null ? QuestProgress(points: user.points) : const SizedBox(),
            ),
            const SizedBox(height: 24),
            recentReportsAsync.when(
              loading: () => const RecentReportsFeed(reports: [], isLoading: true),
              error: (_, _) => const RecentReportsFeed(reports: []),
              data: (reports) => RecentReportsFeed(reports: reports),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(userProfileProvider);
    ref.invalidate(totalReportsProvider);
    ref.invalidate(wasteTypesCountProvider);
    ref.invalidate(recentReportsProvider);
  }
}

void _goToTab(BuildContext context, int index) {
  NavigationShellScope.of(context).goBranch(index);
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.textOnPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.textOnPrimary)),
          ),
        ],
      ),
    );
  }
}
