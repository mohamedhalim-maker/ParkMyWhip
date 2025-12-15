import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/data/models/report_filter_criteria.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';

class TowingFilterHelper {
  static List<TowingEntryModel> applyFilters(
    List<TowingEntryModel> towingHistory,
    ReportFilterCriteria criteria,
  ) {
    var filtered = towingHistory;

    // Apply time range filter
    if (criteria.timeRange != TimeRangeFilter.all) {
      final now = DateTime.now();
      DateTime cutoffDate;

      switch (criteria.timeRange) {
        case TimeRangeFilter.lastWeek:
          cutoffDate = now.subtract(const Duration(days: 7));
          break;
        case TimeRangeFilter.lastMonth:
          cutoffDate = now.subtract(const Duration(days: 30));
          break;
        case TimeRangeFilter.lastYear:
          cutoffDate = now.subtract(const Duration(days: 365));
          break;
        default:
          cutoffDate = DateTime(2000);
      }

      filtered = filtered.where((entry) {
        return entry.towDate != null && entry.towDate!.isAfter(cutoffDate);
      }).toList();
    }

    // Apply violation type filter
    if (criteria.violationType != ViolationTypeFilter.all) {
      String targetReason = '';

      switch (criteria.violationType) {
        case ViolationTypeFilter.unauthorizedParking:
          targetReason = HomeStrings.unauthorizedParking;
          break;
        case ViolationTypeFilter.expiredPermit:
          targetReason = HomeStrings.expiredPermit;
          break;
        case ViolationTypeFilter.parkedInFireLaneZone:
          targetReason = HomeStrings.parkedInFireLaneZone;
          break;
        default:
          targetReason = '';
      }

      if (targetReason.isNotEmpty) {
        filtered = filtered.where((entry) {
          return entry.reason?.toLowerCase() == targetReason.toLowerCase();
        }).toList();
      }
    }

    // Apply reported by filter
    if (criteria.reportedBy != ReportedByFilter.all) {
      filtered = filtered.where((entry) {
        if (entry.reportedBy == null) return false;
        return _matchReportedBy(entry.reportedBy!, criteria.reportedBy);
      }).toList();
    }

    return filtered;
  }

  static bool _matchReportedBy(String reportedBy, ReportedByFilter filter) {
    final name = reportedBy.toLowerCase();
    switch (filter) {
      case ReportedByFilter.residentAdmin:
        return name.contains('resident');
      case ReportedByFilter.permitControl:
        return name.contains('permit') || name.contains('control');
      case ReportedByFilter.superAdmin:
        return name.contains('super');
      case ReportedByFilter.all:
        return true;
    }
  }

  static List<FilterChipData> getActiveFilters(ReportFilterCriteria criteria) {
    final List<FilterChipData> activeFilters = [];

    // Time range filter
    if (criteria.timeRange != TimeRangeFilter.all) {
      String label = '';
      switch (criteria.timeRange) {
        case TimeRangeFilter.lastWeek:
          label = HomeStrings.lastWeek;
          break;
        case TimeRangeFilter.lastMonth:
          label = HomeStrings.lastMonth;
          break;
        case TimeRangeFilter.lastYear:
          label = HomeStrings.lastYear;
          break;
        default:
          break;
      }
      if (label.isNotEmpty) {
        activeFilters.add(FilterChipData(label: label, filterType: 'timeRange'));
      }
    }

    // Violation type filter
    if (criteria.violationType != ViolationTypeFilter.all) {
      String label = '';
      switch (criteria.violationType) {
        case ViolationTypeFilter.unauthorizedParking:
          label = HomeStrings.unauthorizedParking;
          break;
        case ViolationTypeFilter.expiredPermit:
          label = HomeStrings.expiredPermit;
          break;
        case ViolationTypeFilter.parkedInFireLaneZone:
          label = HomeStrings.parkedInFireLaneZone;
          break;
        default:
          break;
      }
      if (label.isNotEmpty) {
        activeFilters.add(FilterChipData(label: label, filterType: 'violationType'));
      }
    }

    // Reported by filter
    if (criteria.reportedBy != ReportedByFilter.all) {
      String label = '';
      switch (criteria.reportedBy) {
        case ReportedByFilter.residentAdmin:
          label = HomeStrings.residentAdmin;
          break;
        case ReportedByFilter.permitControl:
          label = HomeStrings.permitControl;
          break;
        case ReportedByFilter.superAdmin:
          label = HomeStrings.superAdmin;
          break;
        default:
          break;
      }
      if (label.isNotEmpty) {
        activeFilters.add(FilterChipData(label: label, filterType: 'reportedBy'));
      }
    }

    return activeFilters;
  }
}
