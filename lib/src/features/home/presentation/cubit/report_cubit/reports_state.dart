import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';

class ReportsState extends Equatable {
  final List<ActiveReportModel> activeReports;
  final List<HistoryReportModel> historyReports;
  final List<HistoryReportModel> allHistoryReports;
  final ReportFilterCriteria filterCriteria;
  final bool isLoadingActiveReports;
  final bool isLoadingHistoryReports;

  const ReportsState({
    this.activeReports = const <ActiveReportModel>[],
    this.historyReports = const <HistoryReportModel>[],
    this.allHistoryReports = const <HistoryReportModel>[],
    this.filterCriteria = const ReportFilterCriteria(),
    this.isLoadingActiveReports = false,
    this.isLoadingHistoryReports = false,
  });

  ReportsState copyWith({
    List<ActiveReportModel>? activeReports,
    List<HistoryReportModel>? historyReports,
    List<HistoryReportModel>? allHistoryReports,
    ReportFilterCriteria? filterCriteria,
    bool? isLoadingActiveReports,
    bool? isLoadingHistoryReports,
  }) {
    return ReportsState(
      activeReports: activeReports ?? this.activeReports,
      historyReports: historyReports ?? this.historyReports,
      allHistoryReports: allHistoryReports ?? this.allHistoryReports,
      filterCriteria: filterCriteria ?? this.filterCriteria,
      isLoadingActiveReports: isLoadingActiveReports ?? this.isLoadingActiveReports,
      isLoadingHistoryReports: isLoadingHistoryReports ?? this.isLoadingHistoryReports,
    );
  }

  @override
  List<Object?> get props => [
        activeReports,
        historyReports,
        allHistoryReports,
        filterCriteria,
        isLoadingActiveReports,
        isLoadingHistoryReports,
      ];
}
