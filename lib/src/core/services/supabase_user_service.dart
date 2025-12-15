import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/helpers/shared_pref_helper.dart';
import 'package:park_my_whip/src/core/models/supabase_user_model.dart';

class SupabaseUserService {
  SupabaseUserService({required SharedPrefHelper sharedPrefHelper})
      : _sharedPrefHelper = sharedPrefHelper;

  final SharedPrefHelper _sharedPrefHelper;

  Future<SupabaseUserModel?> getCachedUser() async {
    try {
      final String? stored =
          await _sharedPrefHelper.getString(key: SharedPrefStrings.supabaseUserProfile);
      if (stored == null || stored.isEmpty) {
        return _seedSampleUser();
      }
      final Map<String, dynamic> decoded =
          jsonDecode(stored) as Map<String, dynamic>;
      return SupabaseUserModel.fromJson(decoded);
    } catch (error, stackTrace) {
      debugPrint('SupabaseUserService.getCachedUser error: $error');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  Future<void> cacheUser(SupabaseUserModel user) async {
    try {
      await _sharedPrefHelper.setData(
        key: SharedPrefStrings.supabaseUserProfile,
        value: jsonEncode(user.toJson()),
      );
    } catch (error, stackTrace) {
      debugPrint('SupabaseUserService.cacheUser error: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> clearUser() async {
    try {
      await _sharedPrefHelper.removeData(SharedPrefStrings.supabaseUserProfile);
    } catch (error, stackTrace) {
      debugPrint('SupabaseUserService.clearUser error: $error');
      debugPrint(stackTrace.toString());
    }
  }

  Future<SupabaseUserModel> _seedSampleUser() async {
    final SupabaseUserModel sampleUser = SupabaseUserModel(
      id: 'sample-user-id',
      email: 'qa.patrol@towmywhip.com',
      name: 'QA Patrol Lead',
      emailVerified: true,
      avatarUrl:
          'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=300&q=80',
      phoneNumber: '+1 415-555-0105',
      metadata: const <String, dynamic>{
        'role': 'Field Marshal',
        'territory': 'Downtown District',
        'lastSync': 'Auto-seeded for local testing',
      },
      createdAt: DateTime.utc(2024, 11, 12, 9),
      updatedAt: DateTime.now().toUtc(),
    );
    await _sharedPrefHelper.setData(
      key: SharedPrefStrings.supabaseUserProfile,
      value: jsonEncode(sampleUser.toJson()),
    );
    return sampleUser;
  }
}
