import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String username;
  final String email;
  final bool isLoading;
  final String? errorMessage;
  
  const ProfileState({
    this.username = 'Loading...',
    this.email = 'Loading...',
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? username,
    String? email,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      username: username ?? this.username,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [username, email, isLoading, errorMessage];
}
