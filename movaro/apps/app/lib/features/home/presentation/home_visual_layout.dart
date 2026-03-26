import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

class HomeVisualLayout extends StatelessWidget {
  const HomeVisualLayout({required this.onActionTap, super.key});

  final void Function(int index) onActionTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visualHeight = size.height * 0.28;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Column(
        children: [
          SizedBox(
            height: visualHeight + padding.top,
            width: double.infinity,
            child: CustomPaint(
              painter: JourneyIllustrationPainter(
                primaryColor: scheme.primary,
                surfaceColor: scheme.surfaceContainerHighest,
                cardColor: isDark ? const Color(0xFF131929) : Colors.white,
                textMutedColor: scheme.onSurface.withValues(
                  alpha: isDark ? 0.22 : 0.32,
                ),
                labels: _journeyLabels(context),
                isDark: isDark,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context, scheme),
                  const SizedBox(height: 9),
                  _buildSubtitle(context, scheme),
                  const SizedBox(height: 8),
                  _buildSupportLine(context, scheme),
                  const SizedBox(height: 18),
                  _buildPrimaryButton(context, scheme, isDark),
                  const SizedBox(height: 8),
                  Expanded(child: _buildSecondaryLinks(context, scheme)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ColorScheme scheme) {
    final l10n = context.l10n;
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.2,
      color: scheme.onSurface,
    );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.homeVisualTitlePrefix),
          TextSpan(
            text: l10n.homeVisualTitleHighlight,
            style: TextStyle(color: scheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, ColorScheme scheme) {
    final l10n = context.l10n;
    return Text(
      l10n.homeVisualSubtitle,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.70),
        height: 1.5,
      ),
    );
  }

  Widget _buildSupportLine(BuildContext context, ColorScheme scheme) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 13,
            color: scheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            l10n.homeVisualSupportLine,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.42),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, const Color(0xFF0066FF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => onActionTap(3),
          icon: const Icon(Icons.map_outlined, size: 18),
          label: Text(l10n.homeVisualPrimaryAction),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryLinks(BuildContext context, ColorScheme scheme) {
    final l10n = context.l10n;
    final items = [
      (Icons.attach_money_rounded, l10n.homeVisualCostsAction, 0),
      (Icons.description_outlined, l10n.homeVisualDocumentsAction, 1),
      (Icons.explore_outlined, l10n.homeVisualStartAction, 2),
    ];

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          InkWell(
            onTap: () => onActionTap(items[index].$3),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Icon(
                    items[index].$1,
                    size: 16,
                    color: scheme.onSurface.withValues(alpha: 0.40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[index].$2,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: scheme.onSurface.withValues(alpha: 0.22),
                  ),
                ],
              ),
            ),
          ),
          if (index != items.length - 1)
            Divider(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
        ],
      ],
    );
  }

  JourneyIllustrationLabels _journeyLabels(BuildContext context) {
    final l10n = context.l10n;
    return JourneyIllustrationLabels(
      origin: l10n.homeVisualOriginLabel,
      destination: l10n.homeVisualDestinationLabel,
      documents: l10n.homeVisualWaypointDocuments,
      costs: l10n.homeVisualWaypointCosts,
      route: l10n.homeVisualWaypointRoute,
    );
  }
}

class JourneyIllustrationPainter extends CustomPainter {
  const JourneyIllustrationPainter({
    required this.primaryColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.textMutedColor,
    required this.labels,
    required this.isDark,
  });

  final Color primaryColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color textMutedColor;
  final JourneyIllustrationLabels labels;
  final bool isDark;

