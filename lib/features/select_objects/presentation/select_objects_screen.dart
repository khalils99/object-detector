import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:obj_detector/core/constants/images.dart';
import 'package:obj_detector/features/select_objects/logic/select_object_bloc.dart';
import 'package:obj_detector/router/app_router.dart';
import 'package:sizer/sizer.dart';

class SelectObjectsScreen extends StatelessWidget {
  const SelectObjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, AKW Consultants"),
        centerTitle: false,
      ),
      body: BlocProvider(
        create: (context) => SelectObjectBloc(),
        child: BlocBuilder<SelectObjectBloc, SelectObjectState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 3.h,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Please select\nan object to detect",
                      style: TextStyle(
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.1),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 3.h
                        : 5.h,
                  ),
                  Wrap(
                      spacing: 0.8.h,
                      runSpacing: 0.8.h,
                      alignment: WrapAlignment.end,
                      children: List.from(context
                          .select((SelectObjectBloc bloc) => bloc.objects)
                          .map((object) {
                        return IconButton(
                          style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.all(1.5.h)),
                              shadowColor: WidgetStateProperty.all(
                                  Colors.grey.withOpacity(0.15)),
                              elevation: WidgetStateProperty.all(12),
                              minimumSize:
                                  WidgetStateProperty.all(Size(9.h, 8.h)),
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  side: BorderSide(
                                      color:
                                          state is SelectObjectSelectedState &&
                                                  (state)
                                                      .objects
                                                      .contains(object['name'])
                                              ? Colors.blue
                                              : Colors.grey.shade200,
                                      width: 1),
                                ),
                              )),
                          onPressed: () {
                            context
                                .read<SelectObjectBloc>()
                                .add(SelectObjectSelected(object['name']));
                          },
                          icon: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  "assets/svgs/${object['icon']}.svg",
                                  height: 20.sp,
                                  color: state is SelectObjectSelectedState &&
                                          (state)
                                              .objects
                                              .contains(object['name'])
                                      ? Colors.blue
                                      : null,
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Text(
                                  object['name'],
                                  style: TextStyle(
                                    fontSize: 16.4.sp,
                                    fontWeight:
                                        state is SelectObjectSelectedState &&
                                                (state)
                                                    .objects
                                                    .contains(object['name'])
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color: state is SelectObjectSelectedState &&
                                            (state)
                                                .objects
                                                .contains(object['name'])
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }))),
                  SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 12.h
                        : 28.h,
                  ),
                  AnimatedAlign(
                    alignment: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? Alignment.centerRight
                        : Alignment.bottomCenter,
                    duration: Duration(milliseconds: 300),
                    child: AnimatedOpacity(
                      opacity: state is SelectObjectSelectedState &&
                              state.objects.isNotEmpty
                          ? 1
                          : 0.3,
                      duration: Duration(milliseconds: 300),
                      child: TextButton(
                          onPressed: () {
                            if (state is SelectObjectSelectedState &&
                                state.objects.isNotEmpty) {
                              context.push("${AppRouter.cameraView}", extra: {
                                "object": context
                                    .read<SelectObjectBloc>()
                                    .objects
                                    .firstWhere((element) =>
                                element['name'] ==
                                    (state).objects.first)
                              });
                            }
                          },
                          style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                      horizontal: 3.5.h, vertical: 2.h)),
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.blue),
                              fixedSize: WidgetStateProperty.all(Size(
                                  MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 35.w
                                      : 85.w,
                                  MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 13.h
                                      : 7.h)),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.sp)))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Get Started'.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 19.sp,
                                      height: -0.2,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                              SvgPicture.asset(AppImages.arrowRight,
                                  height: 20.sp, color: Colors.white)
                            ],
                          )),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
