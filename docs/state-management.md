# State Management Documentation

## Overview
ParkMyWhip uses **Cubit** (a simplified version of BLoC) for state management. Cubits manage business logic and emit immutable states that trigger UI rebuilds.

---

## Architecture Pattern

### Cubit Pattern
- **Cubit**: Extends `Cubit<State>` and handles business logic
- **State**: Immutable data class with `copyWith()` method
- **BlocBuilder**: Widget that rebuilds when state changes
- **BlocListener**: Handles side effects (navigation, snackbars)

### Why Cubit over BLoC?
- **Simpler**: No need to define events
- **Less boilerplate**: Direct method calls instead of event dispatching
- **Easier to understand**: Better for small to medium apps

---

## Cubit Structure Pattern

### 1. State Class

**Location**: `*_state.dart`

**Pattern**:
```dart
import 'package:equatable/equatable.dart';

class ReportsState extends Equatable {
  final List<ActiveReportModel> activeReports;
  final List<HistoryReportModel> historyReports;
  final bool isLoadingActive;
  final bool isLoadingHistory;
  final String? errorMessage;

  const ReportsState({
    this.activeReports = const [],
    this.historyReports = const [],
    this.isLoadingActive = false,
    this.isLoadingHistory = false,
    this.errorMessage,
  });

  // copyWith() for immutable updates
  ReportsState copyWith({
    List<ActiveReportModel>? activeReports,
    List<HistoryReportModel>? historyReports,
    bool? isLoadingActive,
    bool? isLoadingHistory,
    String? errorMessage,
  }) {
    return ReportsState(
      activeReports: activeReports ?? this.activeReports,
      historyReports: historyReports ?? this.historyReports,
      isLoadingActive: isLoadingActive ?? this.isLoadingActive,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    activeReports,
    historyReports,
    isLoadingActive,
    isLoadingHistory,
    errorMessage,
  ];
}
```

**Key Points**:
- Extends `Equatable` for value equality
- All fields are `final` (immutable)
- Provides `copyWith()` method for state updates
- Lists default to `const []`
- Booleans default to `false`
- Nullable fields for errors/optional data

### 2. Cubit Class

**Location**: `*_cubit.dart`

**Pattern**:
```dart
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(const ReportsState());

  // Load active reports
  Future<void> loadActiveReports() async {
    try {
      // Show loading
      emit(state.copyWith(isLoadingActive: true));

      // Fetch data (mock or API)
      final reports = await _fetchActiveReports();

      // Emit success state
      emit(state.copyWith(
        activeReports: reports,
        isLoadingActive: false,
        errorMessage: null,
      ));

      log('Loaded ${reports.length} active reports', name: 'ReportsCubit', level: 800);
    } catch (e, stackTrace) {
      log('Failed to load active reports: $e', name: 'ReportsCubit', level: 900, error: e, stackTrace: stackTrace);
      
      // Emit error state
      emit(state.copyWith(
        isLoadingActive: false,
        errorMessage: 'Failed to load reports',
      ));
    }
  }

  // Load history reports
  Future<void> loadHistoryReports() async {
    try {
      emit(state.copyWith(isLoadingHistory: true));
      final reports = await _fetchHistoryReports();
      emit(state.copyWith(
        historyReports: reports,
        isLoadingHistory: false,
      ));
      log('Loaded ${reports.length} history reports', name: 'ReportsCubit', level: 800);
    } catch (e) {
      log('Failed to load history reports: $e', name: 'ReportsCubit', level: 900, error: e);
      emit(state.copyWith(
        isLoadingHistory: false,
        errorMessage: 'Failed to load history',
      ));
    }
  }

  // Mock data fetching
  Future<List<ActiveReportModel>> _fetchActiveReports() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      ActiveReportModel(...),
      ActiveReportModel(...),
    ];
  }
}
```

**Key Patterns**:
- Initialize with `super(const State())`
- Always wrap API calls in try-catch
- Use `emit(state.copyWith(...))` to update state
- Log all actions with `dart:developer`'s `log()`
- Include error handling with proper error states

---

## Dependency Injection

### Registration (injection.dart)

```dart
void setupDependencyInjection() {
  // Register as lazy singleton
  getIt.registerLazySingleton<ReportsCubit>(() => ReportsCubit());
  getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(
    validators: getIt<Validators>(),
    supabaseUserService: getIt<SupabaseUserService>(),
    authRemoteDataSource: getIt<AuthRemoteDataSource>(),
  ));
}
```

### Access Cubit

✅ **CORRECT - Use GetIt**:
```dart
// In any widget
final reportsCubit = getIt<ReportsCubit>();
reportsCubit.loadActiveReports();
```

❌ **WRONG - Don't use context.read()**:
```dart
context.read<ReportsCubit>().loadActiveReports();
```

**Reason**: We use GetIt for singleton cubits to maintain consistent access pattern across the app.

