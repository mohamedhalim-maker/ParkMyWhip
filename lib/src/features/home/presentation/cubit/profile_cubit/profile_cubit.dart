import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:park_my_whip/src/core/data/result.dart';
import 'package:park_my_whip/src/core/helpers/app_logger.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/routes/names.dart';
import 'package:park_my_whip/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/dashboard_cubit/dashboard_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/profile_cubit/profile_state.dart';

/// ProfileCubit handles profile page UI logic and state management.
/// It delegates all data operations to AuthRepository (Single Responsibility).
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const ProfileState());

  final AuthRepository _authRepository;

  void changeEmail() {
    AppLogger.cubit('Change email tapped', cubitName: 'ProfileCubit');
    // TODO: Implement change email functionality
  }

  void changePassword() {
    AppLogger.cubit('Change password tapped', cubitName: 'ProfileCubit');
    // TODO: Implement change password functionality
  }

  Future<void> logOut({required BuildContext context}) async {
    AppLogger.cubit('Logging out user', cubitName: 'ProfileCubit');
    emit(state.copyWith(isLoading: true));

    final result = await _authRepository.signOut();

    switch (result) {
      case Success():
        AppLogger.cubit('User logged out successfully', cubitName: 'ProfileCubit');
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesName.login,
            (route) => false,
          );
        }
      case Failure(message: final message):
        AppLogger.cubit('Logout failed: $message', cubitName: 'ProfileCubit');
        emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  void deleteAccount() {
    AppLogger.cubit('Delete account tapped', cubitName: 'ProfileCubit');
    // TODO: Implement delete account functionality
  }

  void navigateToPatrol() {
    getIt<DashboardCubit>().changePage(0);
  }

  /// Load user data from cache when profile page is initialized
  Future<void> loadUserProfile() async {
    final result = await _authRepository.getCachedUser();

    switch (result) {
      case Success(:final data):
        if (data != null) {
          emit(state.copyWith(
            username: data.fullName,
            email: data.email,
          ));
        }
      case Failure(:final message):
        AppLogger.cubit('Load user profile failed: $message', cubitName: 'ProfileCubit');
    }
  }
}
