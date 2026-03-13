import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class FeatureGuideStep {
  const FeatureGuideStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;
}

class FeatureGuideDialog extends StatefulWidget {
  const FeatureGuideDialog({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.stepsLabel,
    required this.steps,
    required this.hideNextTimeLabel,
    required this.dismissLabel,
    required this.primaryLabel,
    required this.onClose,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String stepsLabel;
  final List<FeatureGuideStep> steps;
  final String hideNextTimeLabel;
  final String dismissLabel;
  final String primaryLabel;
  final Future<void> Function(bool hideNextTime) onClose;

  @override
  State<FeatureGuideDialog> createState() => _FeatureGuideDialogState();
}

class _FeatureGuideDialogState extends State<FeatureGuideDialog> {
  bool _hideNextTime = true;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final viewHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FrostedPanel(
        padding: const EdgeInsets.all(24),
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  AppColors.heroStart,
                  AppColors.heroMiddle,
                  AppColors.heroEnd,
                ]
              : const [Color(0xFFF8FBFF), Color(0xFFEAF3FF), Color(0xFFD9EAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        backgroundColor: isDark
            ? const Color(0xE6101722)
            : const Color(0xFAFFFFFF),
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : AppColors.primary.withValues(alpha: 0.12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: viewHeight * 0.86,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.eyebrow,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.82,
                                              )
                                            : AppColors.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.textPrimaryFor(
                                          context,
                                        ),
                                        fontWeight: FontWeight.w800,
                                        height: 1.05,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _close,
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.textPrimaryFor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.body,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.78)
                              : AppColors.textSoftFor(context),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.stepsLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.82)
                              : AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final step in widget.steps) ...[
                        _FeatureGuideStepCard(
                          number: step.number,
                          title: step.title,
                          body: step.body,
                        ),
                        if (step != widget.steps.last)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AppColors.borderFor(context),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox.adaptive(
                    value: _hideNextTime,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) {
                      setState(() {
                        _hideNextTime = value ?? true;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.hideNextTimeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.84)
                            : AppColors.textSoftFor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: _close,
                    child: Text(widget.dismissLabel),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: _close,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(widget.primaryLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _close() async {
    await widget.onClose(_hideNextTime);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _FeatureGuideStepCard extends StatelessWidget {
  const _FeatureGuideStepCard({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isDark ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.76)
                        : AppColors.textSoftFor(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
