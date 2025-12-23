# ParkMyWhip Documentation

Welcome to the comprehensive documentation for the **ParkMyWhip** Flutter application. This documentation provides detailed information about the architecture, features, state management, data layer, and backend integration.

---

## 📚 Documentation Structure

### Core Documentation

#### **[Core Module](./core.md)**
Complete guide to shared infrastructure:
- **Configuration**: Dependency injection (GetIt), app constants
- **Constants**: Colors, typography, strings, assets
- **Helpers**: SharedPreferences wrapper, spacing utilities
- **Models**: User models, common data structures
- **Services**: User service, deep link handling
- **Networking**: Error handling and exception utilities
- **Routes**: Centralized routing configuration
- **Widgets**: Reusable common widgets (buttons, app bars, text fields)

#### **[State Management](./state-management.md)**
In-depth guide to Cubit (BLoC) pattern:
- Cubit structure and patterns
- State class design with `copyWith()`
- UI integration with BlocBuilder/BlocListener
- Dependency injection with GetIt
- Real-world examples (Auth, Dashboard, Reports)
- Advanced patterns (sentinel values, loading states, form validation)
- Testing strategies

#### **[Data Layer](./data-layer.md)**
Complete data management guide:
- Model structure patterns
- All data models (User, Location, Reports, Permits, Towing, Filters)
- Serialization best practices (JSON, DateTime, nullable fields)
- Data source interfaces and implementations
- Supabase query patterns
- Error handling with NetworkExceptions
- Testing data models

#### **[Supabase Integration](./supabase-integration.md)**
Backend integration documentation:
- Setup and configuration
- Complete database schema (6 tables)
- SQL migrations with triggers
- Row Level Security (RLS) policies
- Authentication flows (signup, login, OTP, password reset)
- Database operations (CRUD patterns)
- Real-time subscriptions (future)
- File storage (future)
- Security best practices
- Performance optimization
- Troubleshooting guide

---

### Feature Documentation

#### **[Authentication Feature](./features/auth-feature.md)**
Complete auth system documentation:
- **User Flows**: Signup (3 steps), Login, Password Reset (5 steps)
- **Domain Layer**: Form validators (email, password, name)
- **Data Layer**: AuthRemoteDataSource interface, Supabase implementation
- **Presentation Layer**: AuthCubit with all methods, AuthState management
- **UI Components**: OTP widget, password validation, navigation links
- **Deep Link Integration**: Password reset deep link handling
- **Error Handling**: User-friendly error messages

#### **[Home Feature](./features/home-feature.md)**
Main dashboard and sub-features:
- **Dashboard**: Bottom navigation with 5 tabs
- **Patrol**: Location listing with search
- **Reports**: Active/History tabs with filtering
- **Tow a Car**: 6-phase violation reporting flow
- **History**: Towing history with filters
- **Profile**: User info and logout
- **Shared Components**: Reusable widgets across features
- **Data Flow**: UI → Cubit → Data Source → Supabase
- **Best Practices**: Loading states, error handling, empty states

---

## 🎯 Quick Start Guide

### For New Developers

1. **Start with Architecture**:
   - Read `../architecture.md` for high-level overview
   - Understand feature-first organization
   - Review clean architecture layers

2. **Understand State Management**:
   - Read `state-management.md`
   - Study Cubit pattern examples
   - Learn GetIt dependency injection

3. **Study Core Module**:
   - Read `core.md`
   - Familiarize with constants (colors, text styles)
   - Learn reusable widgets

4. **Learn Data Layer**:
   - Read `data-layer.md`
   - Understand model structure
   - Study serialization patterns

5. **Explore Features**:
   - Read `features/auth-feature.md` for auth flows
   - Read `features/home-feature.md` for main features

6. **Backend Integration**:
   - Read `supabase-integration.md`
   - Understand database schema
   - Learn query patterns

---

## 🔑 Key Concepts

### Clean Architecture
- **Domain**: Business logic, validators
- **Data**: Models, data sources, repositories
- **Presentation**: UI (pages, widgets) + State (Cubits)

### Feature-First Organization
```
features/
├── auth/              # Self-contained auth feature
│   ├── domain/
│   ├── data/
│   └── presentation/
└── home/              # Self-contained home feature
    ├── data/
    └── presentation/
```

### State Management Flow
```
User Action → Widget → Cubit Method
                ↓
          Cubit updates state
                ↓
          emit(new state)
                ↓
        BlocBuilder rebuilds UI
```

### Data Flow
```
UI → Cubit → Data Source → Supabase
                ↓
         Model.fromJson()
                ↓
        State updated
                ↓
        UI rebuilds
```

---

## 📋 Code Conventions

### Imports
```dart
// ✅ Always use absolute imports
import 'package:park_my_whip/src/core/constants/colors.dart';

// ❌ Never use relative imports
import '../../../core/constants/colors.dart';
```

