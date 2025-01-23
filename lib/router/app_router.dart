import 'package:go_router/go_router.dart';
import 'package:obj_detector/features/select_objects/presentation/select_objects_screen.dart';
import '../features/camera/presentation/screens/camera_screen.dart';
import '../features/camera/presentation/screens/captured_image_screen.dart';

class AppRouter {
  static String cameraView = '/camera';
  static String capturedImageView = '/captured-image';

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SelectObjectsScreen(),
      ),
      GoRoute(
        path: cameraView,
        builder: (context, state) {
          return CameraScreen(
            objects: [(state.extra as Map?)?['object']],
          );
        },
      ),
      GoRoute(
        path: capturedImageView,
        builder: (context, state) {
          final imagePath = state.extra as Map;
          return CapturedImageScreen(imagePath: imagePath);
        },
      ),
    ],
  );
}
