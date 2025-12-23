import 'package:park_my_whip/src/core/models/supabase_user_model.dart';
import 'package:park_my_whip/src/core/models/user_app_model.dart';

/// Result of checking email against the database
enum EmailCheckStatus {
  /// User does not exist - can proceed with sign up
  userNotFound,

  /// User exists and has access to this app - should login instead
  userExistsWithAppAccess,

  /// User exists but no access to this app - contact admin
  userExistsNoAppAccess,
}

/// Model for email check result from RPC function
class EmailCheckResult {
  final EmailCheckStatus status;
  final SupabaseUserModel? user;
  final UserAppModel? userApp;

  const EmailCheckResult({
    required this.status,
    this.user,
    this.userApp,
  });

  factory EmailCheckResult.fromRpcResponse(Map<String, dynamic>? response) {
    if (response == null) {
      return const EmailCheckResult(status: EmailCheckStatus.userNotFound);
    }

    final userData = response['user'] as Map<String, dynamic>?;
    final userAppData = response['user_app'] as Map<String, dynamic>?;

    // If no user data, user doesn't exist
    if (userData == null) {
      return const EmailCheckResult(status: EmailCheckStatus.userNotFound);
    }

    final user = SupabaseUserModel.fromJson(userData);

    // User exists, check if they have app access
    if (userAppData != null) {
      final userApp = UserAppModel.fromJson(userAppData);
      return EmailCheckResult(
        status: EmailCheckStatus.userExistsWithAppAccess,
        user: user,
        userApp: userApp,
      );
    }

    // User exists but no app access
    return EmailCheckResult(
      status: EmailCheckStatus.userExistsNoAppAccess,
      user: user,
    );
  }

  bool get canProceedWithSignUp => status == EmailCheckStatus.userNotFound;
}
