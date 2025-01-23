import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../data/models/detection_result.dart';
import '../data/repositories/detection_repository.dart';
import 'camera_events.dart';
import 'camera_states.dart';
import 'package:image/image.dart' as img;

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final DetectionRepository repository;
  CameraController? _controller;

  CameraBloc(this.repository) : super(CameraInitial()) {
    on<InitializeCamera>(_initializeCamera);
    on<ProcessFrame>(_processFrame);
    on<CaptureImage>(_captureImage);
  }

  Future<void> _initializeCamera(
      InitializeCamera event, Emitter<CameraState> emit) async {
    emit(CameraInitializing());
    final cameras = await availableCameras();
    _controller = CameraController(
        cameras.firstWhere((e) => e.lensDirection == CameraLensDirection.back),
        ResolutionPreset.high);
    await _controller!.initialize();
    _controller!.startImageStream((image) {
      if (!isClosed && state is! TakingPicture)
        add(ProcessFrame(image, event.objects));
    });

    emit(CameraReady(_controller!));
  }

  Future<void> _processFrame(
      ProcessFrame event, Emitter<CameraState> emit) async {
    try {
      final objects = await repository.detectObjects(event.frameData);
      // print("objects ${objects.map((e) => e.labels.firstOrNull?.text)}");
      if (objects.isNotEmpty) {
        if (objects
            .where((e) => e.labels.firstOrNull?.text != null)
            .isNotEmpty) {
          bool? checkTags = (event.objects?.first['tags'] as List?)
              ?.where((element) => objects
                  .where((e) =>
                      e.labels.isNotEmpty &&
                      (e.labels.first.text
                              .toLowerCase()
                              .contains(element.toString().toLowerCase()) ==
                          true))
                  .isNotEmpty)
              .isNotEmpty;
          if (event.objects?.contains("Other") == true ||
              objects
                  .where((e) =>
                      e.labels.isNotEmpty &&
                          (e.labels.first.text.toLowerCase().contains(
                                  (event.objects ?? [])
                                      .first
                                      .toString()
                                      .toLowerCase()) ==
                              true) ||
                      (checkTags ?? false))
                  .isNotEmpty) {
            final firstObject = objects.first;

            final isInPosition = firstObject.boundingBox.width <= 40.h &&
                firstObject.boundingBox.height <= 40.h &&
                firstObject.boundingBox.left >= ((100.w - 40.h) / 2);
            final moveFarther = firstObject.boundingBox.width > 40.h;
            final res = DetectionResult(
                label: firstObject.labels.first.text,
                confidence: firstObject.labels.first.confidence,
                isInPosition: isInPosition,
                boundingBox: firstObject.boundingBox);
            if (moveFarther) {
              emit(MoveFarther(_controller!, detectionResult: [res]));
              return;
            }
            if (isInPosition) {
              final moveCloser = firstObject.boundingBox.width < 25.h;
              if (moveCloser) {
                emit(MoveCloser(
                  _controller!,
                  detectionResult: [res],
                ));
                return;
              }
              if(state is! TakingPicture) {
                await _controller?.stopImageStream();
                emit(TakingPicture(_controller!));
                add(CaptureImage());
              }

              return;
              emit(ObjectInPosition(
                _controller!,
                detectionResult: [
                  DetectionResult(
                      label: firstObject.labels.first.text,
                      confidence: firstObject.labels.first.confidence,
                      boundingBox: firstObject.boundingBox,
                      isInPosition: true)
                ],
              ));
              return;
            }
          } else {
            emit(CameraReady(_controller!, detectionResult: []));
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _captureImage(
      CaptureImage event, Emitter<CameraState> emit) async {
    try {
      final file = await _controller!.takePicture();
      final cropped = await _pickAndCropImage(File(file.path));
      emit(CaptureComplete(cropped?.path ?? ""));
    } catch (e) {
      emit(CameraReady(_controller!));
    }
  }

  Future<File?> _pickAndCropImage(File? pickedFile) async {
    if (pickedFile != null) {
      final imageBytes = File(pickedFile.path).readAsBytesSync();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage != null) {
        final int centerX = (originalImage.width / 2).round();
        final int centerY = (originalImage.height / 2).round();
        final double cropWidth = 40.h;
        final double cropHeight = 40.h;

        final int left =
            (centerX - cropWidth / 2).clamp(0, originalImage.width).round();
        final int top =
            (centerY - cropHeight / 2).clamp(0, originalImage.height).round();
        final img.Image croppedImage = img.copyCrop(originalImage,
            x: left,
            y: top,
            width: cropWidth.toInt(),
            height: cropHeight.toInt());
        final croppedFile = File('${pickedFile.path}_cropped.png')
          ..writeAsBytesSync(img.encodePng(croppedImage));
        return croppedFile;
      }
    }
    return null;
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    repository.dispose();
    return super.close();
  }
}
