import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/gamification/domain/entities/user_badge.dart';

class BadgeCard extends StatelessWidget {
  final UserBadge badge;

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.isUnlocked
            ? (isDark ? AppColors.primaryDark.withValues(alpha: 0.15) : AppColors.primaryLight.withValues(alpha: 0.1))
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        border: badge.isUnlocked
            ? Border.all(color: isDark ? AppColors.primaryDark : AppColors.primaryLight, width: 1.5)
            : Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badge.isUnlocked
                  ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 4),
          if (!badge.isUnlocked)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 4,
                backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              ),
            )
          else
            Icon(Icons.check_circle, size: 16, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
        ],
      ),
    );
  }
}
