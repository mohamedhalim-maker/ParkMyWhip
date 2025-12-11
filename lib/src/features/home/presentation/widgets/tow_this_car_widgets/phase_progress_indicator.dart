import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';

class PhaseProgressIndicator extends StatelessWidget {
  const PhaseProgressIndicator({
    super.key,
    required this.currentPhase,
  });

  final int currentPhase;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              color: index < currentPhase ? AppColor.richRed : AppColor.richRed.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }
}
