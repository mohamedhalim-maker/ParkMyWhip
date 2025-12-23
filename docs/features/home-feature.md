# Home Feature Documentation

## Overview
The home feature is the main application container after login. It includes a dashboard with bottom navigation and 5 sub-features: Patrol, Reports, Tow a Car, History, and Profile.

---

## Feature Structure

```
features/home/
├── data/
│   └── models/
│       ├── active_reports_model.dart      # Active violation reports
│       ├── history_report_model.dart      # Archived reports
│       ├── permit_data_model.dart         # Parking permits
│       ├── location_model.dart            # Patrol locations
│       ├── towing_entry_model.dart        # Towing history records
│       └── report_filter_criteria.dart    # Filter state
└── presentation/
    ├── cubit/
    │   ├── dashboard_cubit/      # Bottom nav state
    │   ├── patrol_cubit/         # Patrol locations state
    │   ├── reports_cubit/        # Reports state
    │   ├── tow_cubit/            # Tow a car flow state
    │   ├── history_cubit/        # Towing history state
    │   └── profile_cubit/        # User profile state
    ├── pages/
    │   ├── dashboard_page.dart   # Main container with bottom nav
    │   └── dashboard_pages/
    │       ├── patrol_page.dart
    │       ├── reports_page.dart
    │       ├── tow_a_car_page.dart
    │       ├── history_page.dart
    │       └── profile_page.dart
    ├── helpers/
    │   ├── phase_widget_builder.dart    # Tow flow phase builder
    │   ├── report_filter_helper.dart    # Report filtering logic
    │   └── towing_filter_helper.dart    # Towing history filtering
    └── widgets/
        ├── common/               # Shared widgets
        ├── patrol_widgets/       # Patrol-specific
        ├── reports_widgets/      # Reports-specific
        ├── tow_this_car_widgets/ # Tow flow phases
        ├── history_widgets/      # History-specific
        ├── profile_widgets/      # Profile-specific
        └── active_permits_widgets/  # Permits-specific
```

---

## Dashboard Structure

### DashboardPage

**Purpose**: Main container with bottom navigation bar.

**Bottom Navigation Tabs**:
1. **Patrol** (index 0) - View patrol locations
2. **Reports** (index 1) - Active/History reports
3. **Tow a Car** (index 2) - Report a violation
4. **History** (index 3) - Towing history
5. **Profile** (index 4) - User profile & logout

**State Management**:
```dart
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  void changeTab(int index) {
    emit(state.copyWith(currentIndex: index));
    log('Tab changed to index $index', name: 'DashboardCubit', level: 800);
  }
}

class DashboardState extends Equatable {
  final int currentIndex;
  const DashboardState({this.currentIndex = 0});
}
```

**UI Implementation**:
```dart
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) {
    final pages = [
      const PatrolPage(),
      const ReportsPage(),
      const TowACarPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];
    
    return Scaffold(
      body: pages[state.currentIndex],
      bottomNavigationBar: DashboardNavBar(
        currentIndex: state.currentIndex,
        onTabChanged: (index) {
          getIt<DashboardCubit>().changeTab(index);
          // Trigger page-specific data loads
          if (index == 1) getIt<ReportsCubit>().loadActiveReports();
          if (index == 3) getIt<HistoryCubit>().loadTowingHistory();
        },
      ),
    );
  },
)
```

---

## Sub-Features

### 1. Patrol Feature

**Purpose**: Display all patrol locations with search functionality.

**Data Model**:
```dart
class LocationModel {
  final String id;
  final String locationName;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**State Management**:
```dart
class PatrolCubit extends Cubit<PatrolState> {
  final List<LocationModel> locations;
  final List<LocationModel> filteredLocations;
  final bool isLoading;
  final String searchQuery;

