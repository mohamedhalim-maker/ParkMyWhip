import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/history_report_shimmer.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/single_history_report.dart';

class AllHistoryReports extends StatelessWidget {
  const AllHistoryReports({
    super.key,
    required this.historyReports,
    this.isLoading = false,
  });

  final List<HistoryReportModel> historyReports;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const HistoryReportShimmer();
    }

    return historyReports.isEmpty
        ? Center(
            child: Text(
              HomeStrings.noHistoryReports,
              style: AppTextStyles.urbanistFont14Gray800Regular1_4,
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => SingleHistoryReport(
              historyReportModel: historyReports[index],
            ),
            itemCount: historyReports.length,
          );
  }
}
