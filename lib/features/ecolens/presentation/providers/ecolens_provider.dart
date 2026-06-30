import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/ecolens/data/services/vision_service.dart';

final visionServiceProvider = Provider<VisionService>((ref) {
  final apiKey = dotenv.env['GOOGLE_VISION_API_KEY'];
  return VisionService(apiKey: apiKey, useMock: apiKey == null);
});

final ecolensAnalysisProvider = FutureProvider.family<VisionResult?, String>((ref, imagePath) {
  if (imagePath.isEmpty) return null;
  final service = ref.watch(visionServiceProvider);
  return service.analyzeImage(imagePath);
});
