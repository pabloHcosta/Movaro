import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class QuestionProgressIndicator extends StatelessWidget {
  const QuestionProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.label,
    super.key,
  });

  final int currentStep;
  final int totalSteps;
  final String label;

  @override
  Widget build(BuildContext context) {
    final value = totalSteps == 0 ? 0.0 : currentStep / totalSteps;
    final textSoft = AppColors.textSoftFor(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: textSoft),
              ),
            ),
            Text(
              '$currentStep/$totalSteps',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: textSoft),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: surfaceMuted,
          ),
        ),
      ],
    );
  }
}
