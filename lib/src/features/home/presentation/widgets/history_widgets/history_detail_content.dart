import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/features/home/data/models/towing_entry_model.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/summary_card.dart';

/// History detail content showing towing entry details
class HistoryDetailContent extends StatelessWidget {
  const HistoryDetailContent({super.key, required this.entry});

  final TowingEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(24),
          Text(
            HomeStrings.towingDetails,
            style: AppTextStyles.urbanistFont28Grey800SemiBold1,
          ),
          verticalSpace(24),
          SummaryCard(
            id: entry.plateNumber,
            adminRole: entry.reportedBy ?? 'N/A',
            carDetails: '${entry.reason ?? 'No violation type'}${entry.location != null ? ' - ${entry.location}' : ''}',
            submitTime: entry.towDate ?? DateTime.now(),
            plateNumber: entry.plateNumber,
            reportedBy: entry.towCompany ?? 'N/A',
            additionalNotes: entry.notes ?? 'No additional notes',
            backgroundColor: AppColor.veryLightRed,
            reportedByLabel: HomeStrings.towedByLabel,
          ),
          verticalSpace(24),
          Text(
            HomeStrings.attachedImagesLabel,
            style: AppTextStyles.urbanistFont10Grey700Regular1_3,
          ),
          verticalSpace(8),
          _AttachedImagePreview(imagePath: entry.attachedImage ?? ''),
          verticalSpace(24),
        ],
      ),
    );
  }
}

class _AttachedImagePreview extends StatelessWidget {
  const _AttachedImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final imageWidget = imagePath.startsWith('http')
        ? Image.network(
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
                ),
              );
            },
            errorBuilder: (context, _, __) => const _ImageFallback(),
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) => const _ImageFallback(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: SizedBox(
        height: 200.h,
        width: double.infinity,
        child: imageWidget,
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColor.veryLightRed,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined, color: AppColor.grey700),
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
