enum TimeRangeFilter {
  all,
  lastYear,
  lastMonth,
  lastWeek,
}

enum ViolationTypeFilter {
  all,
  expiredPermit,
  unauthorizedParking,
  parkedInFireLaneZone,
}

enum ReportedByFilter {
  all,
  residentAdmin,
  permitControl,
  superAdmin,
}

class ReportFilterCriteria {
  final TimeRangeFilter timeRange;
  final ViolationTypeFilter violationType;
  final ReportedByFilter reportedBy;

  const ReportFilterCriteria({
    this.timeRange = TimeRangeFilter.all,
    this.violationType = ViolationTypeFilter.all,
    this.reportedBy = ReportedByFilter.all,
  });

  ReportFilterCriteria copyWith({
    TimeRangeFilter? timeRange,
    ViolationTypeFilter? violationType,
    ReportedByFilter? reportedBy,
  }) {
    return ReportFilterCriteria(
      timeRange: timeRange ?? this.timeRange,
      violationType: violationType ?? this.violationType,
      reportedBy: reportedBy ?? this.reportedBy,
    );
  }

  bool get hasActiveFilters =>
      timeRange != TimeRangeFilter.all ||
      violationType != ViolationTypeFilter.all ||
      reportedBy != ReportedByFilter.all;

  void reset() => const ReportFilterCriteria();
}
