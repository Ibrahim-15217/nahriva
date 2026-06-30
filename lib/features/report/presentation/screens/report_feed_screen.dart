import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/report/presentation/providers/report_providers.dart';
import 'package:nahriva/features/report/presentation/screens/submit_report_screen.dart';
import 'package:nahriva/features/report/presentation/widgets/report_card.dart';
import 'package:go_router/go_router.dart';

class ReportFeedScreen extends ConsumerWidget {
  const ReportFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSubmit(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load reports', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No reports yet', style: AppTypography.headline3.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Tap + to submit your first report', style: AppTypography.body.copyWith(color: AppColors.textHint)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(reportsStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: reports.length,
              itemBuilder: (_, i) => ReportCard(
                report: reports[i],
                onTap: () => context.push('/report/${reports[i].id}'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToSubmit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubmitReportScreen()),
    );
  }
}
