import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/auth/data/models/user_model.dart';

class LeaderboardTile extends StatelessWidget {
  final UserModel user;
  final int rank;

  const LeaderboardTile({super.key, required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rank <= 3
                    ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${user.reportsCount} reports',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco, size: 18, color: isDark ? AppColors.primaryDark : AppColors.primaryLight),
              const SizedBox(width: 4),
              Text(
                '${user.points}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
