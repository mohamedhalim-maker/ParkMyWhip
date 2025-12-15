import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColor.cardBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        backgroundColor: AppColor.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            TowMyWhipIcons.filter,
            color: AppColor.redDark,
            size: 14.sp,
          ),
          horizontalSpace(6),
          Text(
            HomeStrings.filtersAction,
            style: AppTextStyles.urbanistFont14Gray800Regular1_4.copyWith(
              color: AppColor.richRed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
