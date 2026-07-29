import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpStep {
  const HelpStep({required this.title, required this.body, this.icon});

  final String title;
  final String body;
  final IconData? icon;
}

class HelpBottomSheet extends StatefulWidget {
  const HelpBottomSheet({
    required this.contextLabel,
    required this.contextIcon,
    required this.title,
    required this.description,
    required this.steps,
    required this.preferenceKey,
    required this.hideAgainLabel,
    required this.confirmLabel,
    this.showHideAgainControl = true,
    super.key,
  });

  final String contextLabel;
  final IconData contextIcon;
  final String title;
  final String description;
  final List<HelpStep> steps;
  final String preferenceKey;
  final String hideAgainLabel;
  final String confirmLabel;
  final bool showHideAgainControl;

  @override
  State<HelpBottomSheet> createState() => _HelpBottomSheetState();
}

class _HelpBottomSheetState extends State<HelpBottomSheet> {
  bool _doNotShowAgain = false;
  bool _isSaving = false;
  bool _hasPersistedPreference = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppColors.isDark(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.86;
    final sheetColor = AppColors.surfaceFor(context);
    final dividerColor = AppColors.borderFor(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          unawaited(_persistPreference());
        }
      },
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 680, maxHeight: maxHeight),
              child: Material(
                color: sheetColor,
                elevation: isDark ? 0 : 18,
                shadowColor: Colors.black.withValues(alpha: 0.16),
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  side: BorderSide(color: dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DragHandle(isDark: isDark),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: isDark ? 0.18 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Icon(
                              widget.contextIcon,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.contextLabel.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Semantics(
                                  header: true,
                                  child: Text(
                                    widget.title,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: AppColors.textPrimaryFor(context),
                                      fontWeight: FontWeight.w800,
                                      height: 1.14,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                            onPressed: _isSaving ? null : _dismiss,
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.textSoftFor(context),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: dividerColor),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSoftFor(context),
                                height: 1.48,
                              ),
                            ),
                            const SizedBox(height: 18),
                            for (
                              var index = 0;
                              index < widget.steps.length;
                              index++
                            ) ...[
                              _HelpStepCard(
                                index: index,
                                step: widget.steps[index],
                              ),
                              if (index < widget.steps.length - 1)
                                const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: dividerColor),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 10, 16, 14 + safeBottom),
                      child: Column(
                        children: [
                          if (widget.showHideAgainControl) ...[
                            CheckboxListTile(
                              value: _doNotShowAgain,
                              onChanged: _isSaving
                                  ? null
                                  : (value) => setState(
                                      () => _doNotShowAgain = value ?? false,
                                    ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              activeColor: AppColors.primary,
                              title: Text(
                                widget.hideAgainLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _confirm,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 17,
                                      height: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded, size: 19),
                              label: Text(widget.confirmLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    await _persistPreference();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _dismiss() async {
    await _persistPreference();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _persistPreference() async {
    if (_isSaving || _hasPersistedPreference) {
      return;
    }
    if (!widget.showHideAgainControl) {
      _hasPersistedPreference = true;
      return;
    }
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('help_${widget.preferenceKey}', _doNotShowAgain);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasPersistedPreference = true;
      });
    } else {
      _hasPersistedPreference = true;
    }
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        width: 38,
        height: 4,
        margin: const EdgeInsets.only(top: 10, bottom: 4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.black.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _HelpStepCard extends StatelessWidget {
  const _HelpStepCard({required this.index, required this.step});

  final int index;
  final HelpStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppColors.isDark(context);
    final icon = step.icon ?? _fallbackIcon(index);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintedSurfaceFor(
          context,
          tint: AppColors.primary,
          lightColor: const Color(0xFFF5F8FD),
          darkAlpha: 0.09,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoftFor(context),
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _fallbackIcon(int index) => switch (index) {
    0 => Icons.looks_one_outlined,
    1 => Icons.looks_two_outlined,
    2 => Icons.looks_3_outlined,
    _ => Icons.check_circle_outline_rounded,
  };
}
