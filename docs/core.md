# Core Module Documentation

## Overview
The `lib/src/core/` directory contains shared infrastructure used across all features. This includes theming, routing, constants, helpers, services, and reusable widgets.

---

## Directory Structure

```
core/
├── app_style/
│   └── app_theme.dart          # Global Material theme
├── config/
│   ├── injection.dart          # Dependency injection (GetIt)
│   └── config.dart             # App-wide constants
├── constants/
│   ├── colors.dart             # Color palette (AppColor)
│   ├── text_style.dart         # Typography (AppTextStyles)
│   ├── strings.dart            # Static text constants
│   ├── assets.dart             # Asset path constants
│   └── tow_my_whip_icons_icons.dart  # Custom icon font
├── helpers/
│   ├── shared_pref_helper.dart # SharedPreferences wrapper
│   └── spacing.dart            # Spacing helper functions
├── models/
│   ├── common_model.dart       # Shared data structures
│   └── supabase_user_model.dart # User profile model
├── services/
│   ├── supabase_user_service.dart  # User data caching service
│   └── deep_link_service.dart      # Deep link handling
├── networking/
│   └── network_exceptions.dart # Custom exception classes
├── routes/
│   ├── names.dart              # Route name constants
│   └── router.dart             # App routing configuration
└── widgets/
    ├── common_button.dart      # Primary button
    ├── common_secondary_button.dart
    ├── common_form_button.dart
    ├── common_form_text_button.dart
    ├── common_app_bar.dart
    ├── common_app_bar_no_scaffold.dart
    ├── custom_text_field.dart
    ├── filter_button.dart
    └── error_dialog.dart
```

---

## 1. Config

### Dependency Injection (injection.dart)

**Purpose**: Centralized service locator using **GetIt** for managing singleton instances.

**Pattern**: Lazy singleton registration

**Registered Services**:
```dart
// Services
getIt.registerLazySingleton<SharedPrefHelper>(() => SharedPrefHelper());
getIt.registerLazySingleton<SupabaseUserService>(() => SupabaseUserService(sharedPrefHelper: getIt<SharedPrefHelper>()));

// Data Sources
getIt.registerLazySingleton<AuthRemoteDataSource>(() => SupabaseAuthRemoteDataSource());

// Validators
getIt.registerLazySingleton<Validators>(() => Validators());

// Cubits
getIt.registerLazySingleton<AuthCubit>(() => AuthCubit(...));
getIt.registerLazySingleton<DashboardCubit>(() => DashboardCubit());
getIt.registerLazySingleton<PatrolCubit>(() => PatrolCubit());
getIt.registerLazySingleton<ProfileCubit>(() => ProfileCubit(...));
getIt.registerLazySingleton<ReportsCubit>(() => ReportsCubit());
getIt.registerLazySingleton<TowCubit>(() => TowCubit());
getIt.registerLazySingleton<HistoryCubit>(() => HistoryCubit());
```

**Usage Example**:
```dart
// Access registered cubit
final authCubit = getIt<AuthCubit>();

// In widget
getIt<ReportsCubit>().loadActiveReports();
```

**Important**: Always use `getIt<T>()` instead of `context.read<T>()` for singleton cubits.

---

## 2. Constants

### Colors (colors.dart)

**Purpose**: Centralized color palette for consistent theming.

**Primary Colors**:
- `AppColor.richRed` - #C8102E (Primary brand color)
- `AppColor.grey800` - #12181C (Dark text)
- `AppColor.white` - #FFFFFF
- `AppColor.black` - #1C1C1E

**Semantic Colors**:
- `AppColor.red500` - Error/danger states
- `AppColor.green` - Success states
- `AppColor.grey300` - Borders
- `AppColor.grey400` - Disabled text
- `AppColor.grey200` - Background

**Usage**:
```dart
// ✅ CORRECT
Container(color: AppColor.richRed)

// ❌ WRONG - Never hardcode colors
Container(color: Color(0xFFC8102E))
```

### Text Styles (text_style.dart)

**Purpose**: Typography system with consistent fonts and sizes.

