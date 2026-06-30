import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/ecolens/presentation/screens/ecolens_result_screen.dart';

class EcoLensScreen extends ConsumerStatefulWidget {
  const EcoLensScreen({super.key});

  @override
  ConsumerState<EcoLensScreen> createState() => _EcoLensScreenState();
}

class _EcoLensScreenState extends ConsumerState<EcoLensScreen> {
  String? _imagePath;
  bool _isAnalyzing = false;

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.gallery); },
            ),
          ],
        ),
      ),
    );
  }

  void _analyze() {
    if (_imagePath == null) return;
    setState(() => _isAnalyzing = true);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EcoLensResultScreen(imagePath: _imagePath!),
      ),
    ).then((_) => setState(() => _isAnalyzing = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoLens AI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _showSourcePicker,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _buildImagePreview(),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(Icons.visibility_rounded, size: 40, color: AppColors.primary),
                            ),
                            const SizedBox(height: 20),
                            Text('Tap to capture waste', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Text('Take a photo of the waste item', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_imagePath != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showSourcePicker,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isAnalyzing ? null : _analyze,
                      icon: _isAnalyzing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_fix_high_rounded),
                      label: const Text('Identify'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Image.network(_imagePath!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
  }
}
