# Object Detection App

An object detection app built with **Flutter** and **BLoC** architecture that uses TensorFlow Lite models for real-time object detection. The app leverages the device's camera to identify objects in the viewfinder and displays their bounding boxes, categories, and confidence scores.

---

## Features
- Real-time object detection using TensorFlow Lite.
- Clean navigation with **GoRouter**.
- Scalable UI with **Sizer**.
- State management using **Flutter BLoC**.
- Lightweight image processing with **image** package.
- Google ML Kit integration for enhanced object detection.

---

## Getting Started

### Prerequisites
- Flutter SDK installed ([Installation Guide](https://docs.flutter.dev/get-started/install)).
- Compatible Android or iOS device/emulator.

### Instructions to Run the App

1. Clone this repository:
   ```bash
   git clone https://github.com/khalils99/object-detector.git
   cd object-detector
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Connect your device or start an emulator.

4. Run the app:
   ```bash
   flutter run
   ```

---

## Dependencies

Here is the list of libraries and tools used in this project:

| Library                          | Version   | Purpose                                              |
|----------------------------------|-----------|------------------------------------------------------|
| `camera`                        | ^0.11.0+2 | Access the device camera for real-time object detection. |
| `flutter_bloc`                  | ^9.0.0    | State management with BLoC architecture.            |
| `go_router`                     | ^14.6.3   | Simplified routing and navigation.                  |
| `sizer`                         | ^3.0.4    | Responsive UI scaling.                              |
| `flutter_svg`                   | ^2.0.17   | Rendering SVG assets.                               |
| `google_mlkit_object_detection` | ^0.14.0   | Google ML Kit object detection.                    |
| `path_provider`                 | ^2.1.5    | Access device file paths.                           |
| `tflite_flutter`                | ^0.11.0   | Run TensorFlow Lite models.                         |
| `image`                         | ^4.5.2    | Image manipulation and preprocessing.               |
| `intl`                          | ^0.20.1   | Localization and internationalization.              |

---

## Challenges Faced

### Finding a Suitable TFLite Model
- **Problem**: Many TensorFlow Lite models found online for object detection performed poorly, lacked accuracy, or were incompatible with real-time inference.
- **Solution**: After extensive research and testing, a custom-trained TFLite model with accurate detection capabilities was integrated. Preprocessing pipelines were optimized to work with the model's requirements (300x300 input, normalized float32).

---

## Screenshots
![IMG_8610.PNG](..%2FDownloads%2FIMG_8610.PNG)
![IMG_8609.PNG](..%2FDownloads%2FIMG_8609.PNG)
![IMG_8608.PNG](..%2FDownloads%2FIMG_8608.PNG)

## How it Works (Video Guide)
[ScreenRecording_01-24-2025 00-04-00_1.MP4](..%2FDownloads%2FScreenRecording_01-24-2025%2000-04-00_1.MP4)
