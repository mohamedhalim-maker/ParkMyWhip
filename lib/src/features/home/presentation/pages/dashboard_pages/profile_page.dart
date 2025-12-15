import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/profile_widgets/profile_info_card.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/profile_widgets/profile_action_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(24),
              Text(HomeStrings.yourProfile, style: AppTextStyles.urbanistFont24Grey800SemiBold1),
              verticalSpace(20),
              ProfileInfoCard(
                label: HomeStrings.username,
                value: 'Adam Wade Johnson Christopher Alexander Montgomery Wellington',
              ),
              verticalSpace(16),
              ProfileInfoCard(
                label: HomeStrings.email,
                value: 'verylongemailaddressforsometestingpurposes@mail.example.com',
                hasAction: true,
                onActionTap: () {
                  debugPrint('Change email tapped');
                },
              ),
              verticalSpace(16),
              ProfileActionCard(
                text: HomeStrings.changePassword,
                icon: TowMyWhipIcons.forwardIcon,
                iconColor: AppColor.grey800,
                                iconSize:12.sp,

                onTap: () {
                  debugPrint('Change password tapped');
                },
              ),
              verticalSpace(16),
              ProfileActionCard(
                text: HomeStrings.logOut,
                icon: TowMyWhipIcons.logout,
                iconColor: AppColor.richRed,
                onTap: () {
                  debugPrint('Log out tapped');
                },
              ),
              verticalSpace(16),
              ProfileActionCard(
                text: HomeStrings.deleteAccount,
                textColor: AppColor.richRed,
                onTap: () {
                  debugPrint('Delete account tapped');
                },
              ),
              verticalSpace(24),
            ],
          ),
        ),
      ),
    );
  }
}