  Future<void> loadLocations() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 2)); // Shimmer
    final locations = await _fetchLocations();
    emit(state.copyWith(
      locations: locations,
      filteredLocations: locations,
      isLoading: false,
    ));
  }

  void searchLocations(String query) {
    final filtered = state.locations
        .where((loc) => loc.locationName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(state.copyWith(
      searchQuery: query,
      filteredLocations: filtered,
    ));
  }
}
```

**Key Widgets**:
- `PatrolHeaderWidget` - Logo and title
- `AllPatrolLocations` - List of locations
- `SearchTextField` - Search input
- `LocationShimmer` - Loading skeleton

---

### 2. Reports Feature

**Purpose**: View active and history reports with tab switching and filtering.

**Data Models**:
```dart
class ActiveReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String additionalNotes;
  final String attachedImage;
  final DateTime submitTime;
  final String carDetails;

  // Supabase serialization (snake_case)
  factory ActiveReportModel.fromJson(Map<String, dynamic> json) {
    return ActiveReportModel(
      id: json['id'] ?? '',
      adminRole: json['admin_role'] ?? json['adminRole'] ?? '',
      plateNumber: json['plate_number'] ?? json['plateNumber'] ?? '',
      reportedBy: json['reported_by'] ?? json['reportedBy'] ?? '',
      additionalNotes: json['additional_notes'] ?? json['additionalNotes'] ?? '',
      attachedImage: json['attached_image'] ?? json['attachedImage'] ?? '',
      carDetails: json['car_details'] ?? json['carDetails'] ?? '',
      submitTime: json['submit_time'] != null 
        ? DateTime.parse(json['submit_time']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'admin_role': adminRole,
    'plate_number': plateNumber,
    'reported_by': reportedBy,
    'additional_notes': additionalNotes,
    'attached_image': attachedImage,
    'car_details': carDetails,
    'submit_time': submitTime.toIso8601String(),
  };
}

class HistoryReportModel {
  final String id;
  final String adminRole;
  final String plateNumber;
  final String reportedBy;
  final String additionalNotes;
  final String attachedImage;
  final DateTime towDate;
  final String carDetails;
  final String status;  // 'completed', 'cancelled'
}
```

**State Management**:
```dart
class ReportsCubit extends Cubit<ReportsState> {
  final List<ActiveReportModel> activeReports;
  final List<HistoryReportModel> historyReports;
  final bool isLoadingActive;
  final bool isLoadingHistory;
  final ReportFilterCriteria? activeFilter;
  final ReportFilterCriteria? historyFilter;

  Future<void> loadActiveReports() async {
    emit(state.copyWith(isLoadingActive: true));
    await Future.delayed(const Duration(seconds: 2));
    final reports = await _fetchActiveReports();
    emit(state.copyWith(
      activeReports: reports,
      isLoadingActive: false,
    ));
  }

  Future<void> loadHistoryReports() async {
    emit(state.copyWith(isLoadingHistory: true));
    await Future.delayed(const Duration(seconds: 2));
    final reports = await _fetchHistoryReports();
    emit(state.copyWith(
      historyReports: reports,
      isLoadingHistory: false,
    ));
  }

  void applyActiveFilter(ReportFilterCriteria criteria) {
    final filtered = ReportFilterHelper.applyFilter(
      state.activeReports,
      criteria,
    );
    emit(state.copyWith(
      activeFilter: criteria,
      filteredActiveReports: filtered,
    ));
  }
}
```

**UI Structure**:
```
ReportsPage
  └── ReportsTabWrapper (TabController)
      ├── Tab 1: Active Reports
      │   ├── ReportsTapHeader (filter button)
      │   ├── AllActiveReports (list)
      │   │   └── SingleActiveReport (card)
      │   └── ActiveReportShimmer (loading)
      └── Tab 2: History Reports
          ├── ReportsTapHeader (filter button)
          ├── AllHistoryReports (list)
          │   └── SingleHistoryReport (card)
          └── HistoryReportShimmer (loading)
```

**Key Widgets**:
- `ReportsTabWrapper` - Tab controller
- `ReportsTapHeader` - Title + filter button
- `SingleActiveReport` - Active report card
- `SingleHistoryReport` - History report card
- `ActiveReportDetailSheet` - Bottom sheet for report details
- `FilterBottomSheet` - Filter options modal
- Reusable components:
  - `IdAndAdminRole` - Report ID + role badge
  - `PlateNumberAndReportedBy` - Vehicle info
  - `CarDetailsAndSubmitTime` - Car type + timestamp

**Filtering System**:
```dart
class ReportFilterCriteria {
  final String? timeRange;      // 'last_week', 'last_month', 'last_year'
  final String? violationType;  // 'unauthorized', 'expired_permit', etc.
}

class ReportFilterHelper {
  static List<ActiveReportModel> applyFilter(
    List<ActiveReportModel> reports,
    ReportFilterCriteria criteria,
  ) {
    var filtered = reports;
    
    // Time range filter
    if (criteria.timeRange != null) {
      final now = DateTime.now();
      DateTime cutoff;
      if (criteria.timeRange == 'last_week') {
        cutoff = now.subtract(const Duration(days: 7));
      } else if (criteria.timeRange == 'last_month') {
        cutoff = now.subtract(const Duration(days: 30));
      } else {
        cutoff = now.subtract(const Duration(days: 365));
      }
      filtered = filtered.where((r) => r.submitTime.isAfter(cutoff)).toList();
    }
    
    // Violation type filter
    if (criteria.violationType != null) {
      filtered = filtered.where((r) => r.carDetails.contains(criteria.violationType!)).toList();
    }
    
    return filtered;
  }
}
```

---

### 3. Tow a Car Feature

**Purpose**: Multi-phase flow for reporting a vehicle violation.

**6-Phase Flow**:
1. **Phase 1**: Enter plate number
2. **Phase 2**: Select violation type
3. **Phase 3**: Attach image
4. **Phase 4**: Add notes
5. **Phase 5**: Preview submission
6. **Phase 6**: Success confirmation

**State Management**:
```dart
class TowCubit extends Cubit<TowState> {
  final int currentPhase;         // 1-6
  final String plateNumber;
  final String violationType;
  final String? imagePath;
  final String notes;
  final bool isSubmitting;

  void nextPhase() {
    if (currentPhase < 6) {
      emit(state.copyWith(currentPhase: currentPhase + 1));
    }
  }

  void previousPhase() {
    if (currentPhase > 1) {
      emit(state.copyWith(currentPhase: currentPhase - 1));
    }
  }

  void setPlateNumber(String plateNumber) {
    emit(state.copyWith(plateNumber: plateNumber));
  }

  void setViolationType(String type) {
    emit(state.copyWith(violationType: type));
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null) {
      emit(state.copyWith(imagePath: image.path));
    }
  }

  void setNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  Future<void> submitReport() async {
    emit(state.copyWith(isSubmitting: true));
    try {
      // Submit to Supabase
      await _submitToDatabase();
      emit(state.copyWith(isSubmitting: false, currentPhase: 6));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  void resetFlow() {
    emit(const TowState()); // Reset to initial state
  }
}
```

**Phase Widgets**:
- `Phase1EnterPlateNumber` - Text input for plate
- `Phase2SelectViolation` - List of violation options
- `Phase3AttachImage` - Image picker (camera/gallery)
- `Phase4AddNotes` - Text area for notes
- `Phase5Preview` - Summary of all data
- `Phase6Success` - Success animation + "Back to Patrol" button

**Phase Widget Builder**:
```dart
class PhaseWidgetBuilder {
  static Widget buildPhase(int phase, TowState state) {
    switch (phase) {
      case 1:
        return Phase1EnterPlateNumber();
      case 2:
        return Phase2SelectViolation();
      case 3:
        return Phase3AttachImage();
      case 4:
        return Phase4AddNotes();
      case 5:
        return Phase5Preview(state: state);
      case 6:
        return Phase6Success();
      default:
        return const SizedBox();
    }
  }
}
```

**Progress Indicator**:
```dart
class PhaseProgressIndicator extends StatelessWidget {
  final int currentPhase;
  final int totalPhases;

  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPhases, (index) {
        final isComplete = index < currentPhase - 1;
        final isCurrent = index == currentPhase - 1;
        return Container(
          width: 40,
          height: 4,
          color: isComplete || isCurrent ? AppColor.richRed : AppColor.grey300,
        );
      }),
    );
  }
}
```

---

### 4. History Feature

**Purpose**: View towing history with filtering.

**Data Model**:
```dart
class TowingEntryModel {
  final String id;
  final String plateNumber;
  final String violationType;
  final DateTime towDate;
  final String location;
  final String towedBy;
  final String additionalNotes;
  final String? imagePath;
}
```

**State Management**:
```dart
class HistoryCubit extends Cubit<HistoryState> {
  final List<TowingEntryModel> entries;
  final List<TowingEntryModel> filteredEntries;
  final bool isLoading;
  final ReportFilterCriteria? filter;

