# ParkMyWhip Architecture Guide

## Overview
ParkMyWhip is a Flutter mobile application for parking enforcement management. It follows **Clean Architecture** principles with a **feature-first** folder structure under `lib/src/features/`. Each feature is self-contained with its own data models, presentation logic (Cubits), and UI components. Shared utilities, theming, routing, and reusable widgets live under `lib/src/core/` and are accessible to all features.

---

## Project Structure

```
lib/
├── main.dart                          # App entry point, DI setup
├── park_my_whip_app.dart             # Root widget, theme & routing config
└── src/
    ├── core/                          # Shared infrastructure
    │   ├── app_style/
    │   │   └── app_theme.dart         # Global Material theme config
    │   ├── config/
    │   │   ├── injection.dart         # GetIt DI registration
    │   │   └── config.dart            # App-wide constants
    │   ├── constants/
    │   │   ├── colors.dart            # AppColor palette (richRed, grey800, etc.)
    │   │   ├── text_style.dart        # AppTextStyles (Urbanist, Figtree, Plus Jakarta Sans)
    │   │   ├── strings.dart           # Static text constants
    │   │   └── assets.dart            # Asset path constants
    │   ├── helpers/
    │   │   └── spacing.dart           # verticalSpace() / horizontalSpace() helpers
    │   ├── models/
    │   │   └── common_model.dart      # Shared data structures
    │   ├── networking/
    │   │   └── network_exceptions.dart # Custom exception classes
    │   ├── routes/
    │   │   ├── names.dart             # Route name constants
    │   │   └── router.dart            # AppRouter with BlocProvider setup
    │   └── widgets/
    │       ├── common_button.dart     # Primary button (richRed bg)
    │       ├── common_secondary_button.dart # Secondary button variant
    │       ├── common_form_button.dart # Form-specific button
    │       ├── common_form_text_button.dart # Text button for forms
    │       ├── common_app_bar.dart    # Standard app bar with Scaffold
    │       └── common_app_bar_no_scaffold.dart # App bar without Scaffold
    │
    └── features/
        ├── auth/                      # Authentication feature
        │   ├── domain/
        │   │   └── validators.dart    # Email, password validation logic
        │   └── presentation/
        │       ├── cubit/
        │       │   ├── auth_cubit.dart
        │       │   └── auth_state.dart
        │       ├── pages/
        │       │   ├── login_page.dart
        │       │   └── sign_up_pages/
        │       │       ├── sign_up_page.dart
        │       │       ├── enter_otp_code_page.dart
        │       │       └── create_password_page.dart
        │       └── widgets/
        │           ├── custom_text_field.dart
        │           ├── otp_widget.dart
        │           ├── forgot_password.dart
        │           ├── already_have_account_text.dart
        │           └── dont_have_account_text.dart
        │
        └── home/                      # Main app feature (dashboard, reports, patrol, etc.)
            ├── data/
            │   └── models/
            │       ├── active_reports_model.dart
            │       ├── history_report_model.dart
            │       ├── permit_data_model.dart
            │       └── location_model.dart
            └── presentation/
                ├── cubit/
                │   ├── dashboard_cubit/      # Bottom nav state
                │   │   ├── dashboard_cubit.dart
                │   │   └── dashboard_state.dart
                │   ├── report_cubit/         # Active/history reports state
                │   │   ├── reports_cubit.dart
                │   │   └── reports_state.dart
                │   └── patrol_cubit/         # Patrol locations state
                │       ├── patrol_cubit.dart
                │       └── patrol_state.dart
                ├── pages/
                │   ├── dashboard_page.dart   # Main container with bottom nav
                │   └── dashboard_pages/
                │       ├── patrol_page.dart
                │       ├── reports_page.dart
                │       ├── tow_a_car_page.dart
                │       ├── history_page.dart
                │       └── profile_page.dart
                └── widgets/
                    ├── dashboard_nav_bar.dart
                    ├── search_text_filed.dart
                    ├── reports_widgets/      # Reports feature components
                    │   ├── reports_tab_wrapper.dart (Active/History tabs)
                    │   ├── reports_tap_header.dart
                    │   ├── all_active_reports.dart
                    │   ├── all_history_reports.dart
                    │   ├── single_active_report.dart
                    │   ├── single_history_report.dart
                    │   ├── active_report_detail_sheet.dart
                    │   ├── report_small_container.dart
                    │   ├── id_and_admin_role.dart
                    │   ├── car_details_and_submit_time.dart
                    │   └── plate_number_and_reported_by.dart
                    ├── patrol_widgets/       # Patrol feature components
                    │   ├── patrol_page_content.dart
                    │   ├── patrol_header_widget.dart
                    │   ├── all_patrol_locations.dart
                    │   └── logo_and_app_name.dart
                    └── active_permits_widgets/ # Permits feature components
                        ├── active_permit_page_content.dart
                        ├── all_active_permit_list.dart
                        ├── single_permit.dart
                        ├── permit_small_container.dart
                        ├── permits_found.dart
                        └── no_permits_found.dart
```

