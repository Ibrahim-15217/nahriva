import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/core/theme/app_typography.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/report/domain/entities/report_entity.dart';
import 'package:nahriva/features/report/presentation/providers/report_providers.dart';
import 'package:nahriva/features/report/presentation/widgets/photo_picker.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _photoPath;
  String _wasteType = 'plastic';
  Position? _currentPosition;
  bool _isSubmitting = false;
  bool _isLocating = false;

  final _wasteTypes = ['plastic', 'paper', 'metal', 'glass', 'organic', 'other'];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = pos);
    } catch (_) {
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo')),
      );
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Not authenticated');

      final report = ReportEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        wasteType: _wasteType,
        description: _descriptionController.text.trim(),
        photoUrl: '',
        location: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        address: '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
        timestamp: DateTime.now(),
      );

      await ref.read(submitReportProvider).call(report, _photoPath!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Photo', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              PhotoPicker(onPhotoPicked: (path) => _photoPath = path),
              const SizedBox(height: 20),
              Text('Waste Type', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _wasteType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _wasteTypes.map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                onChanged: (v) => setState(() => _wasteType = v!),
              ),
              const SizedBox(height: 20),
              Text('Description', style: AppTypography.title.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe what you found...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    _currentPosition != null ? Icons.location_on : Icons.location_off,
                    color: _currentPosition != null ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLocating
                        ? 'Detecting location...'
                        : _currentPosition != null
                            ? 'Location detected'
                            : 'Location unavailable',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
