import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_form_button.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/history_cubit/history_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/history_widgets/history_small_container.dart';

class SingleTowingEntry extends StatelessWidget {
  const SingleTowingEntry({super.key, required this.towingEntry});
  final TowingEntryModel towingEntry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColor.gray20),
          color: AppColor.veryLightRed,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            verticalSpace(8),
            _buildCarAndDateInfo(),
            verticalSpace(12),
            Container(height: 1, color: AppColor.gray20),
            verticalSpace(12),
            _buildPlateAndReportedBy(),
            verticalSpace(12),
            CommonFormButton(
              text: HomeStrings.review,
              leadingIcon:Icons.info_outline ,
              onPressed: () => getIt<HistoryCubit>().selectEntry(towingEntry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: HistorySmallContainer(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150.w),
              child: Text(
                '#${towingEntry.plateNumber}',
                style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        horizontalSpace(4),
        Flexible(
          child: HistorySmallContainer(
            color: AppColor.redDark,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150.w),
              child: Text(
                towingEntry.reason ?? '',
                style: AppTextStyles.urbanistFont12RedLightMedium1_3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarAndDateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          towingEntry.location ?? 'Unknown Location',
          style: AppTextStyles.urbanistFont14Grey800Bold1,
        ),
        verticalSpace(4),
        if (towingEntry.towDate != null)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${HomeStrings.towingDate} ',
                  style: AppTextStyles.urbanistFont10Grey700Regular1_3,
                ),
                TextSpan(
                  text: DateFormat('yyyy-MM-dd').format(towingEntry.towDate!),
                  style: AppTextStyles.urbanistFont10Grey800SemiBold1_54,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlateAndReportedBy() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                HomeStrings.plateNumberLabel,
                style: AppTextStyles.urbanistFont10Grey700Regular1_3,
              ),
              verticalSpace(4),
              Text(
                towingEntry.plateNumber,
                style: AppTextStyles.urbanistFont14Grey800Bold1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        horizontalSpace(4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                HomeStrings.reportedByLabel,
                style: AppTextStyles.urbanistFont10Grey700Regular1_3,
              ),
              verticalSpace(4),
              HistorySmallContainer(
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
                        towingEntry.reportedBy ?? 'N/A',
                        style: AppTextStyles.urbanistFont10Grey700Medium1_54,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