  Future<void> loadTowingHistory() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(seconds: 2));
    final entries = await _fetchTowingEntries();
    emit(state.copyWith(
      entries: entries,
      filteredEntries: entries,
      isLoading: false,
    ));
  }

  void applyFilter(ReportFilterCriteria criteria) {
    final filtered = TowingFilterHelper.applyFilter(state.entries, criteria);
    emit(state.copyWith(
      filter: criteria,
      filteredEntries: filtered,
    ));
  }
}
```

**Key Widgets**:
- `AllTowingHistory` - List of entries
- `SingleTowingEntry` - Entry card
- `HistoryPageContent` - Title + filters
- `HistoryListShimmer` - Loading skeleton
- `HistoryDetailContent` - Detail view bottom sheet

---

### 5. Profile Feature

**Purpose**: Display user info and provide logout functionality.

**State Management**:
```dart
class ProfileCubit extends Cubit<ProfileState> {
  final SupabaseUserService supabaseUserService;
  final AuthRemoteDataSource authRemoteDataSource;

  Future<void> loadUserProfile() async {
    emit(state.copyWith(isLoading: true));
    final user = await supabaseUserService.getCachedUser();
    emit(state.copyWith(
      user: user,
      isLoading: false,
    ));
  }

  Future<void> logout(BuildContext context) async {
    emit(state.copyWith(isLoading: true));
    await authRemoteDataSource.signOut();
    await supabaseUserService.clearCachedUser();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        RoutesName.login,
        (route) => false,
      );
    }
  }
}
```

**Key Widgets**:
- `ProfileInfoCard` - User details (name, email, role)
- `ProfileActionCard` - Action buttons (Edit Profile, Settings, Logout)

---

## Shared Components

### Common Widgets

Located in `widgets/common/`:

**1. SummaryCard**
```dart
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
}
```

**2. FilterSection**
```dart
class FilterSection extends StatelessWidget {
  final String activeFilter;
  final VoidCallback onFilterTap;
}
```

**3. SearchTextField**
```dart
class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
}
```

**4. SmallBadgeContainer**
```dart
class SmallBadgeContainer extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
}
```

---

## Data Flow

### From UI to Supabase

```
User Action (Button press)
  ↓
