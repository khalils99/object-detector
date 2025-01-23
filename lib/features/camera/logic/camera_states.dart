import 'package:camera/camera.dart';

import '../data/models/detection_result.dart';

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraInitializing extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final List<DetectionResult>? detectionResult;
  CameraReady(this.controller, {this.detectionResult});
}
class TakingPicture extends CameraReady {
  TakingPicture(super.controller,{super.detectionResult});
}

class ObjectInPosition extends CameraReady {
  ObjectInPosition(super.controller,{super.detectionResult});
}

class CaptureComplete extends CameraState {
  final String imagePath;
  CaptureComplete(this.imagePath);
}

class MoveCloser extends CameraReady {
  MoveCloser(super.controller, {super.detectionResult});
}

class MoveFarther extends CameraReady {
  MoveFarther(super.controller,{super.detectionResult});
}
