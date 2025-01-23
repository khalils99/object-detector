import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../router/app_router.dart';
import '../../data/repositories/detection_repository.dart';
import '../../logic/camera_bloc.dart';
import '../../logic/camera_events.dart';
import '../../logic/camera_states.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({
    super.key,
    this.objects,
  });
  final List? objects;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CameraBloc(DetectionRepository())..add(InitializeCamera(objects)),
      child: Scaffold(
        body: BlocConsumer<CameraBloc, CameraState>(
          listener: (context, state) {
            if (state is CaptureComplete) {
              context.replace(AppRouter.capturedImageView,
                  extra: {"path": state.imagePath, "object": objects?.first});
            }
          },
          builder: (context, state) {
            if (state is CameraInitializing) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CameraReady) {
              return Stack(
                children: [
                  SizedBox(
                      height: 100.h,
                      width: 100.w,
                      child: CameraPreview(state.controller)),
                  if (state is MoveFarther)
                    Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                          child: Text("Move Farther!",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.w600))),
                    ),
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 40.h,
                        maxHeight: 40.h,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: state is MoveCloser || state is MoveFarther
                                ? Colors.yellow
                                : state is ObjectInPosition
                                    ? Colors.green
                                    : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (state is MoveCloser)
                    Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                          child: Text("Move Closer!",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.w600))),
                    ),
                  if ((state.detectionResult ?? []).isEmpty)
                    Align(
                      alignment: Alignment.topCenter,
                      child: SafeArea(
                          child: Text("Detecting ${objects?.first['name']}...",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600))),
                    ),
                  if (state is ObjectInPosition)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Object in position"),
                          SafeArea(
                            child: TextButton(
                                onPressed: () async {
                                  context
                                      .read<CameraBloc>()
                                      .add(CaptureImage());
                                },
                                style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 2.h)),
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.blue),
                                    minimumSize: WidgetStateProperty.all(
                                        Size(85.w, 7.h)),
                                    shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.sp)))),
                                child: Text('Take Picture'.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 19.sp,
                                        height: -0.2,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white))),
                          )
                        ],
                      ),
                    ),
                ],
              );
            }

            return const Center(child: Text("Error loading camera"));
          },
        ),
      ),
    );
  }
}
