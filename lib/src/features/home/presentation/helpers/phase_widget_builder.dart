import 'package:flutter/material.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_1_enter_plate_number.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_2_select_violation.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_3_attach_image.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_4_add_notes.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_5_preview.dart';

/// Helper class that builds the appropriate phase widget based on the current state.
/// This keeps widget building logic separate from both UI pages and business logic.
class PhaseWidgetBuilder {
  static Widget build(TowState state) {
    switch (state.currentPhase) {
      case 1:
        return Phase1EnterPlateNumber(state: state);
      case 2:
        return Phase2SelectViolation(state: state);
      case 3:
        return Phase3AttachImage(state: state);
      case 4:
        return Phase4AddNotes(state: state);
      case 5:
        return Phase5Preview(state: state);
      default:
        return const SizedBox.shrink();
    }
  }
}
