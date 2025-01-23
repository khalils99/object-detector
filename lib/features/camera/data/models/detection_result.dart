import 'dart:ui';

class DetectionResult {
  final String label;
  final double confidence;
  final bool isInPosition;
  final Rect boundingBox;

  DetectionResult( {
    required this.label,
    required this.confidence,
    required this.isInPosition,
    required this.boundingBox,
  });
}
