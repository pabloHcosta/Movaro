import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

/// Branded confirmation dialog used when the user attempts to exit a flow
/// (e.g. migration questionnaire, result reveal). Surfaces a clear visual
/// hierarchy: icon → title → body → primary "stay" CTA → destructive link.
class ExitFlowDialog extends StatelessWidget {
  const ExitFlowDialog({
    required this.title,
    required this.body,
    required this.stayLabel,
    required this.leaveLabel,
    super.key,
  });

  final String title;
  final String body;
  final String stayLabel;
  final String leaveLabel;

  /// Convenience: show the dialog and return `true` if the user chose to leave.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    required String stayLabel,
    required String leaveLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ExitFlowDialog(
        title: title,
        body: body,
        stayLabel: stayLabel,
        leaveLabel: leaveLabel,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: FrostedPanel(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        borderRadius: BorderRadius.circular(28),
        backgroundColor: isDark
            ? const Color(0xF0111828)
            : const Color(0xF8FFFFFF),
        borderColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ────────────────────────────────────────────────────
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: scheme.onErrorContainer,
                size: 26,
              ),
            ),
            const SizedBox(height: 18),

            // ── Title ────────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // ── Body ─────────────────────────────────────────────────────
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // ── Primary CTA: Stay ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, false),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                child: Text(stayLabel),
              ),
            ),
            const SizedBox(height: 10),

            // ── Destructive link: Leave ───────────────────────────────────
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: scheme.error,
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              child: Text(leaveLabel),
            ),
          ],
        ),
      ),
    );
  }
}
