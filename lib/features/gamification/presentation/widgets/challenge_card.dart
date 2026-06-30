import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/gamification/domain/entities/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = challenge.progressFraction;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: challenge.isCompleted
              ? (isDark ? Colors.green.shade300 : Colors.green)
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                challenge.isCompleted ? Icons.emoji_events : Icons.flag_outlined,
                color: challenge.isCompleted
                    ? Colors.amber
                    : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  challenge.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (challenge.rewardPoints > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryDark : AppColors.primaryLight).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco, size: 14, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
                      const SizedBox(width: 2),
                      Text(
                        '+${challenge.rewardPoints}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.isCompleted ? Colors.amber : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${challenge.progress}/${challenge.target}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
