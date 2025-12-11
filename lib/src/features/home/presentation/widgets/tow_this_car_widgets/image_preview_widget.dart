import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onChangeTap;

  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChangeTap,
      child: Container(
        width: double.infinity,
        height: 240.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: AppColor.cardBorder,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: kIsWeb
                  ? Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildErrorWidget())
                  : Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildErrorWidget()),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColor.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TowMyWhipIcons.change, size: 14.sp, color: AppColor.redDark),
                SizedBox(width: 8.w),
                Text(HomeStrings.changeImage, style: AppTextStyles.urbanistFont12RedDarkSemiBold1),
              ],
            ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() => Container(
        color: AppColor.grey200,
        child: Center(
          child: Icon(Icons.broken_image, size: 48.sp, color: AppColor.grey400),
        ),
      );
}
