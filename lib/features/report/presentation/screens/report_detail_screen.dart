import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/report/domain/entities/report_entity.dart';
import 'package:nahriva/features/report/presentation/providers/report_providers.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      appBar: AppBar(title: const Text('Report Detail')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (report) {
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }
          return _ReportDetailContent(reportId: reportId, report: report);
        },
      ),
    );
  }
}

class _ReportDetailContent extends ConsumerWidget {
  final String reportId;
  final ReportEntity report;

  const _ReportDetailContent({required this.reportId, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentVote = currentUser != null ? report.votes[currentUser.uid] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              report.photoUrl,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 260,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatusBadge(status: report.status),
              const SizedBox(width: 12),
              _TypeBadge(type: report.wasteType),
              const Spacer(),
              _ScoreBadge(score: report.trustScore),
            ],
          ),
          const SizedBox(height: 16),
          Text(report.wasteType[0].toUpperCase() + report.wasteType.substring(1),
              style: AppTypography.headline2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(report.address, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(_formatDate(report.timestamp), style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.divider),
          const SizedBox(height: 16),
          Text('Description', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(report.description, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Text('Community Vote', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _VoteButton(
                icon: Icons.thumb_up_rounded,
                label: 'Verify',
                isActive: currentVote == 1,
                count: report.upvotes.length,
                color: AppColors.success,
                onTap: currentUser != null
                    ? () => _vote(ref, currentUser.uid, 1)
                    : null,
              ),
              const SizedBox(width: 24),
              _VoteButton(
                icon: Icons.thumb_down_rounded,
                label: 'Flag',
                isActive: currentVote == -1,
                count: report.votes.values.where((v) => v < 0).length,
                color: AppColors.error,
                onTap: currentUser != null
                    ? () => _vote(ref, currentUser.uid, -1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trust score: ${report.trustScore}/100 — ${_trustScoreHint(report.trustScore)}',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _vote(WidgetRef ref, String userId, int value) {
    ref.read(voteReportProvider).call(reportId, userId, value);
    ref.invalidate(reportDetailProvider(reportId));
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _trustScoreHint(int score) {
    if (score >= 70) return 'Community-verified & resolved';
    if (score >= 30) return 'Community-verified';
    return 'Pending verification';
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _VoteButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? color : AppColors.textHint, size: 28),
            const SizedBox(height: 6),
            Text(label, style: AppTypography.label.copyWith(
              color: isActive ? color : AppColors.textSecondary,
            )),
            const SizedBox(height: 2),
            Text('$count', style: AppTypography.caption.copyWith(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'verified' ? AppColors.success : status == 'resolved' ? AppColors.info : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status[0].toUpperCase() + status.substring(1),
          style: AppTypography.label.copyWith(color: color)),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(type[0].toUpperCase() + type.substring(1),
          style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? AppColors.success : score >= 40 ? AppColors.warning : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: color),
          const SizedBox(width: 4),
          Text('$score%', style: AppTypography.label.copyWith(color: color)),
        ],
      ),
    );
  }
}

final reportDetailProvider = FutureProvider.family<ReportEntity?, String>((ref, id) {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getReportById(id);
});