---

## UI Integration

### 1. BlocBuilder Pattern

**Purpose**: Rebuild UI when state changes.

**Pattern**:
```dart
BlocBuilder<ReportsCubit, ReportsState>(
  builder: (context, state) {
    // Show loading shimmer
    if (state.isLoadingActive) {
      return const ActiveReportShimmer();
    }

    // Show error message
    if (state.errorMessage != null) {
      return ErrorWidget(message: state.errorMessage!);
    }

    // Show empty state
    if (state.activeReports.isEmpty) {
      return const EmptyReportsWidget();
    }

    // Show data
    return ListView.builder(
      itemCount: state.activeReports.length,
      itemBuilder: (context, index) {
        final report = state.activeReports[index];
        return SingleActiveReport(report: report);
      },
    );
  },
)
```

### 2. BlocListener Pattern

**Purpose**: Handle side effects (navigation, snackbars, dialogs).

**Pattern**:
```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    // Show error dialog
    if (state.errorMessage != null) {
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: state.errorMessage!),
      );
    }

    // Navigate on success
    if (state.isLoginSuccess) {
      Navigator.pushReplacementNamed(context, RoutesName.dashboard);
    }
  },
  child: LoginPageContent(),
)
```

### 3. BlocConsumer Pattern

**Purpose**: Combines BlocBuilder and BlocListener.

**Pattern**:
```dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    // Handle side effects
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }
  },
  builder: (context, state) {
    // Build UI based on state
    if (state.isLoading) {
      return const CircularProgressIndicator();
    }
    return LoginForm();
  },
)
```

---

## Real-World Examples

### Example 1: Authentication Flow

**State**:
```dart
class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;
  final bool isLoginButtonEnabled;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.emailError,
    this.passwordError,
    this.isLoginButtonEnabled = false,
  });

  AuthState copyWith({...}) { ... }

  @override
  List<Object?> get props => [...];
}
```

**Cubit**:
```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.validators,
    required this.authRemoteDataSource,
    required this.supabaseUserService,
  }) : super(const AuthState());

  final Validators validators;
  final AuthRemoteDataSource authRemoteDataSource;
  final SupabaseUserService supabaseUserService;

  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Enable/disable login button based on field state
  void onLoginFieldChanged() {
    final hasEmail = emailController.text.trim().isNotEmpty;
    final hasPassword = passwordController.text.trim().isNotEmpty;
    final shouldEnable = hasEmail && hasPassword;
    
    if (state.isLoginButtonEnabled != shouldEnable) {
      emit(state.copyWith(isLoginButtonEnabled: shouldEnable));
    }
  }

  // Validate and login
  Future<void> validateLoginForm({required BuildContext context}) async {
    final emailError = validators.emailValidator(emailController.text.trim());
    final passwordError = validators.loginPasswordValidator(passwordController.text.trim());

    if (emailError != null || passwordError != null) {
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    await loginWithSupabase(context: context);
  }

  Future<void> loginWithSupabase({required BuildContext context}) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
        emailError: null,
        passwordError: null,
      ));

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final user = await authRemoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      log('User logged in: ${user.id}', name: 'AuthCubit', level: 1000);

      await supabaseUserService.cacheUser(user);

      emit(state.copyWith(isLoading: false));

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.dashboard);
      }
    } catch (e) {
      log('Login error: $e', name: 'AuthCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
```

**UI Usage**:
```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: Scaffold(
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            final authCubit = getIt<AuthCubit>();
            
            return Column(
              children: [
                CustomTextField(
                  controller: authCubit.emailController,
                  labelText: 'Email',
                  errorText: state.emailError,
                  onChanged: (_) => authCubit.onLoginFieldChanged(),
                ),
                CustomTextField(
                  controller: authCubit.passwordController,
                  labelText: 'Password',
                  errorText: state.passwordError,
                  obscureText: true,
                  onChanged: (_) => authCubit.onLoginFieldChanged(),
                ),
                CommonButton(
                  text: 'Login',
                  isEnabled: state.isLoginButtonEnabled,
                  isLoading: state.isLoading,
                  onPressed: () => authCubit.validateLoginForm(context: context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

---

### Example 2: Dashboard Navigation

**State**:
```dart
class DashboardState extends Equatable {
  final int currentIndex;

  const DashboardState({this.currentIndex = 0});

  DashboardState copyWith({int? currentIndex}) {
    return DashboardState(currentIndex: currentIndex ?? this.currentIndex);
  }

