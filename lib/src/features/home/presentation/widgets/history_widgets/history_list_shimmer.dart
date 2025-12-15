import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:shimmer/shimmer.dart';

/// Displays skeleton cards that mimic towing history entries while data loads.
class HistoryListShimmer extends StatelessWidget {
  const HistoryListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Shimmer.fromColors(
          baseColor: AppColor.grey200,
          highlightColor: AppColor.white,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.grey200,
              borderRadius: BorderRadius.circular(20.r),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBar(width: 140.w, height: 16.h),
                SizedBox(height: 8.h),
                _ShimmerBar(width: 200.w, height: 14.h),
                SizedBox(height: 12.h),
                _ShimmerBar(width: double.infinity, height: 12.h),
                SizedBox(height: 6.h),
                _ShimmerBar(width: double.infinity, height: 12.h),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _ShimmerCircle(size: 36.w),
                    SizedBox(width: 12.w),
                    Expanded(child: _ShimmerBar(width: double.infinity, height: 12.h)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  const _ShimmerCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColor.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
