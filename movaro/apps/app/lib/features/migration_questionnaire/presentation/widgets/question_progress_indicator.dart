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
    final textSoft = AppColors.textSoftFor(context);

    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: textSoft),
    );
  }
}
