import '/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Text('فضلاً انتظر ...',
            style: TextStyle(
                fontSize: 16,
                color: AppColor.primary,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo')),
      ],
    ));
  }
}
