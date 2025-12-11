import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';

class TowState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final int currentPhase;
  final TowingEntryModel? towingEntry;
  final String? plateNumberError;
  final bool isPlateNumberButtonEnabled;
  final String? selectedViolation;
  final bool isViolationButtonEnabled;
  final String? selectedImagePath;
  final bool isImageButtonEnabled;
  final bool isImageLoading;

  const TowState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentPhase = 1,
    this.towingEntry,
    this.plateNumberError,
    this.isPlateNumberButtonEnabled = false,
    this.selectedViolation,
    this.isViolationButtonEnabled = false,
    this.selectedImagePath,
    this.isImageButtonEnabled = false,
    this.isImageLoading = false,
  });

  TowState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? currentPhase,
    TowingEntryModel? towingEntry,
    String? plateNumberError,
    bool? isPlateNumberButtonEnabled,
    String? selectedViolation,
    bool? isViolationButtonEnabled,
    bool clearViolation = false,
    String? selectedImagePath,
    bool? isImageButtonEnabled,
    bool? isImageLoading,
    bool clearImage = false,
  }) {
    return TowState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      currentPhase: currentPhase ?? this.currentPhase,
      towingEntry: towingEntry ?? this.towingEntry,
      plateNumberError: plateNumberError,
      isPlateNumberButtonEnabled: isPlateNumberButtonEnabled ?? this.isPlateNumberButtonEnabled,
      selectedViolation: clearViolation ? null : (selectedViolation ?? this.selectedViolation),
      isViolationButtonEnabled: clearViolation ? false : (isViolationButtonEnabled ?? this.isViolationButtonEnabled),
      selectedImagePath: clearImage ? null : (selectedImagePath ?? this.selectedImagePath),
      isImageButtonEnabled: clearImage ? false : (isImageButtonEnabled ?? this.isImageButtonEnabled),
      isImageLoading: clearImage ? false : (isImageLoading ?? this.isImageLoading),
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, successMessage, currentPhase, towingEntry, plateNumberError, isPlateNumberButtonEnabled, selectedViolation, isViolationButtonEnabled, selectedImagePath, isImageButtonEnabled, isImageLoading];
}
