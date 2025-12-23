import 'package:park_my_whip/src/core/config/config.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/models/email_check_result.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete implementation of [AuthRemoteDataSource] using Supabase
/// 
/// This class follows the Single Responsibility Principle by focusing solely
/// on authentication operations. User profile management is delegated to
/// a separate helper class to maintain separation of concerns.
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  late final _UserProfileRepository _profileRepo;

  SupabaseAuthRemoteDataSource({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client {
    _profileRepo = _UserProfileRepository(_supabaseClient);
  }

  @override
  Future<EmailCheckResult> checkEmailForApp({
    required String email,
    required String appId,
  }) async {
    try {
      _logInfo('Checking email $email for app $appId');

      final response = await _supabaseClient.rpc(
        DbStrings.getUserByEmailWithAppCheck,
        params: {
          'user_email': email,
          'p_app_id': appId,
        },
      );

      final result = EmailCheckResult.fromRpcResponse(
        response as Map<String, dynamic>?,
      );

      _logSuccess('Email check result: ${result.status}');
      return result;
    } catch (e, stackTrace) {
      _logError('Email check failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<SupabaseUserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logInfo('Attempting login for $email');

      final authResponse = await _signInWithPassword(email, password);
      final user = _validateAuthResponse(authResponse);

      _logSuccess('User logged in: ${user.id}');

      return await _profileRepo.getOrCreateUserProfile(user, email);
    } catch (e, stackTrace) {
      _logError('Login failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> sendPasswordResetEmail({required String email}) async {
    try {
      _logInfo('Sending password reset to $email');

      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: AuthConstStrings.passwordResetDeepLink,
      );

      _logSuccess('Password reset email sent');
      return true;
    } catch (e, stackTrace) {
      _logError('Password reset failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> updatePassword({required String newPassword}) async {
    try {
      _logInfo('Updating password');

      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _logSuccess('Password updated successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Update password failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      _logInfo('Signing out user');
      await _supabaseClient.auth.signOut();
      _logSuccess('User signed out successfully');
      return true;
    } catch (e, stackTrace) {
      _logError('Sign out failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _logInfo('Creating account for $email');

      final authResponse = await _signUpWithEmail(email, password, fullName);
      final user = _validateAuthResponse(authResponse);

      _logSuccess('Account created. User ID: ${user.id}');

      await _profileRepo.createUserProfile(user.id, email, fullName);

      _logSuccess('User profile created in database');
      return true;
    } catch (e, stackTrace) {
      _logError('Create account failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> sendOtpForEmailVerification({required String email}) async {
    try {
      _logInfo('Sending OTP to $email');

      await _supabaseClient.auth.signInWithOtp(email: email);

      _logSuccess('OTP sent to $email');
      return true;
    } catch (e, stackTrace) {
      _logError('Send OTP failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<SupabaseUserModel> verifyOtpAndCompleteSignup({
    required String email,
    required String otp,
  }) async {
    try {
      _logInfo('Verifying OTP for $email');

      final verifyResponse = await _verifyOtp(email, otp);
      final user = _validateAuthResponse(verifyResponse);

      _logSuccess('Email verified successfully');

      return await _profileRepo.getUserProfile(user.id, email, emailVerified: true);
    } catch (e, stackTrace) {
      _logError('OTP verification failed', e, stackTrace);
      rethrow;
    }
  }

  // ========== Private Auth Methods ==========

  Future<AuthResponse> _signInWithPassword(String email, String password) =>
      _supabaseClient.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> _signUpWithEmail(String email, String password, String fullName) =>
      _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {DbStrings.fullName: fullName},
        emailRedirectTo: null,
      );

  Future<AuthResponse> _verifyOtp(String email, String otp) =>
      _supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

  User _validateAuthResponse(AuthResponse response) {
    if (response.user == null) {
      throw _AuthException(ErrorStrings.authFailed);
    }
    return response.user!;
  }

  // ========== Logging Helpers ==========

  void _logInfo(String message) => AppLogger.auth(message);

  void _logSuccess(String message) => AppLogger.auth(message);

  void _logError(String message, Object error, [StackTrace? stackTrace]) {
    final errorDetails = StringBuffer(message);
    if (error is AuthException) {
      errorDetails.write(' | Status: ${error.statusCode}, Message: ${error.message}');
    }
    if (error is PostgrestException) {
      errorDetails.write(' | DB Code: ${error.code}, Message: ${error.message}');
    }
    AppLogger.error(errorDetails.toString(), name: 'Auth', error: error, stackTrace: stackTrace);
  }
}

// ========== User Profile Repository ==========
/// Handles all user profile database operations
/// Separated from auth logic to follow Single Responsibility Principle
class _UserProfileRepository {
  final SupabaseClient _client;

  _UserProfileRepository(this._client);

  /// Gets existing user profile or creates one if it doesn't exist
  /// Also ensures user_apps record exists for the current app
  Future<SupabaseUserModel> getOrCreateUserProfile(User user, String email) async {
    final profile = await _fetchUserProfile(user.id);

    if (profile == null) {
      AppLogger.database('Creating new user profile for user ${user.id}');
      await createUserProfile(
        user.id,
        user.email ?? email,
        user.userMetadata?[DbStrings.fullName] ?? AuthConstStrings.defaultUserName,
      );
      final newProfile = await _fetchUserProfile(user.id, required: true);
      return _mapToUserModel(user, newProfile!, email);
    }

    // Ensure user_apps record exists
    await _ensureUserAppRecord(user.id);

    return _mapToUserModel(user, profile, email);
  }

  /// Fetches user profile by user ID
  Future<SupabaseUserModel> getUserProfile(
    String userId,
    String email, {
    bool emailVerified = false,
  }) async {
    final profile = await _fetchUserProfile(userId, required: true);

    // Ensure user_apps record exists
    await _ensureUserAppRecord(userId);

    return SupabaseUserModel(
      id: userId,
      email: email,
      fullName: profile![DbStrings.fullName] ?? AuthConstStrings.defaultUserName,
      emailVerified: emailVerified,
      avatarUrl: profile[DbStrings.avatarUrl],
      phoneNumber: profile[DbStrings.phone],
      metadata: Map<String, dynamic>.from(profile[DbStrings.metadata] ?? {}),
      createdAt: DateTime.parse(profile[DbStrings.createdAt]),
      updatedAt: DateTime.parse(profile[DbStrings.updatedAt]),
    );
  }

  /// Creates a new user profile in the database
  /// Also creates user_apps record for the current app
  Future<void> createUserProfile(String userId, String email, String fullName) async {
    try {
      // Create users record
      await _client.from(DbStrings.usersTable).insert({
        DbStrings.id: userId,
        DbStrings.email: email,
        DbStrings.fullName: fullName,
        DbStrings.role: AppConfig.defaultRole,
        DbStrings.isActive: true,
        DbStrings.metadata: {},
      });

      // Create user_apps record
      await _createUserAppRecord(userId);
    } catch (e) {
      throw _AuthException(ErrorStrings.createProfileFailed(e.toString()));
    }
  }

  // ========== Private Methods ==========

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId, {bool required = false}) async {
    final profile = await _client
        .from(DbStrings.usersTable)
        .select()
        .eq(DbStrings.id, userId)
        .maybeSingle();

    if (required && profile == null) {
      throw _AuthException(ErrorStrings.userProfileNotFound);
    }

    return profile;
  }

  /// Ensures user_apps record exists for the current app
  Future<void> _ensureUserAppRecord(String userId) async {
    try {
      final existing = await _client
          .from(DbStrings.userAppsTable)
          .select()
          .eq(DbStrings.userId, userId)
          .eq(DbStrings.appId, AppConfig.appId)
          .maybeSingle();

      if (existing == null) {
        AppLogger.database('Creating user_apps record for user $userId');
        await _createUserAppRecord(userId);
      }
    } catch (e) {
      AppLogger.error('Failed to ensure user_apps record: $e', name: 'UserProfileRepository');
      // Don't throw - this is a non-critical operation
    }
  }

  /// Creates user_apps record for the current app
  Future<void> _createUserAppRecord(String userId) async {
    await _client.from(DbStrings.userAppsTable).insert({
      DbStrings.userId: userId,
      DbStrings.appId: AppConfig.appId,
      DbStrings.role: AppConfig.defaultRole,
      DbStrings.isActive: true,
      DbStrings.metadata: {},
    });
    AppLogger.database('Created user_apps record for user $userId, app ${AppConfig.appId}');
  }

  SupabaseUserModel _mapToUserModel(User user, Map<String, dynamic> profile, String email) =>
      SupabaseUserModel(
        id: user.id,
        email: user.email ?? email,
        fullName: profile[DbStrings.fullName] ?? AuthConstStrings.defaultUserName,
        emailVerified: user.emailConfirmedAt != null,
        avatarUrl: profile[DbStrings.avatarUrl],
        phoneNumber: profile[DbStrings.phone],
        metadata: Map<String, dynamic>.from(profile[DbStrings.metadata] ?? {}),
        createdAt: DateTime.parse(profile[DbStrings.createdAt]),
        updatedAt: DateTime.parse(profile[DbStrings.updatedAt]),
      );
}

/// Custom auth exception
class _AuthException implements Exception {
  final String message;
  _AuthException(this.message);

  @override
  String toString() => message;
}
