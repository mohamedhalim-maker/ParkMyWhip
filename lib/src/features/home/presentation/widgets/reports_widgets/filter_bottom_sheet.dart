import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    required this.currentCriteria,
    required this.onApplyFilter,
  });

  final ReportFilterCriteria currentCriteria;
  final Function(ReportFilterCriteria) onApplyFilter;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TimeRangeFilter _selectedTimeRange;
  late ViolationTypeFilter _selectedViolationType;
  late ReportedByFilter _selectedReportedBy;

  @override
  void initState() {
    super.initState();
    _selectedTimeRange = widget.currentCriteria.timeRange;
    _selectedViolationType = widget.currentCriteria.violationType;
    _selectedReportedBy = widget.currentCriteria.reportedBy;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height:747.h,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(TowMyWhipIcons.close, size: 14.sp,color:AppColor.grey700),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
            verticalSpace(16),
            _buildTimeRangeSection(),
            verticalSpace(24),
            _buildViolationTypeSection(),
            verticalSpace(24),
            _buildReportedBySection(),
            Spacer(),
            CommonButton(
              text: HomeStrings.filter,
              onPressed: () {
                final criteria = ReportFilterCriteria(
                  timeRange: _selectedTimeRange,
                  violationType: _selectedViolationType,
                  reportedBy: _selectedReportedBy,
                );
                widget.onApplyFilter(criteria);
                Navigator.pop(context);
              },
            ),
            verticalSpace(16),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeStrings.timeRange,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(16),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              label: HomeStrings.lastYear,
              isSelected: _selectedTimeRange == TimeRangeFilter.lastYear,
              onTap: () => setState(() {
                _selectedTimeRange = _selectedTimeRange == TimeRangeFilter.lastYear
                    ? TimeRangeFilter.all
                    : TimeRangeFilter.lastYear;
              }),
            ),
            _buildFilterChip(
              label: HomeStrings.lastMonth,
              isSelected: _selectedTimeRange == TimeRangeFilter.lastMonth,
              onTap: () => setState(() {
                _selectedTimeRange = _selectedTimeRange == TimeRangeFilter.lastMonth
                    ? TimeRangeFilter.all
                    : TimeRangeFilter.lastMonth;
              }),
            ),
            _buildFilterChip(
              label: HomeStrings.lastWeek,
              isSelected: _selectedTimeRange == TimeRangeFilter.lastWeek,
              onTap: () => setState(() {
                _selectedTimeRange = _selectedTimeRange == TimeRangeFilter.lastWeek
                    ? TimeRangeFilter.all
                    : TimeRangeFilter.lastWeek;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViolationTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeStrings.violationType,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(16),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              label: HomeStrings.expiredPermit,
              isSelected: _selectedViolationType == ViolationTypeFilter.expiredPermit,
              onTap: () => setState(() {
                _selectedViolationType =
                    _selectedViolationType == ViolationTypeFilter.expiredPermit
                        ? ViolationTypeFilter.all
                        : ViolationTypeFilter.expiredPermit;
              }),
            ),
            _buildFilterChip(
              label: HomeStrings.unauthorizedParking,
              isSelected: _selectedViolationType == ViolationTypeFilter.unauthorizedParking,
              onTap: () => setState(() {
                _selectedViolationType =
                    _selectedViolationType == ViolationTypeFilter.unauthorizedParking
                        ? ViolationTypeFilter.all
                        : ViolationTypeFilter.unauthorizedParking;
              }),
            ),
            _buildFilterChip(
              label: HomeStrings.parkedInFireLaneZone,
              isSelected: _selectedViolationType == ViolationTypeFilter.parkedInFireLaneZone,
              onTap: () => setState(() {
                _selectedViolationType =
                    _selectedViolationType == ViolationTypeFilter.parkedInFireLaneZone
                        ? ViolationTypeFilter.all
                        : ViolationTypeFilter.parkedInFireLaneZone;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportedBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HomeStrings.reportedByLabel,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(16),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              label: HomeStrings.residentAdmin,
              isSelected: _selectedReportedBy == ReportedByFilter.residentAdmin,
              onTap: () => setState(() {
                _selectedReportedBy = _selectedReportedBy == ReportedByFilter.residentAdmin
                    ? ReportedByFilter.all
                    : ReportedByFilter.residentAdmin;
              }),
            ),
            _buildFilterChip(
              label: HomeStrings.permitControl,
              isSelected: _selectedReportedBy == ReportedByFilter.permitControl,
              onTap: () => setState(() {
                _selectedReportedBy = _selectedReportedBy == ReportedByFilter.permitControl
                    ? ReportedByFilter.all
                    : ReportedByFilter.permitControl;
              }),
            ),
            _buildFilterChip(
              label: HomeStrings.superAdmin,
              isSelected: _selectedReportedBy == ReportedByFilter.superAdmin,
              onTap: () => setState(() {
                _selectedReportedBy = _selectedReportedBy == ReportedByFilter.superAdmin
                    ? ReportedByFilter.all
                    : ReportedByFilter.superAdmin;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ?AppColor.redBG :AppColor.white,
          border: Border.all(
            color: isSelected ? AppColor.richRed : AppColor.cardBorder,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.urbanistFont14Grey700Medium1_28,
        ),
      ),
    );
  }
}
