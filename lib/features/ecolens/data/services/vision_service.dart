import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VisionResult {
  final String wasteType;
  final double confidence;
  final List<VisionLabel> labels;

  const VisionResult({
    required this.wasteType,
    required this.confidence,
    required this.labels,
  });
}

class VisionLabel {
  final String description;
  final double score;

  const VisionLabel({required this.description, required this.score});
}

class VisionService {
  final String? apiKey;
  final bool useMock;

  VisionService({this.apiKey, this.useMock = false});

  static const _wasteKeywords = {
    'plastic': ['plastic', 'bottle', 'bag', 'container', 'packaging', 'wrapper', 'straw', 'cup'],
    'paper': ['paper', 'cardboard', 'box', 'newspaper', 'magazine', 'document', 'carton'],
    'metal': ['metal', 'can', 'aluminum', 'tin', 'steel', 'iron', 'foil'],
    'glass': ['glass', 'bottle', 'jar', 'window'],
    'organic': ['food', 'organic', 'waste', 'fruit', 'vegetable', 'leaf', 'garden', 'compost'],
  };

  Future<VisionResult> analyzeImage(String imagePath) async {
    final shouldMock = useMock ||
        apiKey == null ||
        apiKey!.isEmpty ||
        apiKey == 'your_google_vision_api_key_here';

    if (shouldMock) {
      return _mockAnalysis();
    }
    return _cloudVisionAnalysis(imagePath);
  }

  Future<VisionResult> _cloudVisionAnalysis(String imagePath) async {
    final bytes = await _readImageBytes(imagePath);
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://vision.googleapis.com/v1/images:annotate?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [{'type': 'LABEL_DETECTION', 'maxResults': 10}],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Vision API error (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final responses = data['responses'] as List?;
    final annotations = responses?.firstOrNull?['labelAnnotations'] as List?;

    if (annotations == null || annotations.isEmpty) {
      return VisionResult(wasteType: 'other', confidence: 0, labels: []);
    }

    final labels = annotations.map((a) => VisionLabel(
      description: a['description'] as String,
      score: (a['score'] as num).toDouble(),
    )).toList();

    return _classifyFromLabels(labels);
  }

  Future<Uint8List> _readImageBytes(String path) async {
    final response = await http.get(Uri.parse(path));
    if (response.statusCode != 200) {
      throw Exception('Failed to read image: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  VisionResult _classifyFromLabels(List<VisionLabel> labels) {
    final scores = <String, double>{};
    for (final wasteType in _wasteKeywords.keys) {
      scores[wasteType] = 0;
    }
    scores['other'] = 0;

    for (final label in labels) {
      final desc = label.description.toLowerCase();
      for (final entry in _wasteKeywords.entries) {
        for (final keyword in entry.value) {
          if (desc.contains(keyword)) {
            scores[entry.key] = (scores[entry.key] ?? 0) + label.score;
          }
        }
      }
    }

    final bestType = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final confidence = (bestType.value * 100).round().clamp(0, 100);

    return VisionResult(
      wasteType: bestType.key,
      confidence: confidence.toDouble(),
      labels: labels,
    );
  }

  VisionResult _mockAnalysis() {
    final types = ['plastic', 'paper', 'metal', 'glass', 'organic'];
    final type = types[Random().nextInt(types.length)];
    final confidence = 50 + Random().nextInt(40);

    return VisionResult(
      wasteType: type,
      confidence: confidence.toDouble(),
      labels: [
        VisionLabel(description: type, score: confidence / 100),
        VisionLabel(description: 'container', score: 0.6),
        VisionLabel(description: 'waste material', score: 0.4),
      ],
    );
  }
}
