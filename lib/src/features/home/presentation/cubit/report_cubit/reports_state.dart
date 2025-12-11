import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';

class ReportsState extends Equatable {
  final List<ActiveReportModel> activeReports;
  final List<HistoryReportModel> historyReports;

  const ReportsState({
    this.activeReports = const <ActiveReportModel>[],
    this.historyReports = const <HistoryReportModel>[],
  });

  ReportsState copyWith({
    List<ActiveReportModel>? activeReports,
    List<HistoryReportModel>? historyReports,
  }) {
    return ReportsState(
      activeReports: activeReports ?? this.activeReports,
      historyReports: historyReports ?? this.historyReports,
    );
  }

  @override
  List<Object?> get props => [activeReports, historyReports];
}
