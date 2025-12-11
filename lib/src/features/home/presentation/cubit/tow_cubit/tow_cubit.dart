import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:park_my_whip/src/features/auth/domain/validators.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/image_source_bottom_sheet.dart';

class TowCubit extends Cubit<TowState> {
  final Validators _validators = Validators();
  final TextEditingController plateNumberController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  TowCubit() : super(const TowState());

  void resetState() {
    plateNumberController.clear();
    emit(const TowState());
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  void onPlateNumberFieldChanged() {
    final text = plateNumberController.text;
    final shouldEnable = text.trim().isNotEmpty;

    String? updatedError = state.plateNumberError;
    if (state.plateNumberError != null) {
      updatedError = _validators.plateNumberValidator(text);
    }

    final shouldEmit = state.isPlateNumberButtonEnabled != shouldEnable || updatedError != state.plateNumberError;
    if (shouldEmit) {
      emit(state.copyWith(isPlateNumberButtonEnabled: shouldEnable, plateNumberError: updatedError));
    }
  }

  void validateAndProceedPhase1() {
    final error = _validators.plateNumberValidator(plateNumberController.text);
    if (error == null) {
      final entry = TowingEntryModel(plateNumber: plateNumberController.text.trim().toUpperCase());
      emit(state.copyWith(towingEntry: entry, plateNumberError: null));
      nextPhase();
    } else {
      emit(state.copyWith(plateNumberError: error));
    }
  }

  void selectViolation(String violation) {
    final updatedEntry = state.towingEntry?.copyWith(reason: violation);
    emit(state.copyWith(
      selectedViolation: violation,
      isViolationButtonEnabled: true,
      towingEntry: updatedEntry,
    ));
  }

  void validateAndProceedPhase2() {
    if (state.selectedViolation != null && state.selectedViolation!.isNotEmpty) {
      nextPhase();
    }
  }

  /// Shows bottom sheet to select image source (camera or gallery)
  void showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        onCameraTap: () => _pickImageFromCamera(),
        onGalleryTap: () => _pickImageFromGallery(),
      ),
    );
  }

  /// Picks image from camera
  Future<void> _pickImageFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  /// Picks image from gallery
  Future<void> _pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  /// Internal method to handle image picking from the specified source
  /// Shows loading state while image is being processed
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Show loading state
      emit(state.copyWith(isImageLoading: true));

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Simulate processing delay to show loading state
        await Future.delayed(const Duration(milliseconds: 500));

        final imagePath = kIsWeb ? pickedFile.path : pickedFile.path;
        final updatedEntry = state.towingEntry?.copyWith(attachedImage: imagePath);
        
        emit(state.copyWith(
          selectedImagePath: imagePath,
          isImageButtonEnabled: true,
          isImageLoading: false,
          towingEntry: updatedEntry,
        ));
      } else {
        // User cancelled the picker
        emit(state.copyWith(isImageLoading: false));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      emit(state.copyWith(isImageLoading: false));
    }
  }

  void validateAndProceedPhase3() {
    if (state.selectedImagePath != null && state.selectedImagePath!.isNotEmpty) {
      nextPhase();
    }
  }

  void goToPhase(int phase) {
    if (phase >= 1 && phase <= 5) {
      emit(state.copyWith(currentPhase: phase));
    }
  }

  void nextPhase() {
    if (state.currentPhase < 5) {
      emit(state.copyWith(currentPhase: state.currentPhase + 1));
    }
  }

  void previousPhase() {
    if (state.currentPhase > 1) {
      final newPhase = state.currentPhase - 1;
      // When going back from phase 2 to phase 1, clear violation selection
      if (state.currentPhase == 2 && newPhase == 1) {
        emit(state.copyWith(currentPhase: newPhase, clearViolation: true));
      }
      // When going back from phase 3 to phase 2, clear image selection
      else if (state.currentPhase == 3 && newPhase == 2) {
        emit(state.copyWith(currentPhase: newPhase, clearImage: true));
      } else {
        emit(state.copyWith(currentPhase: newPhase));
      }
    }
  }

  Future<void> submitTowingReport() async {
    emit(state.copyWith(isLoading: true, errorMessage: null, successMessage: null));

    try {
      // TODO: Replace with actual API call to tow service
      await Future.delayed(const Duration(seconds: 2));

      final plateNumber = state.towingEntry?.plateNumber ?? 'Unknown';
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Car with plate $plateNumber has been marked for towing',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process tow request: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    plateNumberController.dispose();
    return super.close();
  }
}