---

## Architecture Patterns

### 1. **Feature-First Organization**
- Each feature (auth, home) is self-contained with its own layers
- Features do NOT depend on each other (only on `core/`)
- Easy to add new features by duplicating the structure

### 2. **Clean Architecture Layers** (per feature)
- **Domain**: Business logic (validators, entities, use cases)
- **Data**: Models, repositories, data sources (currently mock data)
- **Presentation**: UI (Pages, Widgets) + State Management (Cubits)

### 3. **State Management with Cubit (BLoC Pattern)**
- **Cubit**: Simplified version of BLoC for state management
- **State Classes**: Immutable state using `copyWith()` pattern
- **BlocBuilder**: Rebuild UI when state changes
- **BlocListener**: Side effects (navigation, snackbars)
- **Why Cubit?**: Simpler than full BLoC, no events needed

### 4. **Dependency Injection with GetIt**
- All cubits registered as **lazy singletons** in `injection.dart`
- Access via `getIt<ReportsCubit>()` (not `context.read()`)
- Registered services: `AuthCubit`, `DashboardCubit`, `ReportsCubit`, `PatrolCubit`, `Validators`

### 5. **Navigation with Named Routes**
- Centralized routing in `router.dart`
- Route names in `routes/names.dart`
- BlocProvider automatically injected per route

---

## Key Design Conventions

### **Widget Creation Rules**
1. **Always create widgets as public classes, NOT functions**
   ```dart
   // ✅ CORRECT
   class ReportCard extends StatelessWidget {
     final ActiveReportModel report;
     const ReportCard({required this.report});
   }
   
   // ❌ WRONG
   Widget _buildReportCard(ActiveReportModel report) { ... }
   ```

