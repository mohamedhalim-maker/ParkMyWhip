import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';

class ImagePickerButton extends StatelessWidget {
  final VoidCallback onTap;

  const ImagePickerButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 240.h,
        decoration: BoxDecoration(
          color: AppColor.cardBorder,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(TowMyWhipIcons.add, size: 14.sp, color: AppColor.redDark),
                SizedBox(width: 8.w),
                Text(HomeStrings.attachImage, style: AppTextStyles.urbanistFont12RedDarkSemiBold1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
