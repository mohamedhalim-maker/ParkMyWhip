import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:park_my_whip/src/core/constants/colors.dart';
import 'package:park_my_whip/src/core/constants/strings.dart';
import 'package:park_my_whip/src/core/constants/text_style.dart';
import 'package:park_my_whip/src/core/constants/tow_my_whip_icons_icons.dart';
import 'package:park_my_whip/src/core/helpers/spacing.dart';
import 'package:park_my_whip/src/core/widgets/common_button.dart';
import 'package:park_my_whip/src/features/home/presentation/widgets/common/summary_card.dart';
import 'package:park_my_whip/src/features/home/data/models/active_reports_model.dart';

class ActiveReportDetailSheet extends StatelessWidget {
  const ActiveReportDetailSheet({super.key, required this.report});

  final ActiveReportModel report;

  String get _formattedSubmitTime =>
      DateFormat('dd/MM/yyyy, HH:mm:ss').format(report.submitTime);

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.94, end: 1),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        alignment: Alignment.bottomCenter,
        child: child,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height:747.h,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(TowMyWhipIcons.close, color: AppColor.grey700, size: 16),
                    ),
                  ),
                  SummaryCard(
                    id: report.id,
                    adminRole: report.adminRole,
                    carDetails: report.carDetails,
                    submitTime: report.submitTime,
                    plateNumber: report.plateNumber,
                    reportedBy: report.reportedBy,
                    additionalNotes: report.additionalNotes,
                    backgroundColor: AppColor.veryLightRed,
                  ),
                  verticalSpace(24),
                  Text(
                    HomeStrings.attachedImagesLabel,
                    style: AppTextStyles.urbanistFont10Grey700Regular1_3,
                  ),
                  verticalSpace(4),
                  _AttachedImagePreview(imagePath: report.attachedImage),
                  Spacer(),
                  CommonButton(
                    text: HomeStrings.markAsTowedAction,
                    leadingIcon: TowMyWhipIcons.towACar,
                    color: AppColor.redDark,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  verticalSpace(16),
                ],
              ),
            ),
          ),
        ),
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
        height: 220.h,
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