2. **Component Reusability**
   - Before creating a new widget, check existing components in the feature
   - Extract repeated UI patterns into reusable widgets
   - Use parameters (props) to make components flexible
   - Add documentation comments (///) for public components

3. **Naming Conventions**
   - Pages: `*_page.dart` (e.g., `login_page.dart`)
   - Widgets: Descriptive names (e.g., `report_small_container.dart`)
   - Models: `*_model.dart` (e.g., `active_reports_model.dart`)
   - Cubits: `*_cubit.dart` (e.g., `reports_cubit.dart`)
   - States: `*_state.dart` (e.g., `reports_state.dart`)

### **Import Conventions**
- **Always use absolute imports** (package imports)
  ```dart
  // ✅ CORRECT
  import 'package:park_my_whip/src/core/constants/colors.dart';
  
  // ❌ WRONG
  import '../../../core/constants/colors.dart';
  ```

### **Styling Conventions**

#### Colors
- **Centralized in** `core/constants/colors.dart`
- **Primary palette**: `richRed` (#C8102E), `grey800` (#12181C), `white`, `black`
- **Never hardcode colors** - always use `AppColor.*`
- Example:
  ```dart
  Container(
    color: AppColor.richRed,  // ✅ CORRECT
    // color: Color(0xFFC8102E), ❌ WRONG
  )
  ```

#### Typography
- **Centralized in** `core/constants/text_style.dart`
- **Fonts used**: Urbanist (primary), Figtree, Plus Jakarta Sans
- **Responsive sizing** with `flutter_screenutil` (e.g., `16.sp`)
- **Naming pattern**: `{font}{size}{color}{weight}{lineHeight}`
  - Example: `urbanistFont16Grey800SemiBold1_2`
  - Translates to: Urbanist, 16sp, grey800, SemiBold, 1.2 line height
- **Always reference** `AppTextStyles.*` instead of creating inline styles

#### Spacing
- Use `verticalSpace(height)` and `horizontalSpace(width)` from `core/helpers/spacing.dart`
- Prefer consistent spacing values: 4, 8, 12, 16, 24, 32
- Example:
  ```dart
  Column(
    children: [
      Text('Title'),
      verticalSpace(16),  // ✅ CORRECT
      // SizedBox(height: 16), ❌ AVOID
      Text('Content'),
    ],
  )
  ```

### **Code Style**
1. **Prefer expression bodies** for simple functions
   ```dart
   String get fullName => '$firstName $lastName';  // ✅
   ```

2. **Avoid unnecessary line breaks** - keep code concise
   ```dart
   // ✅ CORRECT
   return Container(color: AppColor.white, child: Text('Hello'));
   
   // ❌ TOO VERBOSE
   return Container(
     color: AppColor.white,
     child: Text(
       'Hello',
     ),
   );
   ```

3. **Use trailing commas only when needed** (multi-line with many parameters)

4. **Split large widget trees** into smaller widget classes (not functions)

---

## State Management Pattern

### Cubit Structure
```dart
// Cubit: Manages business logic and emits states
class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(const ReportsState());

  void loadActiveReports() {
    // Fetch data (currently mock)
    final reports = [...];
    emit(state.copyWith(activeReports: reports));
  }
}

// State: Immutable data class
class ReportsState {
  final List<ActiveReportModel> activeReports;
  final List<HistoryReportModel> historyReports;

  const ReportsState({
    this.activeReports = const [],
    this.historyReports = const [],
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
}
```

### UI Integration
```dart
// In widget:
BlocBuilder<ReportsCubit, ReportsState>(
  builder: (context, state) {
    return ListView.builder(
      itemCount: state.activeReports.length,
      itemBuilder: (context, index) {
        final report = state.activeReports[index];
        return SingleActiveReport(report: report);
      },
    );
  },
)

// Trigger state change:
getIt<ReportsCubit>().loadActiveReports();  // ✅ Use GetIt
// context.read<ReportsCubit>().loadActiveReports(); ❌ DON'T use context.read
```

---

## Data Models Pattern

### Model Structure
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

  ActiveReportModel({
    required this.id,
    required this.adminRole,
    required this.plateNumber,
    required this.reportedBy,
    required this.additionalNotes,
    required this.attachedImage,
    required this.submitTime,
    required this.carDetails,
  });

  factory ActiveReportModel.fromJson(Map<String, dynamic> json) {
    return ActiveReportModel(
      id: json['id'],
      adminRole: json['adminRole'],
      plateNumber: json['plateNumber'],
      reportedBy: json['reportedBy'],
      additionalNotes: json['additionalNotes'],
      attachedImage: json['attachedImage'],
      carDetails: json['carDetails'],
      submitTime: DateTime.parse(json['submitTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminRole': adminRole,
      'plateNumber': plateNumber,
      'reportedBy': reportedBy,
      'additionalNotes': additionalNotes,
      'attachedImage': attachedImage,
      'carDetails': carDetails,
      'submitTime': submitTime.toIso8601String(),
    };
  }
}
```

### Key Patterns
- **Immutable**: All fields are final
- **fromJson**: Factory constructor for API/storage deserialization
- **toJson**: Method for API/storage serialization
- **copyWith**: (Optional) For creating modified copies

---

## Navigation Pattern

### Route Definition
```dart
// 1. Define route name in routes/names.dart
class RoutesName {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String reports = '/reports';
}

// 2. Register route in routes/router.dart
class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.reports:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ReportsCubit>(),
            child: const ReportsPage(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

// 3. Navigate from UI
Navigator.pushNamed(context, RoutesName.reports);
```

---

## Common UI Components

### Buttons
- **CommonButton**: Primary action button (richRed background, white text)
- **CommonSecondaryButton**: Secondary action button (outlined, richRed border)
- **CommonFormButton**: Form-specific button variant
- **CommonFormTextButton**: Text-only button for forms

### App Bars
- **CommonAppBar**: Standard app bar with Scaffold wrapper
- **CommonAppBarNoScaffold**: App bar without Scaffold (for nested use)

### Forms
- **CustomTextField**: Reusable text input with validation
- **OtpWidget**: PIN code input for OTP verification

### Layout Helpers
- **verticalSpace(double height)**: Adds vertical spacing (SizedBox)
- **horizontalSpace(double width)**: Adds horizontal spacing (SizedBox)

---

## Feature-Specific Patterns

### Reports Feature
1. **Two-tab layout**: Active Reports | History Reports
2. **Tab switching logic**: In `reports_tab_wrapper.dart`
   - TabController listens for tab changes
   - Calls `getIt<ReportsCubit>().loadActiveReports()` on index 0
   - Calls `getIt<ReportsCubit>().loadHistoryReports()` on index 1
3. **Reusable components**:
   - `IdAndAdminRole`: Shows report ID + admin role chip
   - `CarDetailsAndSubmitTime`: Shows car details + submission time
   - `PlateNumberAndReportedBy`: Shows plate number + reporter
4. **Detail view**: Bottom sheet (`active_report_detail_sheet.dart`) with:
   - Reusable header components
   - Additional notes section
   - Image preview
   - Primary action button ("Mark as Towed")

### Dashboard Feature
1. **Bottom navigation**: 5 tabs (Patrol, Reports, Tow a Car, History, Profile)
2. **State management**: `DashboardCubit` tracks current tab index
3. **Each tab**: Separate page in `dashboard_pages/`

### Authentication Feature
1. **Multi-step sign-up**: SignUp → OTP → Create Password
2. **Validation**: Centralized in `domain/validators.dart`
3. **State**: `AuthCubit` manages auth flow (loading, success, error)

---

## Backend Integration (Future)

Currently using **mock data** in cubits. When connecting to Firebase/Supabase:

1. **Create repository layer** under `features/*/data/repositories/`
2. **Create data sources** under `features/*/data/data_sources/`
3. **Inject repositories** into cubits via GetIt
4. **Keep cubit interface unchanged** - only swap data source

Example:
```dart
// Current (mock)
class ReportsCubit extends Cubit<ReportsState> {
  void loadActiveReports() {
    final reports = [...mockData];  // ❌ Mock
    emit(state.copyWith(activeReports: reports));
  }
}

// Future (real backend)
class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository repository;
  ReportsCubit(this.repository);

  Future<void> loadActiveReports() async {
    try {
      final reports = await repository.getActiveReports();  // ✅ Real API
      emit(state.copyWith(activeReports: reports));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
```

---

## Dependencies Overview

### Core Dependencies
- **flutter_bloc** (^9.1.1): State management (Cubit pattern)
- **get_it** (^9.2.0): Dependency injection (service locator)
- **equatable** (^2.0.7): Value equality for state classes

### UI & Design
- **flutter_screenutil** (^5.9.3): Responsive sizing (.sp, .w, .h)
- **google_fonts** (^6.3.2): Custom fonts (Urbanist, Figtree, Plus Jakarta Sans)

### Storage & Data
- **shared_preferences** (^2.5.3): Local key-value storage
- **intl** (^0.19.0): Date/number formatting

### Forms
- **pin_code_fields** (^8.0.1): OTP input widget

### Backend (Future)
- **firebase_core** (^3.8.0): Firebase SDK (not yet integrated)

---

## When Creating a New Feature

1. **Create feature folder** under `lib/src/features/{feature_name}/`
2. **Add layers**:
   - `data/models/` - Data models with fromJson/toJson
   - `domain/` - Business logic (validators, use cases)
   - `presentation/cubit/` - State management
   - `presentation/pages/` - Full-screen pages
   - `presentation/widgets/` - Reusable components
3. **Register cubit** in `core/config/injection.dart`:
   ```dart
   getIt.registerLazySingleton<FeatureCubit>(() => FeatureCubit());
   ```
4. **Add routes** in `core/routes/`:
   - Add route name to `names.dart`
   - Register route in `router.dart`
5. **Follow naming conventions**:
   - Use absolute imports
   - Reference `AppColor` and `AppTextStyles`
   - Create widgets as classes, not functions
   - Use `verticalSpace()` / `horizontalSpace()` for spacing
6. **State management**:
   - Access cubits via `getIt<Cubit>()`, NOT `context.read()`
   - Use `BlocBuilder` for UI updates
   - Keep state classes immutable with `copyWith()`

---

## Testing Strategy (Future)

- **Unit tests**: Cubits, validators, business logic
- **Widget tests**: Individual components
- **Integration tests**: Full user flows
- **Test location**: `test/` directory (mirrors `lib/` structure)

---

## Recent Updates

### 2025-02-14
- ✅ Added `ActiveReportDetailSheet` bottom sheet for viewing full report details
- ✅ Implemented tab refresh logic: Active/History reports reload on tab switch
- ✅ Migrated from `context.read()` to `getIt<Cubit>()` for accessing singletons
- ✅ Extracted reusable report components: `IdAndAdminRole`, `CarDetailsAndSubmitTime`, `PlateNumberAndReportedBy`
- ✅ Fixed Spacer rendering errors by removing ScrollView from fixed-height sheets

---

## Key Principles Summary

✅ **DO**:
- Use feature-first organization
- Create widgets as public classes
- Access cubits via GetIt (`getIt<Cubit>()`)
- Reference centralized colors/text styles
- Use absolute imports
- Keep state immutable
- Extract reusable components
- Document public widgets with ///

❌ **DON'T**:
- Create widget functions (use classes)
- Use `context.read()` for singleton cubits
- Hardcode colors or text styles
- Use relative imports
- Mutate state directly
- Duplicate UI code
- Create private widgets that could be reusable

---

**This architecture ensures**:
- 🎯 Consistent codebase structure
- 🔄 Easy feature addition/removal
- 🧪 Testable business logic
- 🎨 Unified design system
- 📦 Loose coupling between features
- 🚀 Scalable state management
