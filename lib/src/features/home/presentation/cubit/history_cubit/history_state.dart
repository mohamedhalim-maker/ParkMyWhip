import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';

class HistoryState extends Equatable {
  final List<TowingEntryModel> towingHistory;
  final List<TowingEntryModel> allTowingHistory;
  final ReportFilterCriteria filterCriteria;
  final TowingEntryModel? selectedEntry;
  final bool showDetail;
  final bool isLoadingHistory;

  const HistoryState({
    this.towingHistory = const <TowingEntryModel>[],
    this.allTowingHistory = const <TowingEntryModel>[],
    this.filterCriteria = const ReportFilterCriteria(),
    this.selectedEntry,
    this.showDetail = false,
    this.isLoadingHistory = false,
  });

  HistoryState copyWith({
    List<TowingEntryModel>? towingHistory,
    List<TowingEntryModel>? allTowingHistory,
    ReportFilterCriteria? filterCriteria,
    TowingEntryModel? selectedEntry,
    bool? showDetail,
    bool? isLoadingHistory,
  }) {
    return HistoryState(
      towingHistory: towingHistory ?? this.towingHistory,
      allTowingHistory: allTowingHistory ?? this.allTowingHistory,
      filterCriteria: filterCriteria ?? this.filterCriteria,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      showDetail: showDetail ?? this.showDetail,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }

  @override
  List<Object?> get props => [
        towingHistory,
        allTowingHistory,
        filterCriteria,
        selectedEntry,
        showDetail,
        isLoadingHistory,
      ];
}
