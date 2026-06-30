import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';

class PhotoPicker extends StatefulWidget {
  final ValueChanged<String> onPhotoPicked;

  const PhotoPicker({super.key, required this.onPhotoPicked});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  String? _photoPath;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _photoPath = image.path);
      widget.onPhotoPicked(image.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photoPath = image.path);
      widget.onPhotoPicked(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: _photoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(_photoPath!, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(Icons.image, size: 48, color: AppColors.textHint),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 40, color: AppColors.textHint),
                  const SizedBox(height: 8),
                  Text('Tap to add photo', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                ],
              ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () { Navigator.pop(context); _pickPhoto(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () { Navigator.pop(context); _pickFromGallery(); },
            ),
            if (_photoPath != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                onTap: () { Navigator.pop(context); setState(() => _photoPath = null); },
              ),
          ],
        ),
      ),
    );
  }
}
