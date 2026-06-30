import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class ImpactSummary extends StatelessWidget {
  final int totalReports;
  final int wasteTypes;

  const ImpactSummary({
    super.key,
    required this.totalReports,
    required this.wasteTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.report_rounded,
            label: 'Total Reports',
            value: '$totalReports',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.category_rounded,
            label: 'Waste Types',
            value: '$wasteTypes',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.headline2.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
