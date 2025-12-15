import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/features/home/data/models/history_report_model.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';

class ReportFilterHelper {
  static List<HistoryReportModel> applyFilters(
    List<HistoryReportModel> reports,
    ReportFilterCriteria criteria,
  ) {
    return reports.where((report) {
      // Time range filter
      if (criteria.timeRange != TimeRangeFilter.all) {
        final now = DateTime.now();
        final reportDate = report.submitTime;
        
        switch (criteria.timeRange) {
          case TimeRangeFilter.lastWeek:
            if (now.difference(reportDate).inDays > 7) return false;
            break;
          case TimeRangeFilter.lastMonth:
            if (now.difference(reportDate).inDays > 30) return false;
            break;
          case TimeRangeFilter.lastYear:
            if (now.difference(reportDate).inDays > 365) return false;
            break;
          case TimeRangeFilter.all:
            break;
        }
      }

      // Violation type filter
      if (criteria.violationType != ViolationTypeFilter.all) {
        final violationMatch = _matchViolationType(
          report.expiredReason,
          criteria.violationType,
        );
        if (!violationMatch) return false;
      }

      // Reported by filter
      if (criteria.reportedBy != ReportedByFilter.all) {
        final reportedByMatch = _matchReportedBy(
          report.adminRole,
          criteria.reportedBy,
        );
        if (!reportedByMatch) return false;
      }

      return true;
    }).toList();
  }

  static bool _matchViolationType(
    String expiredReason,
    ViolationTypeFilter filter,
  ) {
    final reason = expiredReason.toLowerCase();
    switch (filter) {
      case ViolationTypeFilter.expiredPermit:
        return reason.contains('expired') || reason.contains('permit');
      case ViolationTypeFilter.unauthorizedParking:
        return reason.contains('unauthorized') || reason.contains('parking');
      case ViolationTypeFilter.parkedInFireLaneZone:
        return reason.contains('fire') || reason.contains('lane');
      case ViolationTypeFilter.all:
        return true;
    }
  }

  static bool _matchReportedBy(
    String adminRole,
    ReportedByFilter filter,
  ) {
    final role = adminRole.toLowerCase();
    switch (filter) {
      case ReportedByFilter.residentAdmin:
        return role.contains('resident');
      case ReportedByFilter.permitControl:
        return role.contains('permit') || role.contains('control');
      case ReportedByFilter.superAdmin:
        return role.contains('super');
      case ReportedByFilter.all:
        return true;
    }
  }

  static List<FilterChipData> getActiveFilters(ReportFilterCriteria criteria) {
    final List<FilterChipData> filters = [];

    if (criteria.timeRange != TimeRangeFilter.all) {
      filters.add(FilterChipData(
        label: _getTimeRangeLabel(criteria.timeRange),
        filterType: 'timeRange',
      ));
    }

    if (criteria.violationType != ViolationTypeFilter.all) {
      filters.add(FilterChipData(
        label: _getViolationTypeLabel(criteria.violationType),
        filterType: 'violationType',
      ));
    }

    if (criteria.reportedBy != ReportedByFilter.all) {
      filters.add(FilterChipData(
        label: _getReportedByLabel(criteria.reportedBy),
        filterType: 'reportedBy',
      ));
    }

    return filters;
  }

  static String _getTimeRangeLabel(TimeRangeFilter filter) {
    switch (filter) {
      case TimeRangeFilter.all:
        return HomeStrings.all;
      case TimeRangeFilter.lastYear:
        return HomeStrings.lastYear;
      case TimeRangeFilter.lastMonth:
        return HomeStrings.lastMonth;
      case TimeRangeFilter.lastWeek:
        return HomeStrings.lastWeek;
    }
  }

  static String _getViolationTypeLabel(ViolationTypeFilter filter) {
    switch (filter) {
      case ViolationTypeFilter.all:
        return HomeStrings.all;
      case ViolationTypeFilter.expiredPermit:
        return HomeStrings.expiredPermit;
      case ViolationTypeFilter.unauthorizedParking:
        return HomeStrings.unauthorizedParking;
      case ViolationTypeFilter.parkedInFireLaneZone:
        return HomeStrings.parkedInFireLaneZone;
    }
  }

  static String _getReportedByLabel(ReportedByFilter filter) {
    switch (filter) {
      case ReportedByFilter.all:
        return HomeStrings.all;
      case ReportedByFilter.residentAdmin:
        return HomeStrings.residentAdmin;
      case ReportedByFilter.permitControl:
        return HomeStrings.permitControl;
      case ReportedByFilter.superAdmin:
        return HomeStrings.superAdmin;
    }
  }
}
