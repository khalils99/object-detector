import 'package:camera/camera.dart';

abstract class CameraEvent {}

class InitializeCamera extends CameraEvent {
  final List? objects;
  InitializeCamera(this.objects);
}

class ProcessFrame extends CameraEvent {
  final CameraImage frameData;
  final List? objects;
  ProcessFrame(this.frameData, this.objects);
}

class CaptureImage extends CameraEvent {}
