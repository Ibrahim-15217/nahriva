import 'package:flutter/material.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class EcoLensScreen extends StatelessWidget {
  const EcoLensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoLens')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'EcoLens AI',
              style: AppTypography.headline2,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon in Phase 6',
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}
