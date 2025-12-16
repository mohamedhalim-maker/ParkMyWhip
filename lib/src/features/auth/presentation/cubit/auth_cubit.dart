import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/services/supabase_user_service.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'auth_state.dart' as app_auth;

class AuthCubit extends Cubit<app_auth.AuthState> {
  AuthCubit({
    required this.validators,
    required this.supabaseUserService,
  }) : super(const app_auth.AuthState());

  final Validators validators;
  final SupabaseUserService supabaseUserService;

  // Text controllers for signup form
  final TextEditingController signUpNameController = TextEditingController();
  final TextEditingController signUpEmailController = TextEditingController();
  final TextEditingController signUpPasswordController =
      TextEditingController();
  final TextEditingController signUpConfirmPasswordController =
      TextEditingController();
  // Text controllers for create password form
  final TextEditingController createPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  // Text controllers for otp form
  final TextEditingController otpController = TextEditingController();
  // Text controllers for login form
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Update button state when field changes
  void onSignUpFieldChanged() {
    final hasName = signUpNameController.text.trim().isNotEmpty;
    final hasEmail = signUpEmailController.text.trim().isNotEmpty;
    final shouldEnable = hasName && hasEmail;
    if (state.isSignUpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isSignUpButtonEnabled: shouldEnable));
    }
  }

  // Validate signup form on continue button press
  void validateSignupForm({required BuildContext context}) {
    final nameError = validators.nameValidator(
      signUpNameController.text.trim(),
    );
    final emailError = validators.emailValidator(
      signUpEmailController.text.trim(),
    );

    emit(
      state.copyWith(signUpNameError: nameError, signUpEmailError: emailError),
    );

    // If no errors, proceed with signup logic
    if (nameError == null && emailError == null) {
      Navigator.pushNamed(context, RoutesName.enterOtpCode);
    } else {
      emit(
        state.copyWith(
          signUpNameError: nameError,
          signUpEmailError: emailError,
        ),
      );
    }
  }

  // Clear form errors
  void clearErrors() {
    emit(state.copyWith(signUpNameError: null, signUpEmailError: null));
  }

  // navigate to login page
  void navigateToLoginPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.login);
  }
  //********************************************** otp ************************** */

  void onOtpFieldChanged({required String text}) {
    final hasOtp = text.length == 5;
    final shouldEnable = hasOtp;
    if (state.isOtpButtonEnabled != shouldEnable) {
      emit(state.copyWith(isOtpButtonEnabled: shouldEnable));
    }
  }

  // Validate otp form on continue button press
  void continueFromOTPPage({required BuildContext context}) {
    if (otpController.text == '12345') {
      Navigator.pushNamed(context, RoutesName.createPassword);
    } else {
      emit(state.copyWith(otpError: 'Invalid OTP'));
    }
  }
  //********************************************** create password ************************** */

  void onCreatePasswordFieldChanged() {
    final hasPassword = createPasswordController.text.trim().isNotEmpty;
    final hasConfirmPassword = confirmPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasPassword && hasConfirmPassword;
    if (state.isCreatePasswordButtonEnabled != shouldEnable) {
      emit(state.copyWith(isCreatePasswordButtonEnabled: shouldEnable));
    }
  }

  void validateCreatePasswordForm({required BuildContext context}) {
    final createPasswordError = validators.passwordValidator(
      createPasswordController.text.trim(),
    );
    final confirmPasswordError = validators.conformPasswordValidator(
      createPasswordController.text.trim(),
      confirmPasswordController.text.trim(),
    );

    // If no errors, proceed with create password logic
    if (createPasswordError == null && confirmPasswordError == null) {
      Navigator.pushNamed(context, RoutesName.login);
    } else {
      emit(
        state.copyWith(
          createPasswordError: createPasswordError,
          confirmPasswordError: confirmPasswordError,
        ),
      );
    }
  }

  //************************************ login ************************** */
  navigateToSignUpPage({required BuildContext context}) {
    Navigator.pushNamed(context, RoutesName.signup);
  }

  void onLoginFieldChanged() {
    final hasEmail = loginEmailController.text.trim().isNotEmpty;
    final hasPassword = loginPasswordController.text.trim().isNotEmpty;
    final shouldEnable = hasEmail && hasPassword;
    if (state.isLoginButtonEnabled != shouldEnable) {
      emit(state.copyWith(isLoginButtonEnabled: shouldEnable));
    }
  }

  Future<void> validateLoginForm({required BuildContext context}) async {
    final emailError = validators.emailValidator(
      loginEmailController.text.trim(),
    );
    final passwordError = validators.loginPasswordValidator(
      loginPasswordController.text.trim(),
    );

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          loginEmailError: emailError,
          loginPasswordError: passwordError,
        ),
      );
      return;
    }

    // If no validation errors, proceed with Supabase login
    await loginWithSupabase(context: context);
  }

  Future<void> loginWithSupabase({required BuildContext context}) async {
    try {
      // Clear previous errors and show loading
      emit(state.copyWith(
        isLoading: true,
        loginGeneralError: null,
        loginEmailError: null,
        loginPasswordError: null,
      ));

      final email = loginEmailController.text.trim();
      final password = loginPasswordController.text.trim();

      // Sign in with Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        emit(state.copyWith(
          isLoading: false,
          loginGeneralError: 'Login failed. Please try again.',
        ));
        return;
      }

      debugPrint('AuthCubit: User logged in successfully: \${user.id}');

      // Fetch user profile from users table
      final userProfile = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        debugPrint('AuthCubit: User profile not found, creating new profile');
        // Create user profile if it doesn't exist
        await Supabase.instance.client.from('users').insert({
          'id': user.id,
          'email': user.email ?? email,
          'full_name': user.userMetadata?['full_name'] ?? 'User',
          'phone': user.phone,
          'role': 'user',
          'is_active': true,
          'metadata': {},
        });

        // Fetch the newly created profile
        final newProfile = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single();
        
        // Save to local storage
        final supabaseUser = SupabaseUserModel(
          id: user.id,
          email: user.email ?? email,
          fullName: newProfile['full_name'] ?? 'User',
          emailVerified: user.emailConfirmedAt != null,
          avatarUrl: newProfile['avatar_url'],
          phoneNumber: newProfile['phone'],
          metadata: Map<String, dynamic>.from(newProfile['metadata'] ?? {}),
          createdAt: DateTime.parse(newProfile['created_at']),
          updatedAt: DateTime.parse(newProfile['updated_at']),
        );
        await supabaseUserService.cacheUser(supabaseUser);
      } else {
        debugPrint('AuthCubit: User profile found, caching user data');
        // Save user data to SharedPreferences
        final supabaseUser = SupabaseUserModel(
          id: user.id,
          email: user.email ?? email,
          fullName: userProfile['full_name'] ?? 'User',
          emailVerified: user.emailConfirmedAt != null,
          avatarUrl: userProfile['avatar_url'],
          phoneNumber: userProfile['phone'],
          metadata: Map<String, dynamic>.from(userProfile['metadata'] ?? {}),
          createdAt: DateTime.parse(userProfile['created_at']),
          updatedAt: DateTime.parse(userProfile['updated_at']),
        );
        await supabaseUserService.cacheUser(supabaseUser);
      }

      // Navigate to dashboard
      emit(state.copyWith(isLoading: false));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RoutesName.dashboard);
      }
    } on AuthException catch (e) {
      debugPrint('AuthCubit: Supabase auth error: \${e.message}');
      emit(state.copyWith(
        isLoading: false,
        loginGeneralError: _getAuthErrorMessage(e.message),
      ));
    } catch (e, stackTrace) {
      debugPrint('AuthCubit: Login error: \$e');
      debugPrint('AuthCubit: Stack trace: \$stackTrace');
      emit(state.copyWith(
        isLoading: false,
        loginGeneralError: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  String _getAuthErrorMessage(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (message.contains('Email not confirmed')) {
      return 'Please verify your email address before logging in.';
    } else if (message.contains('User not found')) {
      return 'No account found with this email.';
    }
    return 'Login failed. Please check your credentials and try again.';
  }

  @override
  Future<void> close() {
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    signUpConfirmPasswordController.dispose();
    createPasswordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
