import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/report_cubit/reports_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/all_active_reports.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/all_history_reports.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/reports_tap_header.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/reports_widgets/filter_bottom_sheet.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/filter_section.dart';
import 'package:park_my_whip/src/features/home/presentation/helpers/report_filter_helper.dart';

class ReportsTabWrapper extends StatefulWidget {
  const ReportsTabWrapper({super.key});

  @override
  State<ReportsTabWrapper> createState() => _ReportsTabWrapperState();
}

class _ReportsTabWrapperState extends State<ReportsTabWrapper>
    with SingleTickerProviderStateMixin {
  late final ReportsCubit _reportsCubit;
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _reportsCubit = getIt<ReportsCubit>();
    _controller = TabController(length: 2, vsync: this);
    _controller.addListener(_onTabChanged);

    // Kick off loading immediately so the shimmer shows before any cached data renders.
    _reportsCubit.loadActiveReports();
  }

  void _onTabChanged() {
    if (_controller.indexIsChanging) return;
    if (_controller.index == 0) {
      _reportsCubit.loadActiveReports();
    } else if (_controller.index == 1) {
      _reportsCubit.resetFilter();
      _reportsCubit.loadHistoryReports();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          /// ----- TAB BAR -----
          ReportsTapHeader(controller: _controller),
          verticalSpace(12),
          /// ----- FILTER SECTION (shown only on History tab) -----
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return _controller.index == 1
                  ? BlocBuilder<ReportsCubit, ReportsState>(
                      bloc: _reportsCubit,
                      builder: (context, state) {
                        return FilterSection(
                          activeFilters: ReportFilterHelper.getActiveFilters(
                            state.filterCriteria,
                          ),
                          onFilterPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => FilterBottomSheet(
                                currentCriteria: state.filterCriteria,
                                onApplyFilter: (criteria) {
                                  _reportsCubit.applyFilter(criteria);
                                },
                              ),
                            );
                          },
                          onRemoveFilter: (filterType) {
                            _reportsCubit.removeFilter(filterType);
                          },
                        );
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
          BlocBuilder<ReportsCubit, ReportsState>(
            bloc: _reportsCubit,
            builder: (context, state) {
              return Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: [
                    AllActiveReports(
                      activeReports: state.activeReports,
                      isLoading: state.isLoadingActiveReports,
                    ),
                    AllHistoryReports(
                      historyReports: state.historyReports,
                      isLoading: state.isLoadingHistoryReports,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