### Widget Creation
```dart
// ✅ Create widgets as public classes
class ReportCard extends StatelessWidget {
  final ActiveReportModel report;
  const ReportCard({required this.report});
}

// ❌ Don't create widget functions
Widget _buildReportCard(ActiveReportModel report) { ... }
```

### State Access
```dart
// ✅ Use GetIt for singleton cubits
getIt<ReportsCubit>().loadActiveReports();

// ❌ Don't use context.read() for singletons
context.read<ReportsCubit>().loadActiveReports();
```

### Styling
```dart
// ✅ Use centralized constants
Container(color: AppColor.richRed)
Text('Title', style: AppTextStyles.urbanistFont16Grey800SemiBold1_2)

// ❌ Don't hardcode styles
Container(color: Color(0xFFC8102E))
Text('Title', style: TextStyle(fontSize: 16, color: Colors.grey))
```

### Logging
```dart
// ✅ Use dart:developer log()
import 'dart:developer';
log('User logged in: ${user.id}', name: 'AuthCubit', level: 1000);

// ❌ Don't use print() or debugPrint()
print('User logged in');
debugPrint('User logged in');
```

---

## 🛠️ Common Patterns

### Loading State with Shimmer
```dart
if (state.isLoading) {
  return const ReportShimmer();
}
return ListView(...);
```

### Error Handling
```dart
try {
  await dataSource.fetchData();
} catch (e) {
  final message = NetworkExceptions.getSupabaseExceptionMessage(e);
  emit(state.copyWith(errorMessage: message));
}
```

### Empty State
```dart
if (state.reports.isEmpty && !state.isLoading) {
  return const EmptyReportsWidget();
}
return ListView(...);
```

### Form Validation
```dart
final emailError = validators.emailValidator(email);
if (emailError != null) {
  emit(state.copyWith(emailError: emailError));
  return;
}
```

---

## 📱 App Architecture Overview

```
ParkMyWhip
├── Entry Point: main.dart
├── Root Widget: park_my_whip_app.dart
├── Core Module (Shared)
│   ├── Theme & Styling
│   ├── Routing
│   ├── DI (GetIt)
│   ├── Common Widgets
│   └── Services
└── Features
    ├── Auth
    │   ├── Login
    │   ├── Signup (3 steps)
    │   └── Password Reset
    └── Home (Dashboard)
        ├── Patrol (Locations)
        ├── Reports (Active/History)
        ├── Tow a Car (6 phases)
        ├── History (Towing records)
        └── Profile (User info)
```

---

## 🗄️ Database Schema

### Tables
1. **users** - User profiles (extends auth.users)
2. **locations** - Patrol locations
3. **permits** - Parking permits
4. **active_reports** - Current violation reports
5. **history_reports** - Archived reports
6. **towing_entries** - Towing history records

See `supabase-integration.md` for complete schema and policies.

---

## 🧪 Testing Guidelines

### Unit Tests
- Test validators independently
- Test Cubit state transitions
- Mock data sources

### Widget Tests
- Test UI components in isolation
- Verify form validation displays correctly
- Test button state changes

### Integration Tests
- Test complete user flows (signup → login → dashboard)
- Test navigation between features
- Test data persistence

---

## 🔐 Security

### Authentication
- Email/password authentication via Supabase
- OTP email verification
- Secure password reset with deep links
- Session management with JWT tokens

### Data Protection
- Row Level Security (RLS) on all tables
- User-specific data access policies
- Secure storage of sensitive data
- Never expose service role key in client

---

## 🚀 Performance

### Optimization Strategies
- Lazy loading with GetIt
- Local caching with SharedPreferences
- Database indexing on frequently queried columns
- Pagination for large data sets
- Shimmer loading states for better UX

---

## 📖 Additional Resources

### Internal References
- `../architecture.md` - High-level architecture overview
- `../README.md` - Project README (if exists)

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [flutter_bloc Documentation](https://bloclibrary.dev)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Supabase Documentation](https://supabase.com/docs)

---

## 🤝 Contributing

When adding new features or modifying existing ones:

1. **Follow existing patterns** - Study similar features first
2. **Update documentation** - Keep these docs in sync with code
3. **Write tests** - Unit tests for business logic, widget tests for UI
4. **Use proper logging** - Use `log()` with appropriate levels
5. **Follow naming conventions** - Consistent naming across the app
6. **Add to architecture.md** - Update if making architectural changes

---

## 📝 Document Maintenance

### When to Update These Docs

- **New feature added** - Create feature documentation
- **State management changes** - Update `state-management.md`
- **New data models** - Update `data-layer.md`
- **Database schema changes** - Update `supabase-integration.md`
- **New shared widgets** - Update `core.md`
- **Architecture changes** - Update `../architecture.md` and relevant docs

---

## 📞 Support

For questions or clarifications:
1. Read the relevant documentation section
2. Check `architecture.md` for high-level context
3. Review code examples in documentation
4. Study existing implementations in codebase

---

**Last Updated**: March 2025

This documentation is maintained alongside the codebase to ensure accuracy and completeness.