Widget calls Cubit method
  ↓
Cubit updates state (loading: true)
  ↓
Cubit calls data source
  ↓
Data source makes Supabase query
  ↓
Response returned
  ↓
Cubit updates state (data + loading: false)
  ↓
BlocBuilder rebuilds UI
```

**Example**:
```dart
// 1. User taps "Load Reports" button
onPressed: () => getIt<ReportsCubit>().loadActiveReports()

// 2. Cubit method
Future<void> loadActiveReports() async {
  // 3. Show loading
  emit(state.copyWith(isLoadingActive: true));
  
  // 4. Fetch from Supabase
  final response = await Supabase.instance.client
      .from('active_reports')
      .select()
      .order('submit_time', ascending: false);
  
  final reports = response.map((json) => ActiveReportModel.fromJson(json)).toList();
  
  // 5. Update state
  emit(state.copyWith(
    activeReports: reports,
    isLoadingActive: false,
  ));
}

// 6. UI rebuilds with BlocBuilder
BlocBuilder<ReportsCubit, ReportsState>(
  builder: (context, state) {
    if (state.isLoadingActive) return Shimmer();
    return ListView(children: state.activeReports.map((r) => ReportCard(r)).toList());
  },
)
```

---

## Best Practices

### Loading States
Always use shimmer skeletons during data fetching:
```dart
if (state.isLoading) {
  return const LocationShimmer();
}
return ListView(...);
```

### Error Handling
Display user-friendly error messages:
```dart
if (state.errorMessage != null) {
  return ErrorWidget(message: state.errorMessage!);
}
```

### Empty States
Show helpful empty state messages:
```dart
if (state.reports.isEmpty && !state.isLoading) {
  return const EmptyReportsWidget();
}
```

### Navigation
Use dashboard cubit for tab navigation:
```dart
getIt<DashboardCubit>().changeTab(0); // Navigate to Patrol
```

### Data Refresh
Reload data when navigating to a tab:
```dart
onTabChanged: (index) {
  getIt<DashboardCubit>().changeTab(index);
  if (index == 1) getIt<ReportsCubit>().loadActiveReports();
}
```

---

## Summary

The Home feature provides:
- **Dashboard navigation** with 5 main tabs
- **Patrol locations** with search
- **Reports management** with filtering and detail views
- **Tow a car** multi-phase flow
- **Towing history** with filters
- **User profile** with logout
- **Shimmer loading states** for better UX
- **Reusable components** across sub-features
- **Consistent state management** using Cubit pattern
