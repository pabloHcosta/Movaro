import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
    this.backgroundColor = const Color(0xCCFFFFFF),
    this.borderColor = const Color(0x1A1D1D1F),
    this.gradient,
    this.blurSigma = 18,
    this.boxShadow = const [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 36,
        offset: Offset(0, 18),
      ),
    ],
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final Gradient? gradient;
  final double blurSigma;
  final List<BoxShadow> boxShadow;

  @override
  Widget build(BuildContext context) {
    final resolvedBackgroundColor = backgroundColor == const Color(0xCCFFFFFF)
        ? AppColors.frostedBackgroundFor(context)
        : backgroundColor;
    final resolvedBorderColor = borderColor == const Color(0x1A1D1D1F)
        ? AppColors.frostedBorderFor(context)
        : borderColor;
    final resolvedBoxShadow =
        boxShadow.length == 1 &&
            boxShadow.first.color == const Color(0x12000000) &&
            boxShadow.first.blurRadius == 36 &&
            boxShadow.first.offset == const Offset(0, 18)
        ? AppColors.frostedShadowFor(context)
        : boxShadow;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: resolvedBackgroundColor,
            gradient: gradient,
            borderRadius: borderRadius,
            border: Border.all(color: resolvedBorderColor),
            boxShadow: resolvedBoxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
