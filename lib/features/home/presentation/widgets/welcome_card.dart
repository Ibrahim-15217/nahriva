import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class WelcomeCard extends StatelessWidget {
  final String displayName;
  final int points;

  const WelcomeCard({
    super.key,
    required this.displayName,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.onPrimary.withValues(alpha: 0.2),
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                  style: AppTypography.title.copyWith(color: AppColors.textOnPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $displayName',
                      style: AppTypography.title.copyWith(color: AppColors.textOnPrimary),
                    ),
                    Text(
                      'Let\'s protect our waterways today!',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.textOnPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$points GreenPoints',
                  style: AppTypography.subtitle.copyWith(color: AppColors.textOnPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
