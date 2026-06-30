import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class RecentReportsFeed extends StatelessWidget {
  final List<Map<String, dynamic>> reports;
  final bool isLoading;

  const RecentReportsFeed({
    super.key,
    required this.reports,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Latest Reports', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          ...List.generate(3, (_) => _ReportShimmer())
        else if (reports.isEmpty)
          _EmptyState()
        else
          ...reports.map((report) => _ReportCard(report: report)),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final wasteType = report['wasteType'] as String? ?? 'Unknown';
    final location = report['address'] as String? ?? 'Unknown location';
    final trustScore = report['trustScore'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _wasteTypeColor(wasteType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_wasteTypeIcon(wasteType), color: _wasteTypeColor(wasteType), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wasteType, style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trustScore >= 50 ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$trustScore',
              style: AppTypography.caption.copyWith(
                color: trustScore >= 50 ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _wasteTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Icons.local_drink_outlined;
      case 'paper': return Icons.description_outlined;
      case 'metal': return Icons.hardware_outlined;
      case 'glass': return Icons.liquor_outlined;
      case 'organic': return Icons.eco_outlined;
      default: return Icons.delete_outlined;
    }
  }

  Color _wasteTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'plastic': return Colors.red;
      case 'paper': return Colors.blue;
      case 'metal': return Colors.orange;
      case 'glass': return Colors.purple;
      case 'organic': return Colors.green;
      default: return Colors.grey;
    }
  }
}

class _ReportShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(
            color: AppColors.disabled,
            borderRadius: BorderRadius.circular(10),
          )),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(4),
                )),
                const SizedBox(height: 6),
                Container(width: 150, height: 10, decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(4),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text('No reports yet', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Be the first to report!', style: AppTypography.caption.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }
}
