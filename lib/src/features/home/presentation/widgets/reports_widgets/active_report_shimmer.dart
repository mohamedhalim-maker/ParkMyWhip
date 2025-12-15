import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton cards shown while active reports are fetched.
class ActiveReportShimmer extends StatelessWidget {
  const ActiveReportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Shimmer.fromColors(
          baseColor: AppColor.grey200,
          highlightColor: AppColor.white,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColor.gray20),
              color: AppColor.grey200,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 200.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(height: 1, color: AppColor.white.withValues(alpha: 0.6)),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(height: 1, color: AppColor.white.withValues(alpha: 0.6)),
                SizedBox(height: 12.h),
                Container(
                  width: 180.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 28.h,
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 64.w,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(height: 1, color: AppColor.white.withValues(alpha: 0.6)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
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
