import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class QuestProgress extends StatelessWidget {
  final int points;

  const QuestProgress({super.key, required this.points});

  static const int _nextBadgeThreshold = 50;

  @override
  Widget build(BuildContext context) {
    final progress = (points / _nextBadgeThreshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GreenQuest Progress', style: AppTypography.label.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '$points / $_nextBadgeThreshold points to next badge',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
