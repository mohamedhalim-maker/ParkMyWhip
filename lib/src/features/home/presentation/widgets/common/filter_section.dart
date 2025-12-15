import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/filter_button.dart';

class FilterSection extends StatelessWidget {
  const FilterSection({
    super.key,
    required this.activeFilters,
    required this.onFilterPressed,
    required this.onRemoveFilter,
  });

  final List<FilterChipData> activeFilters;
  final VoidCallback onFilterPressed;
  final Function(String filterType) onRemoveFilter;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = activeFilters.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilterButton(onPressed: onFilterPressed),
        ),
        if (hasActiveFilters) ...[
          verticalSpace(12),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: activeFilters
                .map((filter) => _FilterChip(
                      label: filter.label,
                      onRemove: () => onRemoveFilter(filter.filterType),
                    ))
                .toList(),
          ),
        ],
        verticalSpace(12),
      ],
    );
  }
}

class FilterChipData {
  final String label;
  final String filterType;

  const FilterChipData({
    required this.label,
    required this.filterType,
  });
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.redBG,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              TowMyWhipIcons.close,
              size: 12.sp,
              color: AppColor.redDark,
            ),
          ),
          horizontalSpace(6),
          Text(
            label,
            style: AppTextStyles.urbanistFont10RedAlertsMedium1.copyWith(color: AppColor.richRed),
          ),
        ],
      ),
    );
  }
}
