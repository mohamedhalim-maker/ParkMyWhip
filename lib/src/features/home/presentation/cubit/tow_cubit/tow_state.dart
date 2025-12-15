import 'package:equatable/equatable.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';

class TowState extends Equatable {
  static const Object _unset = Object();

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
  final String? notes;
  final bool isNotesButtonEnabled;
  final bool isConfirmed;

  const TowState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.currentPhase = 1,
    this.isConfirmed = false,
    this.towingEntry,
    this.plateNumberError,
    this.isPlateNumberButtonEnabled = false,
    this.selectedViolation,
    this.isViolationButtonEnabled = false,
    this.selectedImagePath,
    this.isImageButtonEnabled = false,
    this.isImageLoading = false,
    this.notes,
    this.isNotesButtonEnabled = false,
  });

  TowState copyWith({
    bool? isLoading,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    int? currentPhase,
    Object? towingEntry = _unset,
    Object? plateNumberError = _unset,
    bool? isPlateNumberButtonEnabled,
    Object? selectedViolation = _unset,
    bool? isViolationButtonEnabled,
    bool clearViolation = false,
    Object? selectedImagePath = _unset,
    bool? isImageButtonEnabled,
    bool? isImageLoading,
    bool clearImage = false,
    Object? notes = _unset,
    bool? isNotesButtonEnabled,
    bool clearNotes = false,
    bool? isConfirmed,
  }) {
    return TowState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      successMessage: successMessage == _unset ? this.successMessage : successMessage as String?,
      currentPhase: currentPhase ?? this.currentPhase,
      towingEntry: towingEntry == _unset ? this.towingEntry : towingEntry as TowingEntryModel?,
      plateNumberError: plateNumberError == _unset ? this.plateNumberError : plateNumberError as String?,
      isPlateNumberButtonEnabled: isPlateNumberButtonEnabled ?? this.isPlateNumberButtonEnabled,
      selectedViolation: clearViolation
          ? null
          : (selectedViolation == _unset ? this.selectedViolation : selectedViolation as String?),
      isViolationButtonEnabled:
          clearViolation ? false : (isViolationButtonEnabled ?? this.isViolationButtonEnabled),
      selectedImagePath: clearImage
          ? null
          : (selectedImagePath == _unset ? this.selectedImagePath : selectedImagePath as String?),
      isImageButtonEnabled: clearImage ? false : (isImageButtonEnabled ?? this.isImageButtonEnabled),
      isImageLoading: clearImage ? false : (isImageLoading ?? this.isImageLoading),
      notes: clearNotes ? null : (notes == _unset ? this.notes : notes as String?),
      isNotesButtonEnabled: clearNotes ? false : (isNotesButtonEnabled ?? this.isNotesButtonEnabled),
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        successMessage,
        currentPhase,
        towingEntry,
        plateNumberError,
        isPlateNumberButtonEnabled,
        selectedViolation,
        isViolationButtonEnabled,
        selectedImagePath,
        isImageButtonEnabled,
        isImageLoading,
        notes,
        isNotesButtonEnabled,
        isConfirmed,
      ];
}
