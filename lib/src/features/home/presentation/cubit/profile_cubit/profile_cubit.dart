import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/networking/network_exceptions.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/core/services/supabase_user_service.dart';
import 'package:park_my_whip/src/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.authRemoteDataSource,
    required this.supabaseUserService,
  }) : super(const ProfileState());

  final AuthRemoteDataSource authRemoteDataSource;
  final SupabaseUserService supabaseUserService;

  void changeEmail() {
    log('Change email tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement change email functionality
  }

  void changePassword() {
    log('Change password tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement change password functionality
  }

  Future<void> logOut({required BuildContext context}) async {
    try {
      log('Logging out user', name: 'ProfileCubit', level: 800);
      
      emit(state.copyWith(isLoading: true));

      // Sign out from Supabase
      await authRemoteDataSource.signOut();
      
      // Clear cached user data
      await supabaseUserService.clearUser();
      
      log('User logged out successfully', name: 'ProfileCubit', level: 1000);
      
      emit(state.copyWith(isLoading: false));

      // Navigate to login page and clear navigation stack
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.login,
          (route) => false,
        );
      }
    } catch (e) {
      log('Logout error: $e', name: 'ProfileCubit', level: 900, error: e);
      final errorMessage = NetworkExceptions.getSupabaseExceptionMessage(e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void deleteAccount() {
    log('Delete account tapped', name: 'ProfileCubit', level: 800);
    // TODO: Implement delete account functionality
  }

  void navigateToPatrol() {
    getIt<DashboardCubit>().changePage(0);
  }

  /// Load user data from cache when profile page is initialized
  Future<void> loadUserProfile() async {
    try {
      final user = await supabaseUserService.getCachedUser();
      if (user != null) {
        emit(state.copyWith(
          username: user.fullName,
          email: user.email,
        ));
      }
    } catch (e) {
      log('Load user profile error: $e', name: 'ProfileCubit', level: 900, error: e);
    }
  }
}
