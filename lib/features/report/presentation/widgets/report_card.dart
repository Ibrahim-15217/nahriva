import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/report/domain/entities/report_entity.dart';

class ReportCard extends StatelessWidget {
  final ReportEntity report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  report.photoUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 72, height: 72,
                    color: AppColors.surfaceVariant,
                    child: Icon(Icons.broken_image, color: AppColors.textHint, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _WasteTypeChip(type: report.wasteType),
                        const Spacer(),
                        _TrustScoreBadge(score: report.trustScore),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.address,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text('${report.upvotes.length}', style: AppTypography.caption.copyWith(color: AppColors.textHint)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WasteTypeChip extends StatelessWidget {
  final String type;
  const _WasteTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(type, style: AppTypography.caption.copyWith(color: _color, fontWeight: FontWeight.w600)),
    );
  }

  Color get _color {
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

class _TrustScoreBadge extends StatelessWidget {
  final int score;
  const _TrustScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 70 ? AppColors.success : score >= 40 ? AppColors.warning : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$score', style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
