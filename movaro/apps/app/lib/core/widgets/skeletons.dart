import 'package:flutter/material.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
    this.margin,
    super.key,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
    if (disableAnimations ?? false) {
      _controller.stop();
      _controller.value = 0.4;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF263240)
        : const Color(0xFFE3EAF5);
    final highlightColor = isDark
        ? const Color(0xFF344456)
        : const Color(0xFFF5F8FD);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final color = Color.lerp(baseColor, highlightColor, _controller.value);

        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
          ),
        );
      },
    );
  }
}

class PageSkeleton extends StatelessWidget {
  const PageSkeleton({
    required this.label,
    required this.children,
    this.maxWidth = 1160,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final String label;
  final List<Widget> children;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: ExcludeSemantics(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: ListView(padding: padding, children: children),
            ),
          ),
        ),
      ),
    );
  }
}

class CardSkeleton extends StatelessWidget {
  const CardSkeleton({
    this.showLeading = true,
    this.showTrailing = false,
    this.lineCount = 3,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    super.key,
  });

  final bool showLeading;
  final bool showTrailing;
  final int lineCount;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: padding,
      borderRadius: borderRadius,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLeading) ...[
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBox(width: 180, height: 18),
                const SizedBox(height: 10),
                for (var index = 0; index < lineCount; index++) ...[
                  SkeletonBox(
                    width: index == lineCount - 1 ? 150 : double.infinity,
                    height: 12,
                  ),
                  if (index < lineCount - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 14),
            const SkeletonBox(
              width: 28,
              height: 28,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    this.itemCount = 4,
    this.showLeading = true,
    this.showTrailing = false,
    this.spacing = 12,
    super.key,
  });

  final int itemCount;
  final bool showLeading;
  final bool showTrailing;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < itemCount; index++) ...[
          CardSkeleton(showLeading: showLeading, showTrailing: showTrailing),
          if (index < itemCount - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

class TableSkeleton extends StatelessWidget {
  const TableSkeleton({this.columnCount = 4, this.rowCount = 5, super.key});

  final int columnCount;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        children: [
          Row(
            children: [
              for (var index = 0; index < columnCount; index++) ...[
                const Expanded(child: SkeletonBox(height: 14)),
                if (index < columnCount - 1) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 18),
          for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) ...[
            Row(
              children: [
                for (
                  var columnIndex = 0;
                  columnIndex < columnCount;
                  columnIndex++
                ) ...[
                  Expanded(
                    child: SkeletonBox(
                      height: 12,
                      width: columnIndex == columnCount - 1
                          ? 80
                          : double.infinity,
                    ),
                  ),
                  if (columnIndex < columnCount - 1) const SizedBox(width: 12),
                ],
              ],
            ),
            if (rowIndex < rowCount - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class FormSkeleton extends StatelessWidget {
  const FormSkeleton({
    this.showSteps = true,
    this.fieldCount = 4,
    this.compact = false,
    super.key,
  });

  final bool showSteps;
  final int fieldCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 120, height: 14),
              const SizedBox(height: 12),
              const SkeletonBox(width: 280, height: 34),
              const SizedBox(height: 12),
              const SkeletonBox(height: 14),
              const SizedBox(height: 8),
              const SkeletonBox(width: 220, height: 14),
              if (showSteps) ...[
                const SizedBox(height: 20),
                const SkeletonBox(width: 180, height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!compact)
          FrostedPanel(
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14),
                SizedBox(height: 12),
                SkeletonBox(
                  height: 54,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ],
            ),
          ),
        if (!compact) const SizedBox(height: 16),
        for (var index = 0; index < fieldCount; index++) ...[
          const CardSkeleton(showLeading: false, showTrailing: true),
          if (index < fieldCount - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        FrostedPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: BorderRadius.circular(28),
          child: Row(
            children: [
              const Expanded(child: SkeletonBox(height: 46)),
              const SizedBox(width: 12),
              const Expanded(flex: 2, child: SkeletonBox(height: 46)),
            ],
          ),
        ),
      ],
    );
  }
}

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SkeletonBox(width: 160, height: 38),
            SkeletonBox(width: 48, height: 38),
          ],
        ),
        const SizedBox(height: 16),
        FrostedPanel(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 220, height: 38),
              const SizedBox(height: 12),
              const SkeletonBox(width: 150, height: 16),
              const SizedBox(height: 10),
              const SkeletonBox(height: 14),
              const SizedBox(height: 8),
              const SkeletonBox(width: 320, height: 14),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 920 ? 4 : 2;
                  final gap = 10.0;
                  final width =
                      (constraints.maxWidth - (gap * (crossAxisCount - 1))) /
                      crossAxisCount;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var index = 0; index < 4; index++)
                        SizedBox(
                          width: width,
                          child: const CardSkeleton(showLeading: false),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 220, height: 16),
              SizedBox(height: 12),
              SkeletonBox(height: 14),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final width = wide
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: width,
                  child: const FrostedPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 160, height: 16),
                        SizedBox(height: 18),
                        SkeletonBox(
                          height: 220,
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: const FrostedPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 180, height: 16),
                        SizedBox(height: 18),
                        SkeletonBox(height: 18),
                        SizedBox(height: 10),
                        SkeletonBox(height: 14),
                        SizedBox(height: 10),
                        SkeletonBox(width: 190, height: 14),
                      ],
                    ),
                  ),
                ),
                for (var index = 0; index < 2; index++)
                  SizedBox(
                    width: width,
                    child: const CardSkeleton(showLeading: false),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const TableSkeleton(columnCount: 3, rowCount: 4),
        const SizedBox(height: 16),
        const FrostedPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 180, height: 42),
              SizedBox(height: 12),
              SkeletonBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
