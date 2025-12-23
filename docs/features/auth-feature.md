# Authentication Feature Documentation

## Overview
The authentication feature handles user signup, login, password reset, and email verification flows using Supabase as the backend.

---

## Feature Structure

```
features/auth/
├── domain/
│   └── validators.dart              # Email, password validation logic
├── data/
│   └── data_sources/
│       ├── auth_remote_data_source.dart        # Abstract interface
│       └── supabase_auth_remote_data_source.dart  # Supabase implementation
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart          # Auth business logic
    │   └── auth_state.dart          # Auth state management
    ├── pages/
    │   ├── login_page.dart
    │   ├── sign_up_pages/
    │   │   ├── sign_up_page.dart           # Step 1: Name + Email
    │   │   ├── create_password_page.dart   # Step 2: Create password
    │   │   └── enter_otp_code_page.dart    # Step 3: Verify OTP
    │   └── reset_password_pages/
    │       ├── forgot_password_page.dart
    │       ├── reset_link_sent_page.dart
    │       ├── reset_password_page.dart
    │       ├── password_reset_success_page.dart
    │       └── reset_link_error_page.dart
    └── widgets/
        ├── dont_have_account_text.dart
        ├── already_have_account_text.dart
        ├── forgot_password.dart
        ├── otp_widget.dart
        └── password_validation_rules.dart
```

---

## User Flows

### 1. Sign Up Flow

**Steps**:
1. **SignUpPage** - User enters name + email
2. **CreatePasswordPage** - User creates password
3. **EnterOtpCodePage** - User verifies email with OTP
4. → **Dashboard** (logged in)

**Flow Diagram**:
```
SignUpPage (name, email)
    ↓
CreatePasswordPage (password)
    ↓
[Account created in Supabase]
    ↓
EnterOtpCodePage (OTP sent to email)
    ↓
[OTP verified → Email confirmed]
    ↓
Dashboard (logged in)
```

**Data Flow**:
```dart
// Step 1: Validate name + email → Navigate to CreatePasswordPage
authCubit.validateSignupForm(context: context);

// Step 2: Create password → Create account → Navigate to OTP page
authCubit.validateCreatePasswordForm(context: context);
  ↓
authCubit.createAccount(context: context);
  ↓
authRemoteDataSource.createAccount(email, password, fullName);
  → Supabase: signUp() + create user profile in users table

// Step 3: OTP page loads → Send OTP
authCubit.sendOtpOnPageLoad(context: context);
  ↓
authRemoteDataSource.sendOtpForEmailVerification(email);
  → Supabase: signInWithOtp()

// Step 4: User enters OTP → Verify → Cache user → Navigate to dashboard
authCubit.continueFromOTPPage(context: context);
  ↓
authRemoteDataSource.verifyOtpAndCompleteSignup(email, otp);
  → Supabase: verifyOTP() + fetch user profile
  ↓
supabaseUserService.cacheUser(user);
```

---

### 2. Login Flow

**Steps**:
1. **LoginPage** - User enters email + password
2. → **Dashboard** (logged in)

**Data Flow**:
```dart
authCubit.validateLoginForm(context: context);
  ↓
authCubit.loginWithSupabase(context: context);
  ↓
authRemoteDataSource.loginWithEmailAndPassword(email, password);
  → Supabase: signInWithPassword()
  → Fetch/create user profile in users table
  ↓
supabaseUserService.cacheUser(user);
  ↓
Navigate to Dashboard
```

---

### 3. Password Reset Flow

**Steps**:
1. **ForgotPasswordPage** - User enters email
2. **ResetLinkSentPage** - Confirmation with resend timer
3. [User clicks link in email] → Deep link opens **ResetPasswordPage**
4. **ResetPasswordPage** - User enters new password
5. **PasswordResetSuccessPage** - Success confirmation
6. → **LoginPage**

**Data Flow**:
```dart
// Step 1: Send reset email
authCubit.sendPasswordResetEmail(context: context);
  ↓
authRemoteDataSource.sendPasswordResetEmail(email);
  → Supabase: resetPasswordForEmail(email, redirectTo: 'parkmywhip://reset-password')
  ↓
Navigate to ResetLinkSentPage (60s countdown timer)

// Step 2: User clicks link → Deep link handled by DeepLinkService
// Opens app at ResetPasswordPage

// Step 3: Submit new password
authCubit.submitPasswordReset(context: context);
  ↓
authRemoteDataSource.updatePassword(newPassword);
  → Supabase: auth.updateUser(UserAttributes(password: newPassword))
  ↓
Navigate to PasswordResetSuccessPage
  ↓
Navigate to LoginPage
```

---

## Domain Layer

### Validators (validators.dart)

**Purpose**: Centralized validation logic for forms.

**Methods**:

```dart
class Validators {
  // Email validation
  String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Name validation
  String? nameValidator(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Password validation (signup)
  String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  // Confirm password validation
  String? conformPasswordValidator(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Login password validation (less strict)
  String? loginPasswordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
}
```

