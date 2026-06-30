import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onSubmitReport;
  final VoidCallback? onScanEcoLens;
  final VoidCallback? onViewMap;
  final VoidCallback? onOpenQuest;
  final VoidCallback? onOpenLearn;

  const QuickActions({
    super.key,
    this.onSubmitReport,
    this.onScanEcoLens,
    this.onViewMap,
    this.onOpenQuest,
    this.onOpenLearn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Quick Actions', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Submit Report',
              color: AppColors.primary,
              onTap: onSubmitReport ?? () {},
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.visibility_rounded,
              label: 'Scan EcoLens',
              color: AppColors.secondary,
              onTap: onScanEcoLens ?? () {},
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.map_rounded,
              label: 'View Map',
              color: AppColors.info,
              onTap: onViewMap ?? () {},
            )),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _ActionButton(
              icon: Icons.emoji_events_rounded,
              label: 'GreenQuest',
              color: AppColors.success,
              onTap: onOpenQuest ?? () {},
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.menu_book_rounded,
              label: 'Learn',
              color: AppColors.warning,
              onTap: onOpenLearn ?? () {},
            )),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.caption.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
