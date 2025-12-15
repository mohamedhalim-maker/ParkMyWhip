import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';

class PlateNumberAndReportedBy extends StatelessWidget {
  const PlateNumberAndReportedBy({
    super.key,
    required this.plateNumber,
    required this.reportedBy,
    this.reportedByLabel,
  });

  final String plateNumber;
  final String reportedBy;
  final String? reportedByLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              HomeStrings.plateNumber,
              style: AppTextStyles.urbanistFont10Grey700Regular1_3,
            ),
            Spacer(),
            Text(
              reportedByLabel ?? HomeStrings.reportedByLabel,
              style: AppTextStyles.urbanistFont10Grey700Regular1_3,
            ),
          ],
        ),
        verticalSpace(2),
        Row(
          children: [
            Expanded(
              child: Text(
                plateNumber,
                style: AppTextStyles.urbanistFont14Grey800Bold1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                reportedBy,
                style: AppTextStyles.urbanistFont14Grey800Bold1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