**Usage in Cubit**:
```dart
final emailError = validators.emailValidator(emailController.text.trim());
final passwordError = validators.passwordValidator(passwordController.text.trim());

if (emailError != null || passwordError != null) {
  emit(state.copyWith(
    emailError: emailError,
    passwordError: passwordError,
  ));
  return;
}
```

---

## Data Layer

### AuthRemoteDataSource (Interface)

**Purpose**: Abstract interface for auth operations (allows swapping implementations).

```dart
abstract class AuthRemoteDataSource {
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<bool> sendPasswordResetEmail({required String email});

  Future<bool> updatePassword({required String newPassword});

  Future<bool> signOut();

  Future<bool> createAccount({
    required String email,
    required String password,
    required String fullName,
  });

  Future<bool> sendOtpForEmailVerification({required String email});

  Future<SupabaseUserModel> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  });
}
```

### SupabaseAuthRemoteDataSource (Implementation)

**Purpose**: Concrete implementation using Supabase.

**Key Methods**:

#### 1. Create Account
```dart
Future<bool> createAccount({
  required String email,
  required String password,
  required String fullName,
}) async {
  try {
    // Create auth user in Supabase
    final signUpResponse = await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
      emailRedirectTo: null, // Disable automatic email sending
    );

    if (signUpResponse.user == null) {
      throw Exception('Account creation failed');
    }

    // Create user profile in database
    await _supabaseClient.from('users').insert({
      'id': signUpResponse.user!.id,
      'email': email,
      'full_name': fullName,
      'role': 'user',
      'is_active': true,
      'metadata': {},
    });

    return true;
  } catch (e) {
    log('Create account error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
    rethrow;
  }
}
```

#### 2. Login
```dart
Future<SupabaseUserModel> loginWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    // Sign in with Supabase
    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    // Fetch user profile from users table
    final userProfile = await _supabaseClient
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    // Create profile if doesn't exist
    if (userProfile == null) {
      await _supabaseClient.from('users').insert({...});
      final newProfile = await _supabaseClient.from('users').select().eq('id', response.user!.id).single();
      return SupabaseUserModel.fromJson(newProfile);
    }

    return SupabaseUserModel.fromJson(userProfile);
  } catch (e) {
    log('Login error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
    rethrow;
  }
}
```

#### 3. Send OTP
```dart
Future<bool> sendOtpForEmailVerification({required String email}) async {
  try {
    await _supabaseClient.auth.signInWithOtp(email: email);
    log('OTP sent to $email', name: 'SupabaseAuthRemoteDataSource', level: 800);
    return true;
  } catch (e) {
    log('Send OTP error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
    rethrow;
  }
}
```

#### 4. Verify OTP
```dart
Future<SupabaseUserModel> verifyOtpAndCompleteSignup({
  required String email,
  required String otp,
}) async {
  try {
    // Verify OTP
    final verifyResponse = await _supabaseClient.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.email,
    );

    if (verifyResponse.user == null) {
      throw Exception('OTP verification failed');
    }

    // Fetch user profile
    final userProfile = await _supabaseClient
        .from('users')
        .select()
        .eq('id', verifyResponse.user!.id)
        .single();

    return SupabaseUserModel.fromJson(userProfile);
  } catch (e) {
    log('OTP verification error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
    rethrow;
  }
}
```

#### 5. Password Reset
```dart
Future<bool> sendPasswordResetEmail({required String email}) async {
  try {
    await _supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: 'parkmywhip://reset-password', // Deep link
    );
    return true;
  } catch (e) {
    log('Password reset error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
    rethrow;
  }
}

Future<bool> updatePassword({required String newPassword}) async {
  try {
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return true;
  } catch (e) {
    log('Update password error: $e', name: 'SupabaseAuthRemoteDataSource', level: 900, error: e);
    rethrow;
  }
}
```

---

## Presentation Layer

### AuthCubit

**Key Responsibilities**:
- Form validation
- State management for all auth pages
- Navigation logic
- Error handling
- Timer management (OTP resend, password reset countdown)

**Text Controllers**:
```dart
// Signup
final TextEditingController signUpNameController;
final TextEditingController signUpEmailController;

// Create password
final TextEditingController createPasswordController;
final TextEditingController confirmPasswordController;

// OTP
final TextEditingController otpController;

// Login
final TextEditingController loginEmailController;
final TextEditingController loginPasswordController;

// Forgot password
final TextEditingController forgotPasswordEmailController;

// Reset password
final TextEditingController resetPasswordController;
final TextEditingController resetConfirmPasswordController;
```

**Key Methods**:

