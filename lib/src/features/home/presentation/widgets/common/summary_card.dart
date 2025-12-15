import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/car_details_and_submit_time.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/id_and_admin_role.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/plate_number_and_reported_by.dart';

/// A reusable summary card widget that displays report/towing information.
/// Used across different pages to maintain consistent UI.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.id,
    required this.adminRole,
    required this.carDetails,
    required this.submitTime,
    required this.plateNumber,
    required this.reportedBy,
    required this.additionalNotes,
    required this.backgroundColor,
    this.reportedByLabel,
  });

  final String id;
  final String adminRole;
  final String carDetails;
  final DateTime submitTime;
  final String plateNumber;
  final String reportedBy;
  final String additionalNotes;
  final Color backgroundColor;
  final String? reportedByLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColor.gray10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IdAndAdminRole(id: id, adminRole: adminRole),
          verticalSpace(8),
          CarDetailsAndSubmitTime(carDetails: carDetails, submitTime: submitTime),
          verticalSpace(12),
          Container(height: 1, color: AppColor.gray20),
          verticalSpace(12),
          PlateNumberAndReportedBy(plateNumber: plateNumber, reportedBy: reportedBy, reportedByLabel: reportedByLabel),
          verticalSpace(12),
          Text(
            HomeStrings.additionalNotesLabel,
            style: AppTextStyles.urbanistFont10Grey700Regular1_3,
          ),
          verticalSpace(2),
          Text(
            '"$additionalNotes"',
            style: AppTextStyles.urbanistFont12Grey700SemiBold1_2,
          ),
        ],
      ),
    );
  }
}
