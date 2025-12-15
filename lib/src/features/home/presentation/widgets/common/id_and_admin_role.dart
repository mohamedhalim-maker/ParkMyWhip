import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/small_badge_container.dart';

class IdAndAdminRole extends StatelessWidget {
  const IdAndAdminRole({
    super.key,
    required this.id,
    required this.adminRole,
    this.child,
  });
  final String id;
  final String adminRole;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: SmallBadgeContainer(
                  child: Text(
                    '#$id',
                    style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              horizontalSpace(4),
              Flexible(
                child: SmallBadgeContainer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: AppColor.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                      horizontalSpace(4),
                      Flexible(
                        child: Text(
                          adminRole,
                          style: AppTextStyles.urbanistFont10Grey700Medium1_54,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (child != null) ...[
          horizontalSpace(8),
          Flexible(child: SmallBadgeContainer(color: AppColor.redDark, child: child!)),
        ],
      ],
    );
  }
}