```dart
// Signup flow
void onSignUpFieldChanged();
Future<void> validateSignupForm({required BuildContext context});
Future<void> validateCreatePasswordForm({required BuildContext context});
Future<void> createAccount({required BuildContext context});

// OTP flow
void onOtpFieldChanged({required String text});
Future<void> sendOtpOnPageLoad({required BuildContext context});
Future<void> continueFromOTPPage({required BuildContext context});
Future<void> resendOtp({required BuildContext context});
void startOtpResendCountdown();

// Login flow
void onLoginFieldChanged();
Future<void> validateLoginForm({required BuildContext context});
Future<void> loginWithSupabase({required BuildContext context});

// Password reset flow
void onForgotPasswordFieldChanged();
Future<void> validateForgotPasswordForm({required BuildContext context});
Future<void> sendPasswordResetEmail({required BuildContext context});
Future<void> resendPasswordResetEmail({required BuildContext context});
void startResendCountdown();

// Reset password
void onResetPasswordFieldChanged();
Future<void> validateResetPasswordForm({required BuildContext context});
Future<void> submitPasswordReset({required BuildContext context});
```

**Countdown Timer Pattern**:
```dart
Timer? _resendTimer;

void startResendCountdown() {
  _resendTimer?.cancel();
  emit(state.copyWith(resendCountdownSeconds: 60, canResendEmail: false));
  
  _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (state.resendCountdownSeconds > 0) {
      emit(state.copyWith(resendCountdownSeconds: state.resendCountdownSeconds - 1));
    } else {
      emit(state.copyWith(canResendEmail: true));
      timer.cancel();
    }
  });
}

@override
Future<void> close() {
  _resendTimer?.cancel();
  // Dispose controllers...
  return super.close();
}
```

### AuthState

**Fields**:
```dart
class AuthState extends Equatable {
  // Global
  final bool isLoading;
  final String? errorMessage;

  // Signup
  final String? signUpNameError;
  final String? signUpEmailError;
  final bool isSignUpButtonEnabled;

  // Create password
  final bool isCreatePasswordButtonEnabled;
  final String? createPasswordError;
  final String? confirmPasswordError;
  final int createPasswordFieldTrigger;  // For validation rules rebuild

  // OTP
  final String? otpError;
  final bool isOtpButtonEnabled;
  final int otpResendCountdownSeconds;
  final bool canResendOtp;

  // Login
  final String? loginEmailError;
  final String? loginPasswordError;
  final String? loginGeneralError;
  final bool isLoginButtonEnabled;

  // Forgot password
  final String? forgotPasswordEmailError;
  final bool isForgotPasswordButtonEnabled;
  final int resendCountdownSeconds;
  final bool canResendEmail;

  // Reset password
  final String? resetPasswordError;
  final String? resetConfirmPasswordError;
  final bool isResetPasswordButtonEnabled;
  final int resetPasswordFieldTrigger;  // For validation rules rebuild
}
```

---

## Key Widgets

### OtpWidget
**Purpose**: 6-digit PIN code input for OTP verification.

**Package**: `pin_code_fields`

**Usage**:
```dart
OtpWidget(
  controller: authCubit.otpController,
  onChanged: (value) => authCubit.onOtpFieldChanged(text: value),
  errorText: state.otpError,
)
```

### PasswordValidationRules
**Purpose**: Real-time password validation feedback.

**Features**:
- ✓ At least 8 characters
- ✓ One uppercase letter
- ✓ One lowercase letter
- ✓ One number

**Usage**:
```dart
PasswordValidationRules(
  password: authCubit.createPasswordController.text,
)
```

### AlreadyHaveAccountText / DontHaveAccountText
**Purpose**: Navigation links between login and signup.

---

## Error Handling

All auth operations use `NetworkExceptions.getSupabaseExceptionMessage()` to translate Supabase errors into user-friendly messages:

```dart
try {
  await authRemoteDataSource.loginWithEmailAndPassword(...);
} catch (e) {
  final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
  emit(state.copyWith(errorMessage: errorMessage));
}
```

**Common error translations**:
- `Invalid login credentials` → "Invalid email or password"
- `User already registered` → "An account with this email already exists"
- `Email not confirmed` → "Please verify your email first"

---

## Deep Link Integration

**Deep Link Handler**: `DeepLinkService`

**Supported Links**:
- `parkmywhip://reset-password` - Opens ResetPasswordPage

**Router Guard**:
```dart
// In router.dart
case RoutesName.resetPassword:
  return MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: const ResetPasswordPage(),
    ),
  );
```

---

## Testing Considerations

### Unit Tests
- Validators should be tested independently
- AuthCubit methods should be tested with mocked data sources
- State transitions should be verified

### Widget Tests
- Form validation errors should display correctly
- Button states should update based on field input
- Navigation should occur on successful operations

### Integration Tests
- Complete signup flow from start to dashboard
- Login flow with valid/invalid credentials
- Password reset flow end-to-end

---

## Summary

The Auth feature provides:
- **Multi-step signup** with email verification
- **Secure login** with Supabase authentication
- **Password reset** with deep link support
- **Form validation** with real-time feedback
- **Error handling** with user-friendly messages
- **State management** using Cubit pattern
- **Countdown timers** for resend functionality
- **Clean architecture** with separated layers
