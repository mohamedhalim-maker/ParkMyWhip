import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';

class ProfileActionCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const ProfileActionCard({
    super.key,
    required this.text,
    this.icon,
    this.iconSize = 24,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColor.cardBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.urbanistFont16BlackSemiBold1_3.copyWith(
                  color: textColor ?? AppColor.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (icon != null) ...[
              SizedBox(width: 8.w),
              Icon(icon, size: iconSize.sp, color: iconColor ?? AppColor.grey800),
            ],
          ],
        ),
      ),
    );
  }
}
