import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/responsive/app_breakpoints.dart';
import 'package:movaro_app/core/responsive/responsive_content.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.title,
    required this.description,
    required this.illustrationAsset,
    this.onRetry,
    this.onBack,
    this.retryLabel,
    this.backLabel,
    super.key,
  });

  final String title;
  final String description;
  final String illustrationAsset;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final String? retryLabel;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ResponsiveContent(
        maxWidth: AppBreakpoints.compactContentMaxWidth,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(illustrationAsset, height: 164),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryLabel ?? context.l10n.commonRetryAction),
              ),
            if (onBack != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(backLabel ?? context.l10n.commonBackAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