**Fonts Used**:
- **Urbanist** - Primary font (headings, body)
- **Figtree** - Secondary font
- **Plus Jakarta Sans** - Accent font

**Naming Convention**: `{font}{size}{color}{weight}{lineHeight}`

**Examples**:
- `AppTextStyles.urbanistFont16Grey800SemiBold1_2`
  - Font: Urbanist
  - Size: 16sp
  - Color: grey800
  - Weight: SemiBold
  - Line Height: 1.2

- `AppTextStyles.figtreeFont14WhiteMedium1_5`
  - Font: Figtree
  - Size: 14sp
  - Color: white
  - Weight: Medium
  - Line Height: 1.5

**Usage**:
```dart
Text(
  'Welcome',
  style: AppTextStyles.urbanistFont24Grey800Bold1_3,
)
```

**Responsive Sizing**: Uses `flutter_screenutil` package (`.sp` for font size).

---

## 3. Helpers

### SharedPrefHelper (shared_pref_helper.dart)

**Purpose**: Wrapper around `SharedPreferences` and `FlutterSecureStorage` with centralized key constants.

**Key Constants**:
```dart
class SharedPrefKeys {
  static const String userData = 'user_data';
  static const String authToken = 'auth_token';
  static const String isLoggedIn = 'is_logged_in';
}
```

**Usage**:
```dart
final prefs = getIt<SharedPrefHelper>();

// Store data
await prefs.setString(SharedPrefKeys.authToken, token);

// Retrieve data
final token = await prefs.getString(SharedPrefKeys.authToken);

// Clear all data
await prefs.clearAll();
```

### Spacing Helper (spacing.dart)

**Purpose**: Consistent spacing throughout the app.

**Functions**:
```dart
Widget verticalSpace(double height) => SizedBox(height: height);
Widget horizontalSpace(double width) => SizedBox(width: width);
```

**Usage**:
```dart
Column(
  children: [
    Text('Title'),
    verticalSpace(16),  // ✅ Preferred
    Text('Subtitle'),
  ],
)

// Instead of:
// SizedBox(height: 16),  // ❌ Less semantic
```

**Recommended spacing values**: 4, 8, 12, 16, 24, 32

---

## 4. Models

### SupabaseUserModel (supabase_user_model.dart)

**Purpose**: Represents user profile data mirroring Supabase `users` table.

**Fields**:
```dart
class SupabaseUserModel {
  final String id;
  final String email;
  final String fullName;
  final bool emailVerified;
  final String? avatarUrl;
  final String? phoneNumber;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Serialization**:
```dart
// From JSON
final user = SupabaseUserModel.fromJson(json);

// To JSON
final json = user.toJson();
```

---

## 5. Services

### SupabaseUserService (supabase_user_service.dart)

**Purpose**: Local caching service for user profile data using `SharedPreferences`.

**Methods**:
```dart
class SupabaseUserService {
  // Cache user profile
  Future<void> cacheUser(SupabaseUserModel user);
  
  // Retrieve cached user
  Future<SupabaseUserModel?> getCachedUser();
  
  // Clear cached user
  Future<void> clearCachedUser();
}
```

**Usage**:
```dart
final userService = getIt<SupabaseUserService>();

// After login
await userService.cacheUser(loggedInUser);

// Retrieve user
final user = await userService.getCachedUser();

// On logout
await userService.clearCachedUser();
```

### DeepLinkService (deep_link_service.dart)

**Purpose**: Handles deep link events for password reset flows.

**Deep Link Format**: `parkmywhip://reset-password`

---

## 6. Networking

### NetworkExceptions (network_exceptions.dart)

**Purpose**: Custom exception handling with user-friendly messages.

**Methods**:
```dart
// Get human-readable error message from Supabase exception
static String getSupabaseExceptionMessage(dynamic exception);

// Get error message from generic exception
static String getExceptionMessage(dynamic exception);
```

**Usage**:
```dart
try {
  await authRemoteDataSource.login(...);
} catch (e) {
  final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
  emit(state.copyWith(errorMessage: errorMessage));
}
```

---

## 7. Routes

### Route Names (names.dart)

**Purpose**: Centralized route name constants.

