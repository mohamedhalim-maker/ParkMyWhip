import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/history_widgets/history_list_shimmer.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/history_widgets/single_towing_entry.dart';

/// Renders either the shimmer placeholder or the populated towing history list.
class AllTowingHistory extends StatelessWidget {
  const AllTowingHistory({super.key, required this.towingHistory, required this.isLoading});

  final List<TowingEntryModel> towingHistory;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const HistoryListShimmer();
    }

    if (towingHistory.isEmpty) {
      return Center(
        child: Text(
          HomeStrings.noTowingHistory,
          style: AppTextStyles.urbanistFont16Grey800Bold1,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      itemCount: towingHistory.length,
      itemBuilder: (context, index) {
        return SingleTowingEntry(towingEntry: towingHistory[index]);
      },
    );
  }
}
