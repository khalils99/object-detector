import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';

class DetectionRepository {
  late final ObjectDetector _objectDetector;
  DetectionRepository() {
    init();
  }
  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  init() async {
    _objectDetector = ObjectDetector(
      options: LocalObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
        modelPath: await getModelPath("assets/models/object_labeler.tflite"),
      ),
    );
  }

  Future<List<DetectedObject>> detectObjects(CameraImage image) async {
    final inputImage = InputImage.fromBytes(
      bytes: concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        format: buildImageFormat(image),
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation90deg,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
    try {
      final objects = await _objectDetector.processImage(inputImage);
      return objects;
    } catch (e) {
      rethrow;
    }
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  InputImageFormat buildImageFormat(CameraImage image) {
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }

  void dispose() {
    _objectDetector.close();
  }
}
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';
//
// class DetectionRepository {
//   static const String _modelPath = 'assets/custom_ssd_mobilenet_v2.tflite';
//   //custom_ssd_mobilenet_v2_fpn_lite_320x320.tflite
//   static const String _labelPath = 'assets/labels.txt';
//
//   Interpreter? _interpreter;
//   List<String>? _labels;
//
//   DetectionRepository() {
//     _loadModel();
//     _loadLabels();
//     log('Done.');
//   }
//
//   Future<void> _loadModel() async {
//     log('Loading interpreter options...');
//     final interpreterOptions = InterpreterOptions();
//
//     // Use XNNPACK Delegate
//     if (Platform.isAndroid) {
//       interpreterOptions.addDelegate(XNNPackDelegate());
//     }
//
//     // Use Metal Delegate
//     if (Platform.isIOS) {
//       interpreterOptions.addDelegate(GpuDelegate());
//     }
//
//     log('Loading interpreter...');
//     _interpreter =
//         await Interpreter.fromAsset(_modelPath, options: interpreterOptions);
//   }
//
//   Future<void> _loadLabels() async {
//     log('Loading labels...');
//     final labelsRaw = await rootBundle.loadString(_labelPath);
//     _labels = labelsRaw.split('\n');
//   }
//
//   Uint8List analyseImage(Uint8List imageData) {
//     log("image data is ${imageData.toString()}");
//
//     final image = img.decodeImage(imageData);
//
//     // Resizing image fpr model, [300, 300]
//     // If you use SSD_Mobile_Net_V2 FPN Lite 320 x 320 , please change both the width and height to 320
//     final imageInput = img.copyResize(
//       image!,
//       width: 300,
//       height: 300,
//     );
//
//     // Creating matrix representation, [300, 300, 3]
//     final imageMatrix = List.generate(
//       imageInput.height,
//       (y) => List.generate(
//         imageInput.width,
//         (x) {
//           final pixel = imageInput.getPixel(x, y);
//           return [pixel.r, pixel.g, pixel.b];
//         },
//       ),
//     );
//
//     final output = _runInference(imageMatrix);
//
//     // Process Tensors from the output
//     final scoresTensor = output[0].first as List<double>;
//     final boxesTensor = output[1].first as List<List<double>>;
//     final classesTensor = output[3].first as List<double>;
//
//     log('Processing outputs...');
//
//     // Process bounding boxes
//     final List<List<int>> locations = boxesTensor
//         .map((box) => box.map((value) => ((value * 300).toInt())).toList())
//         .toList();
//
//     // Convert class indices to int
//     final classes = classesTensor.map((value) => value.toInt()).toList();
//
//     // Number of detections
//     final numberOfDetections = output[2].first as double;
//
//     // Get classifcation with label
//     final List<String> classification = [];
//     for (int i = 0; i < numberOfDetections; i++) {
//       classification.add(_labels![classes[i]]);
//     }
//
//     log('Outlining objects...');
//     for (var i = 0; i < numberOfDetections; i++) {
//       if (scoresTensor[i] > 0.85) {
//         // Rectangle drawing
//         img.drawRect(
//           imageInput,
//           x1: locations[i][1],
//           y1: locations[i][0],
//           x2: locations[i][3],
//           y2: locations[i][2],
//           color: img.ColorRgb8(0, 255, 0),
//           thickness: 3,
//         );
//
//         // Label drawing
//         img.drawString(
//           imageInput,
//           '${classification[i]} ${scoresTensor[i]}',
//           font: img.arial14,
//           x: locations[i][1] + 7,
//           y: locations[i][0] + 7,
//           color: img.ColorRgb8(0, 255, 0),
//         );
//       }
//     }
//
//     log('Done.');
//     return img.encodeJpg(imageInput);
//   }
//
//   List<List<Object>> _runInference(
//     List<List<List<num>>> imageMatrix,
//   ) {
//     log('Running inference...');
//
//     // Set input tensor [1, 300, 300, 3]
//     final input = [imageMatrix];
//
//     // Set output tensor
//     // Scores: [1, 10],
//     // Locations: [1, 10, 4],
//     // Number of detections: [1],
//     // Classes: [1, 10],
//     final output = {
//       0: [List<num>.filled(10, 0)],
//       1: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
//       2: [0.0],
//       3: [List<num>.filled(10, 0)],
//     };
//
//     _interpreter!.runForMultipleInputs([input], output);
//     return output.values.toList();
//   }
// }