**Route Constants**:
```dart
class RoutesName {
  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String createPassword = '/create-password';
  static const String enterOtpCode = '/enter-otp';
  static const String dashboard = '/dashboard';
  static const String forgotPassword = '/forgot-password';
  static const String resetLinkSent = '/reset-link-sent';
  static const String resetPassword = '/reset-password';
  static const String passwordResetSuccess = '/password-reset-success';
  static const String resetLinkError = '/reset-link-error';
}
```

### Router (router.dart)

**Purpose**: Centralized routing configuration with BlocProvider injection.

**Key Method**:
```dart
static Route<dynamic> generate(RouteSettings settings)
```

**Initial Route Logic**:
```dart
static Future<String> getInitialRoute() async {
  // Check if user has active Supabase session
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    // Verify cached user data
    final cachedUser = await userService.getCachedUser();
    if (cachedUser != null && cachedUser.emailVerified) {
      return RoutesName.dashboard;
    }
  }
  return RoutesName.login;
}
```

**Route Registration Pattern**:
```dart
case RoutesName.login:
  return MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: const LoginPage(),
    ),
  );
```

---

## 8. Widgets

### Common Buttons

#### CommonButton
**Purpose**: Primary action button with richRed background.

**Props**:
```dart
CommonButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
  bool isEnabled = true,
})
```

#### CommonSecondaryButton
**Purpose**: Secondary action button with outlined style.

#### CommonFormButton
**Purpose**: Form-specific button variant.

#### CommonFormTextButton
**Purpose**: Text-only button for forms (e.g., "Forgot Password?").

### App Bars

#### CommonAppBar
**Purpose**: Standard app bar with Scaffold wrapper.

**Props**:
```dart
CommonAppBar({
  required String title,
  Widget? body,
  bool showBackButton = true,
})
```

#### CommonAppBarNoScaffold
**Purpose**: App bar without Scaffold (for nested use in pages that already have Scaffold).

### Custom TextField

**Purpose**: Reusable text input with validation and consistent styling.

**Props**:
```dart
CustomTextField({
  required TextEditingController controller,
  required String labelText,
  String? errorText,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  ValueChanged<String>? onChanged,
})
```

**Usage**:
```dart
CustomTextField(
  controller: emailController,
  labelText: 'Email Address',
  errorText: state.emailError,
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) => authCubit.onEmailFieldChanged(),
)
```

### Filter Button

**Purpose**: Filter button used in reports and history pages.

---

## Design Conventions

### Import Rules
✅ **Always use absolute imports**:
```dart
import 'package:park_my_whip/src/core/constants/colors.dart';
```

❌ **Never use relative imports**:
```dart
import '../../../core/constants/colors.dart';
```

### Widget Creation
✅ **Create widgets as public classes**:
```dart
class CustomCard extends StatelessWidget {
  final String title;
  const CustomCard({required this.title});
}
```

❌ **Don't create widget functions**:
```dart
Widget _buildCard(String title) { ... }
```

### Logging Standards
✅ **Use `dart:developer`'s `log()` function**:
```dart
import 'dart:developer';

log('User logged in: ${user.id}', name: 'AuthCubit', level: 1000);
log('Loading reports', name: 'ReportsCubit', level: 800);
log('Error: $e', name: 'DataService', level: 900, error: e, stackTrace: stackTrace);
```

**Log Levels**:
- **800**: Info/Debug (normal operations)
- **900**: Warning/Error (errors, exceptions)
- **1000**: Success (important actions completed)

❌ **Don't use `print()` or `debugPrint()`**:
```dart
print('Debug message');  // ❌
debugPrint('Error: $e');  // ❌
```

---

## Key Principles

✅ **DO**:
- Reference centralized `AppColor` and `AppTextStyles`
- Use `getIt<T>()` for singleton access
- Use absolute imports
- Create widgets as public classes
- Use `verticalSpace()` / `horizontalSpace()` for spacing
- Use `log()` from `dart:developer` for all logging

❌ **DON'T**:
- Hardcode colors or text styles
- Use `context.read<T>()` for singleton cubits
- Use relative imports
- Create private widget functions
- Use `print()` or `debugPrint()`
