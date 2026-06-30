import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class GuidanceCard extends StatelessWidget {
  final String wasteType;

  const GuidanceCard({super.key, required this.wasteType});

  @override
  Widget build(BuildContext context) {
    final guidance = _guidanceFor(wasteType);

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
              Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text('Disposal Guidance', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(guidance, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _guidanceFor(String type) {
    switch (type) {
      case 'plastic':
        return 'Rinse and recycle plastic bottles and containers. Check the recycling number on the bottom. Avoid single-use plastics where possible.';
      case 'paper':
        return 'Keep paper dry and clean for recycling. Remove any tape, staples, or plastic windows. Cardboard should be flattened before disposal.';
      case 'metal':
        return 'Rinse metal cans before recycling. Aluminum and steel are highly recyclable. Crush cans to save space in recycling bins.';
      case 'glass':
        return 'Rinse glass jars and bottles. Separate by color if required by local recycling. Never put broken glass in recycling bins.';
      case 'organic':
        return 'Compost organic waste when possible. Use a compost bin for fruit/vegetable scraps. Avoid sending organic waste to landfill.';
      default:
        return 'Check local guidelines for proper disposal of this waste type. When in doubt, avoid mixing with recyclables.';
    }
  }
}
