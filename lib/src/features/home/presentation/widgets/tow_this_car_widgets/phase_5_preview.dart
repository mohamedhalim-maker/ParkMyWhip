import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/config/injection.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/summary_card.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_cubit.dart';
import 'package:park_my_whip/src/features/home/presentation/cubit/tow_cubit/tow_state.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/tow_this_car_widgets/phase_progress_indicator.dart';

/// Phase 5: Preview - Shows a summary of all entered information before final confirmation
class Phase5Preview extends StatelessWidget {
  const Phase5Preview({super.key, required this.state});

  final TowState state;

  @override
  Widget build(BuildContext context) {
    final towingEntry = state.towingEntry;
    if (towingEntry == null) {
      return const Center(child: Text('No data available'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(24),
                Text(
                  HomeStrings.newTowingEntry,
                  style: AppTextStyles.urbanistFont12Grey800Regular1_64,
                ),
                verticalSpace(8),
                Text(
                  HomeStrings.towingSummary,
                  style: AppTextStyles.urbanistFont28Grey800SemiBold1,
                ),
                verticalSpace(24),
                SummaryCard(
                  id: DateTime.now().millisecondsSinceEpoch
                      .toString()
                      .substring(7),
                  adminRole: HomeStrings.residentAdmin,
                  carDetails:
                      towingEntry.reason ?? HomeStrings.unauthorizedParking,
                  submitTime: DateTime.now(),
                  plateNumber: towingEntry.plateNumber,
                  reportedBy: 'Me',
                  additionalNotes: towingEntry.notes ?? '',
                  backgroundColor: AppColor.veryLightGrey,
                ),
                verticalSpace(24),
                Text(
                  HomeStrings.attachedImages,
                  style: AppTextStyles.urbanistFont10Grey700Regular1_3,
                ),
                verticalSpace(8),
                if (towingEntry.attachedImage != null)
                  _AttachedImagePreview(imagePath: towingEntry.attachedImage!),
                verticalSpace(24),
              ],
            ),
          ),
        ),
        PhaseProgressIndicator(currentPhase: state.currentPhase),
        verticalSpace(16),
        BlocBuilder<TowCubit, TowState>(
          builder: (context, state) => CommonButton(
            text: HomeStrings.confirm,
            onPressed: () => getIt<TowCubit>().confirmTowing(),
            isEnabled: !state.isLoading,
          ),
        ),
        verticalSpace(24),
      ],
    );
  }
}

/// Displays the attached image preview with proper loading and error states
class _AttachedImagePreview extends StatelessWidget {
  const _AttachedImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (kIsWeb) {
      imageWidget = Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              color: AppColor.redDark,
            ),
          );
        },
        errorBuilder: (context, _, __) => const _ImageFallback(),
      );
    } else {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, _, __) => const _ImageFallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: SizedBox(
        height: 280.h,
        width: double.infinity,
        child: imageWidget,
      ),
    );
  }
}

/// Fallback widget when image fails to load
class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.veryLightGrey,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppColor.grey700,
              size: 48,
            ),
            verticalSpace(8),
            Text(
              'Image unavailable',
              style: AppTextStyles.urbanistFont12Grey700SemiBold1_2,
            ),
          ],
        ),
      ),
    );
  }
}
