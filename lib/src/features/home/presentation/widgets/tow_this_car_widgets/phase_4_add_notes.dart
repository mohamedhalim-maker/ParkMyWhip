import 'package:flutter/material.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/core/widgets/custom_text_field.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_progress_indicator.dart';

/// Phase 4 of the towing wizard - allows users to add optional notes/comments
/// about the towing entry (e.g., additional details about the violation)
class Phase4AddNotes extends StatelessWidget {
  const Phase4AddNotes({super.key, required this.state});

  final TowState state;

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<TowCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(24),
        Text(
          HomeStrings.newTowingEntry,
          style: AppTextStyles.urbanistFont14Grey700Regular1_28,
        ),
        verticalSpace(16),
        Text(
          HomeStrings.addNotes,
          style: AppTextStyles.urbanistFont24Grey800SemiBold1,
        ),
        verticalSpace(20),
        CustomTextField(
          title: HomeStrings.note,
          hintText: HomeStrings.addCommentHint,
          controller: cubit.notesController,
          maxLines: 5,
          maxLength: 160,
          onChanged: (_) => cubit.onNotesFieldChanged(),
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const Spacer(),
        PhaseProgressIndicator(currentPhase: 4),
        verticalSpace(16),
        CommonButton(
          text: HomeStrings.next,
          onPressed: () => cubit.validateAndProceedPhase4(),
          isEnabled: state.isNotesButtonEnabled,
        ),
        verticalSpace(24),
      ],
    );
  }
}
