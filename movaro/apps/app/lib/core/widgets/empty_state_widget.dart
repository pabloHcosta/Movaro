import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/core/responsive/app_breakpoints.dart';
import 'package:movaro_app/core/responsive/responsive_content.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.title,
    required this.description,
    this.illustrationAsset = 'assets/illustrations/empty.svg',
    this.action,
    super.key,
  });

  final String title;
  final String description;
  final String illustrationAsset;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ResponsiveContent(
        maxWidth: AppBreakpoints.compactContentMaxWidth,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(illustrationAsset, height: 160),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
