import 'package:flutter/material.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    required this.label,
    this.compact = false,
    super.key,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = FrostedPanel(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 10 : 14,
      ),
      borderRadius: BorderRadius.circular(compact ? 18 : 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              textAlign: compact ? TextAlign.start : TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: compact ? content : Center(child: content),
    );
  }
}

class AnimatedStateSwitcher extends StatelessWidget {
  const AnimatedStateSwitcher({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;

    if (disableAnimations ?? false) {
      return child;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class SectionLoadingOverlay extends StatelessWidget {
  const SectionLoadingOverlay({
    required this.child,
    required this.label,
    this.isLoading = false,
    super.key,
  });

  final Widget child;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: isLoading,
      label: label,
      child: Stack(
        children: [
          child,
          if (isLoading)
            Positioned(
              top: 12,
              right: 12,
              child: IgnorePointer(
                child: LoadingStateWidget(label: label, compact: true),
              ),
            ),
        ],
      ),
    );
  }
}
