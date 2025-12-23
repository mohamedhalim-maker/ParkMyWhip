import 'dart:convert';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/helpers/shared_pref_helper.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';

/// Local data source for caching user authentication data
/// Handles SharedPreferences operations for user persistence
class AuthLocalDataSource {
  final SharedPrefHelper _sharedPrefHelper;

  AuthLocalDataSource({required SharedPrefHelper sharedPrefHelper})
      : _sharedPrefHelper = sharedPrefHelper;

  /// Get cached user from SharedPreferences
  Future<SupabaseUserModel?> getCachedUser() async {
    try {
      final stored = await _sharedPrefHelper.getString(
        key: SharedPrefStrings.supabaseUserProfile,
      );
      
      if (stored == null || stored.isEmpty) {
        AppLogger.storage('No cached user found');
        return null;
      }
      
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final user = SupabaseUserModel.fromJson(decoded);
      
      AppLogger.storage('Cached user loaded: ${user.id}');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get cached user', 
          name: 'Storage', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Cache user to SharedPreferences
  Future<void> cacheUser(SupabaseUserModel user) async {
    try {
      await _sharedPrefHelper.setData(
        key: SharedPrefStrings.supabaseUserProfile,
        value: jsonEncode(user.toJson()),
      );
      AppLogger.storage('User cached successfully: ${user.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cache user', 
          name: 'Storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Clear cached user from SharedPreferences
  Future<void> clearUser() async {
    try {
      await _sharedPrefHelper.removeData(SharedPrefStrings.supabaseUserProfile);
      AppLogger.storage('Cached user cleared');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear cached user', 
          name: 'Storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
