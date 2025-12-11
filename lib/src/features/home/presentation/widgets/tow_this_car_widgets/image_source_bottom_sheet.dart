import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

/// Bottom sheet widget that allows users to select image source (Camera or Gallery)
class ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const ImageSourceBottomSheet({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            HomeStrings.selectImageSource,
            style: AppTextStyles.urbanistFont18Grey800SemiBold1_2,
          ),
          verticalSpace(24),
          
          // Camera option
          ImageSourceOption(
            icon: Icons.camera_alt,
            label: HomeStrings.camera,
            onTap: () {
              Navigator.pop(context);
              onCameraTap();
            },
          ),
          verticalSpace(12),
          
          // Gallery option
          ImageSourceOption(
            icon: Icons.photo_library,
            label: HomeStrings.gallery,
            onTap: () {
              Navigator.pop(context);
              onGalleryTap();
            },
          ),
          verticalSpace(12),
          
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              HomeStrings.cancel,
              style: AppTextStyles.urbanistFont16Grey800Regular1_3.copyWith(
                color: AppColor.redDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual option item in the bottom sheet
class ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ImageSourceOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.cardBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 24.sp, color: AppColor.redDark),
            ),
            horizontalSpace(16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.urbanistFont16Grey800Regular1_3,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColor.grey400),
          ],
        ),
      ),
    );
  }
}