  Offset _bezierPoint(double t, Offset p0, Offset p1, Offset p2, Offset p3) {
    final u = 1.0 - t;
    final x =
        u * u * u * p0.dx +
        3 * u * u * t * p1.dx +
        3 * u * t * t * p2.dx +
        t * t * t * p3.dx;
    final y =
        u * u * u * p0.dy +
        3 * u * u * t * p1.dy +
        3 * u * t * t * p2.dy +
        t * t * t * p3.dy;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = surfaceColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final dotPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.06 : 0.04);
    const spacing = 24.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.85),
      radius: size.width * 0.65,
    );
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
          Colors.transparent,
        ],
      ).createShader(glowRect);
    canvas.drawCircle(glowRect.center, glowRect.width / 2, glowPaint);

    final p0 = Offset(size.width * 0.17, size.height * 0.78);
    final p1 = Offset(size.width * 0.35, size.height * 0.55);
    final p2 = Offset(size.width * 0.65, size.height * 0.45);
    final p3 = Offset(size.width * 0.77, size.height * 0.35);

    final routePath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final routeGlowPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.08 : 0.06)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routeGlowPaint);

    final routeDashPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.20 : 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawDashedPath(
      canvas,
      routePath,
      routeDashPaint,
      dashLength: 4,
      gapLength: 5,
    );

    _drawPlanCard(canvas, size);
    _drawGlobe(canvas, size);
    _drawHouse(canvas, size);

    _drawOriginNode(canvas, p0);
    _drawDestinationNode(canvas, p3);

    _drawWaypoint(
      canvas,
      _bezierPoint(0.30, p0, p1, p2, p3),
      labels.documents,
      _WaypointType.document,
    );
    _drawWaypoint(
      canvas,
      _bezierPoint(0.58, p0, p1, p2, p3),
      labels.costs,
      _WaypointType.cost,
    );
    _drawWaypoint(
      canvas,
      _bezierPoint(0.82, p0, p1, p2, p3),
      labels.route,
      _WaypointType.route,
    );
  }

  void _drawOriginNode(Canvas canvas, Offset center) {
    final ringStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: isDark ? 0.12 : 0.08)
      ..strokeWidth = 1;
    final midStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: isDark ? 0.18 : 0.12)
      ..strokeWidth = 1;
    final outerFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: isDark ? 0.05 : 0.04);
    final midFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: isDark ? 0.08 : 0.05);
    final coreFill = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF0F2A55) : const Color(0xFFD6E8FF);
    final coreStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor
      ..strokeWidth = 1.5;
    final pointFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;

    canvas.drawCircle(center, 20, outerFill);
    canvas.drawCircle(center, 20, ringStroke);
    canvas.drawCircle(center, 12, midFill);
    canvas.drawCircle(center, 12, midStroke);
    canvas.drawCircle(center, 7, coreFill);
    canvas.drawCircle(center, 7, coreStroke);
    canvas.drawCircle(center, 2.5, pointFill);

    final arrowPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      center + const Offset(0, 3),
      center + const Offset(0, -3),
      arrowPaint,
    );
    canvas.drawLine(
      center + const Offset(0, -3),
      center + const Offset(-2, -1),
      arrowPaint,
    );
    canvas.drawLine(
      center + const Offset(0, -3),
      center + const Offset(2, -1),
      arrowPaint,
    );

    _paintLabel(
      canvas,
      labels.origin,
      center + const Offset(0, 34),
      color: textMutedColor,
      size: 7.5,
      letterSpacing: 0.1,
      align: TextAlign.center,
    );
  }

  void _drawDestinationNode(Canvas canvas, Offset center) {
    final haloRect = Rect.fromCircle(center: center, radius: 28);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [primaryColor.withValues(alpha: 0.35), Colors.transparent],
      ).createShader(haloRect);
    canvas.drawCircle(center, 28, haloPaint);

    final outerFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: isDark ? 0.06 : 0.05);
    final outerStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: isDark ? 0.12 : 0.08)
      ..strokeWidth = 1;
    final midFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: isDark ? 0.10 : 0.07);
    final midStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: isDark ? 0.25 : 0.18)
      ..strokeWidth = 1;
    final coreFill = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF0A2040) : const Color(0xFFD6E8FF);
    final coreStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor
      ..strokeWidth = 2;

    canvas.drawCircle(center, 20, outerFill);
    canvas.drawCircle(center, 20, outerStroke);
    canvas.drawCircle(center, 13, midFill);
    canvas.drawCircle(center, 13, midStroke);
    canvas.drawCircle(center, 9, coreFill);
    canvas.drawCircle(center, 9, coreStroke);

    final checkPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final check = Path()
      ..moveTo(center.dx - 3.5, center.dy + 0.5)
      ..lineTo(center.dx - 1, center.dy + 3)
      ..lineTo(center.dx + 4, center.dy - 3);
    canvas.drawPath(check, checkPaint);

    _paintLabel(
      canvas,
      labels.destination,
      center - const Offset(0, 34),
      color: primaryColor.withValues(alpha: 0.75),
      size: 7.5,
      letterSpacing: 0.08,
      align: TextAlign.center,
    );
  }

  void _drawWaypoint(
    Canvas canvas,
    Offset center,
    String label,
    _WaypointType type,
  ) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = cardColor;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.38)
      ..strokeWidth = 1;

    canvas.drawCircle(center, 9, fill);
    canvas.drawCircle(center, 9, stroke);

    switch (type) {
      case _WaypointType.document:
        _drawDocumentIcon(canvas, center);
      case _WaypointType.cost:
        _paintLabel(
          canvas,
          r'$',
          center,
          color: primaryColor,
          size: 9,
          weight: FontWeight.w700,
          align: TextAlign.center,
        );
      case _WaypointType.route:
        _drawCompassIcon(canvas, center);
    }

    _paintLabel(
      canvas,
      label,
      center + const Offset(0, 19),
      color: textMutedColor,
      size: 6.5,
      align: TextAlign.center,
    );
  }

  void _drawDocumentIcon(Canvas canvas, Offset center) {
    final docRect = Rect.fromCenter(center: center, width: 7, height: 8.5);
    final docPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.85)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(docRect, const Radius.circular(1)),
      docPaint,
    );
    for (var i = 0; i < 3; i++) {
      final y = center.dy - 2.5 + (i * 2.2);
      canvas.drawLine(
        Offset(center.dx - 2.5, y),
        Offset(center.dx + 2.5, y),
        linePaint,
      );
    }
  }

  void _drawCompassIcon(Canvas canvas, Offset center) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.30)
      ..strokeWidth = 0.9;
    final northPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;
    final southPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = textMutedColor.withValues(alpha: 0.8);

    canvas.drawCircle(center, 4.5, ringPaint);
    final north = Path()
      ..moveTo(center.dx, center.dy - 4)
      ..lineTo(center.dx + 1.5, center.dy)
      ..lineTo(center.dx - 1.5, center.dy)
      ..close();
    final south = Path()
      ..moveTo(center.dx, center.dy + 4)
      ..lineTo(center.dx + 1.5, center.dy)
      ..lineTo(center.dx - 1.5, center.dy)
      ..close();
    canvas.drawPath(north, northPaint);
    canvas.drawPath(south, southPaint);
  }

  void _drawPlanCard(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.05, size.height * 0.08);
    final rect = Rect.fromLTWH(origin.dx, origin.dy, 72, 38);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0D1E3A).withValues(alpha: 0.50);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.22)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.50)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      stroke,
    );

    const widths = [38.0, 28.0, 32.0, 22.0];
    for (var i = 0; i < widths.length; i++) {
      final y = origin.dy + 10 + (i * 5);
      canvas.drawLine(
        Offset(origin.dx + 10, y),
        Offset(origin.dx + 10 + widths[i], y),
        linePaint,
      );
    }

    final checkCenter = origin + const Offset(58, 8);
    final badgeFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.18);
    final badgeStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.45)
      ..strokeWidth = 0.8;
    final checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(checkCenter, 6, badgeFill);
    canvas.drawCircle(checkCenter, 6, badgeStroke);
    final check = Path()
      ..moveTo(checkCenter.dx - 2, checkCenter.dy)
      ..lineTo(checkCenter.dx - 0.4, checkCenter.dy + 1.8)
      ..lineTo(checkCenter.dx + 2.4, checkCenter.dy - 1.8);
    canvas.drawPath(check, checkPaint);
  }

  void _drawHouse(Canvas canvas, Size size) {
    final anchor = Offset(size.width * 0.82, size.height * 0.68);
    final roofFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.12);
    final roofStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.35)
      ..strokeWidth = 0.9;
    final bodyFill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0D1E3A).withValues(alpha: 0.40);
    final bodyStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.28)
      ..strokeWidth = 0.9;
    final windowFill = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.18);
    final windowStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;

    final roof = Path()
      ..moveTo(anchor.dx - 3, anchor.dy + 10)
      ..lineTo(anchor.dx + 14, anchor.dy)
      ..lineTo(anchor.dx + 31, anchor.dy + 10)
      ..close();
    canvas.drawPath(roof, roofFill);
    canvas.drawPath(roof, roofStroke);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(anchor.dx, anchor.dy + 9, 28, 22),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, bodyFill);
    canvas.drawRRect(body, bodyStroke);

    final door = RRect.fromRectAndRadius(
      Rect.fromLTWH(anchor.dx + 10, anchor.dy + 21, 8, 10),
      const Radius.circular(1),
    );
    canvas.drawRRect(door, bodyStroke);

    final leftWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(anchor.dx + 4, anchor.dy + 15, 6, 5),
      const Radius.circular(1),
    );
    final rightWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(anchor.dx + 18, anchor.dy + 15, 6, 5),
      const Radius.circular(1),
    );
    canvas.drawRRect(leftWindow, windowFill);
    canvas.drawRRect(leftWindow, windowStroke);
    canvas.drawRRect(rightWindow, windowFill);
    canvas.drawRRect(rightWindow, windowStroke);
  }

  void _drawGlobe(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.85, size.height * 0.06);
    const radius = 14.0;
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0D1E3A).withValues(alpha: 0.30);
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.28)
      ..strokeWidth = 0.9;
    final mutedStroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.25)
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius, strokePaint);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 2, height: 12),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = primaryColor.withValues(alpha: 0.30)
        ..strokeWidth = 0.8,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      mutedStroke,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      mutedStroke,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance = next + gapLength;
      }
    }
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset anchor, {
    required Color color,
    required double size,
    TextAlign align = TextAlign.left,
    double letterSpacing = 0,
    FontWeight weight = FontWeight.w600,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: letterSpacing,
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = switch (align) {
      TextAlign.center =>
        anchor - Offset(textPainter.width / 2, textPainter.height / 2),
      TextAlign.right =>
        anchor - Offset(textPainter.width, textPainter.height / 2),
      _ => anchor - Offset(0, textPainter.height / 2),
    };
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(JourneyIllustrationPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.cardColor != cardColor ||
        oldDelegate.textMutedColor != textMutedColor ||
        oldDelegate.labels != labels;
  }
}

class JourneyIllustrationLabels {
  const JourneyIllustrationLabels({
    required this.origin,
    required this.destination,
    required this.documents,
    required this.costs,
    required this.route,
  });

  final String origin;
  final String destination;
  final String documents;
  final String costs;
  final String route;

  @override
  bool operator ==(Object other) {
    return other is JourneyIllustrationLabels &&
        other.origin == origin &&
        other.destination == destination &&
        other.documents == documents &&
        other.costs == costs &&
        other.route == route;
  }

  @override
  int get hashCode => Object.hash(origin, destination, documents, costs, route);
}

enum _WaypointType { document, cost, route }
