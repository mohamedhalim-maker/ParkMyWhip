import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_form_button.dart';

class ProfileInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool hasAction;
  final VoidCallback? onActionTap;

  const ProfileInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.hasAction = false,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColor.cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.urbanistFont14Gray30Regular1_25,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                verticalSpace(4),
                Text(
                  value,
                  style: AppTextStyles.urbanistFont18Grey800SemiBold1_2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          if (hasAction) ...[
            horizontalSpace(12),
            CommonFormButton(
              text: HomeStrings.change,
              onPressed: onActionTap ?? () {},
              leadingIcon: TowMyWhipIcons.edit,
              width: 95,
              height:31,
            ),
          ],
        ],
      ),
    );
  }
}