  @override
  List<Object?> get props => [currentIndex];
}
```

**Cubit**:
```dart
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  void changeTab(int index) {
    emit(state.copyWith(currentIndex: index));
    log('Tab changed to index $index', name: 'DashboardCubit', level: 800);
  }
}
```

**UI Usage**:
```dart
BlocBuilder<DashboardCubit, DashboardState>(
  builder: (context, state) {
    final pages = [PatrolPage(), ReportsPage(), TowCarPage(), HistoryPage(), ProfilePage()];
    
    return Scaffold(
      body: pages[state.currentIndex],
      bottomNavigationBar: DashboardNavBar(
        currentIndex: state.currentIndex,
        onTabChanged: (index) => getIt<DashboardCubit>().changeTab(index),
      ),
    );
  },
)
```

---

## Advanced Patterns

### 1. Sentinel Values for Nullable State

**Problem**: `copyWith()` can't distinguish between "don't change" and "set to null".

**Solution**: Use sentinel values.

```dart
// Sentinel value
class _NoImageChange {}
final _noImageChange = _NoImageChange();

class TowState extends Equatable {
  final Object? selectedImage;  // Can be String, _NoImageChange, or null

  const TowState({this.selectedImage});

  TowState copyWith({Object? selectedImage = _noImageChange}) {
    return TowState(
      selectedImage: identical(selectedImage, _noImageChange) 
        ? this.selectedImage 
        : selectedImage,
    );
  }

  @override
  List<Object?> get props => [selectedImage];
}
```

### 2. Loading States with Shimmer

**Pattern**: Use explicit loading flags for each data section.

```dart
class ReportsState extends Equatable {
  final List<ActiveReportModel> activeReports;
  final List<HistoryReportModel> historyReports;
  final bool isLoadingActive;
  final bool isLoadingHistory;

  const ReportsState({
    this.activeReports = const [],
    this.historyReports = const [],
    this.isLoadingActive = false,
    this.isLoadingHistory = false,
  });
}
```

**UI Implementation**:
```dart
BlocBuilder<ReportsCubit, ReportsState>(
  builder: (context, state) {
    if (state.isLoadingActive) {
      return const ActiveReportShimmer();
    }
    return ListView.builder(...);
  },
)
```

### 3. Form Validation Triggers

**Pattern**: Use counter fields to force widget rebuilds for validation rules.

```dart
class AuthState extends Equatable {
  final int resetPasswordFieldTrigger;

  const AuthState({this.resetPasswordFieldTrigger = 0});

  AuthState copyWith({int? resetPasswordFieldTrigger}) {
    return AuthState(
      resetPasswordFieldTrigger: resetPasswordFieldTrigger ?? this.resetPasswordFieldTrigger,
    );
  }
}
```

**Cubit**:
```dart
void onResetPasswordFieldChanged() {
  // Increment trigger to force rebuild
  emit(state.copyWith(
    resetPasswordFieldTrigger: state.resetPasswordFieldTrigger + 1,
  ));
}
```

---

## Best Practices

### ✅ DO:
1. **Keep state immutable** - Always use `final` fields
2. **Use `copyWith()` for updates** - Never mutate state directly
3. **Log all state changes** - Use `log()` from `dart:developer`
4. **Handle errors gracefully** - Always wrap async calls in try-catch
5. **Dispose resources** - Override `close()` to dispose controllers/timers
6. **Use explicit loading flags** - Don't rely on list emptiness for loading state
7. **Access cubits via GetIt** - Use `getIt<Cubit>()` consistently

### ❌ DON'T:
1. **Mutate state directly** - `state.list.add(item)` ❌
2. **Forget error handling** - Always catch exceptions
3. **Use `context.read()` for singletons** - Use `getIt<T>()` instead
4. **Create cubits in widgets** - Register in DI container
5. **Forget to dispose** - Always clean up in `close()`
6. **Use `print()` or `debugPrint()`** - Use `log()` instead
7. **Leave loading states hanging** - Always reset `isLoading` in finally block

---

## Testing Cubits

### Unit Test Pattern

```dart
void main() {
  group('ReportsCubit', () {
    late ReportsCubit reportsCubit;

    setUp(() {
      reportsCubit = ReportsCubit();
    });

    tearDown(() {
      reportsCubit.close();
    });

    test('initial state is correct', () {
      expect(reportsCubit.state, const ReportsState());
    });

    test('loadActiveReports emits loading then success', () async {
      // Arrange
      final expectedStates = [
        const ReportsState(isLoadingActive: true),
        ReportsState(
          isLoadingActive: false,
          activeReports: [/* mock data */],
        ),
      ];

      // Act & Assert
      expectLater(
        reportsCubit.stream,
        emitsInOrder(expectedStates),
      );

      await reportsCubit.loadActiveReports();
    });
  });
}
```

---

## Summary

The Cubit pattern in ParkMyWhip provides:
- **Simple state management** without event boilerplate
- **Immutable state** with `copyWith()` pattern
- **Centralized business logic** in cubit classes
- **Easy testing** with predictable state emissions
- **Consistent access** via GetIt dependency injection

All cubits follow the same structure, making the codebase predictable and maintainable.
