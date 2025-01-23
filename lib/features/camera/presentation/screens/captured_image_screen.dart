import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:obj_detector/core/constants/images.dart';
import 'package:obj_detector/features/camera/presentation/screens/camera_screen.dart';
import 'package:sizer/sizer.dart';

class CapturedImageScreen extends StatelessWidget {
  final Map imagePath;

  const CapturedImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600);
    return Scaffold(
      appBar: AppBar(title: const Text("Captured Image"),
      leading: IconButton(
        icon: Transform.rotate(
            angle: 180 * 3.14 / 180,
            child: SvgPicture.asset(AppImages.arrowRight)),
        onPressed: () {
          context.pop();
        },
      ),),
      body: Center(
        child: Column(
          children: [
            SizedBox(
                height: 50.h,
                child: Image.file(File(imagePath['path']))),
            SizedBox(height: 3.h),
            Wrap(
              spacing: 3.w,
              runSpacing: 2.w,
              children: [
                Text("Type: ${imagePath['object']['name']}",
                style: textStyle
                ),
                Text("Date: ${DateFormat("MMM dd, yyyy hh:mm aa").format(File(imagePath['path']).lastModifiedSync())}",
                style: textStyle
                ),


              ],
            )
          ],
        ),
      ),
    );
  }
}
