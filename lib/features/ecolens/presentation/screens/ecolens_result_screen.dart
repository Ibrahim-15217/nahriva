import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/ecolens/data/services/vision_service.dart';
import 'package:nahriva/features/ecolens/presentation/providers/ecolens_provider.dart';
import 'package:nahriva/features/ecolens/presentation/screens/submit_report_screen.dart';
import 'package:nahriva/features/ecolens/presentation/widgets/guidance_card.dart';

class EcoLensResultScreen extends ConsumerWidget {
  final String imagePath;

  const EcoLensResultScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(ecolensAnalysisProvider(imagePath));

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: asyncResult.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing with AI...'),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Analysis failed', style: AppTypography.headline3),
                const SizedBox(height: 8),
                Text('$e', style: AppTypography.body.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Try Again')),
              ],
            ),
          ),
        ),
        data: (result) {
          if (result == null) {
            return const Center(child: Text('No result'));
          }
          return _ResultContent(imagePath: imagePath, result: result);
        },
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final String imagePath;
  final VisionResult result;

  const _ResultContent({required this.imagePath, required this.result});

  @override
  Widget build(BuildContext context) {
    final wasteType = result.wasteType;
    final confidence = result.confidence;
    final confidenceColor = confidence >= 70 ? AppColors.success : confidence >= 40 ? AppColors.warning : AppColors.error;
    final displayName = wasteType[0].toUpperCase() + wasteType.substring(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImage(),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: _wasteTypeColor(wasteType).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_wasteTypeIcon(wasteType), color: _wasteTypeColor(wasteType), size: 28),
                ),
                const SizedBox(height: 12),
                Text(displayName, style: AppTypography.displayMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: confidence / 100,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('$confidence%', style: AppTypography.subtitle.copyWith(color: confidenceColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Confidence', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GuidanceCard(wasteType: wasteType),
          if (result.labels.length > 1) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alternative Suggestions', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  ...result.labels.take(3).map((label) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.label_outline, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(label.description, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _navigateToSubmit(context),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Submit Report'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(imagePath, width: double.infinity, height: 220, fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        height: 220,
        color: AppColors.surfaceVariant,
        child: const Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }

  void _navigateToSubmit(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const SubmitReportScreenFromEcoLens(),
      ),
    );
  }

  IconData _wasteTypeIcon(String type) {
    switch (type) {
      case 'plastic': return Icons.local_drink_outlined;
      case 'paper': return Icons.description_outlined;
      case 'metal': return Icons.hardware_outlined;
      case 'glass': return Icons.liquor_outlined;
      case 'organic': return Icons.eco_outlined;
      default: return Icons.delete_outlined;
    }
  }

  Color _wasteTypeColor(String type) {
    switch (type) {
      case 'plastic': return Colors.red;
      case 'paper': return Colors.blue;
      case 'metal': return Colors.orange;
      case 'glass': return Colors.purple;
      case 'organic': return Colors.green;
      default: return Colors.grey;
    }
  }
}
