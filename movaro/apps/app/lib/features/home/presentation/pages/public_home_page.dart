import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/language_selector_button.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({required this.journeyContextController, super.key});

  final JourneyContextController journeyContextController;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.isDesktopLayout ? 1160.0 : 920.0;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 24,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: LanguageSelectorButton(
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _LandingHero(
                      journeyContextController: journeyContextController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingHero extends StatelessWidget {
  const _LandingHero({required this.journeyContextController});

  final JourneyContextController journeyContextController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 920;
    final origin = journeyContextController.selectedOrigin;
    final destination = journeyContextController.selectedDestination;

    final primary = _PrimaryIntroBlock(
      origin: origin,
      destination: destination,
      title: l10n.publicHomeHeadline,
      body: origin != null && destination != null
          ? l10n.publicHomeSelectedJourneyDescription(
              origin.name,
              destination.name,
            )
          : l10n.publicHomeFocusedDescription,
    );

    final actions = const _ActionStage();

    return FrostedPanel(
      padding: EdgeInsets.all(stacked ? 24 : 32),
      backgroundColor: const Color(0xB30B1320),
      borderColor: Colors.white.withValues(alpha: 0.12),
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroMiddle, AppColors.heroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [primary, const SizedBox(height: 22), actions],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: primary),
                const SizedBox(width: 26),
                Expanded(flex: 4, child: actions),
              ],
            ),
    );
  }
}

class _PrimaryIntroBlock extends StatelessWidget {
  const _PrimaryIntroBlock({
    required this.origin,
    required this.destination,
    required this.title,
    required this.body,
  });

  final CatalogCountry? origin;
  final CatalogCountry? destination;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoutePlate(
          originEmoji: origin?.flagEmoji ?? '🇦🇷',
          originName: origin?.name ?? 'Argentina',
          destinationEmoji: destination?.flagEmoji ?? '🇧🇷',
          destinationName: destination?.name ?? 'Brasil',
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style:
              (compact
                      ? Theme.of(context).textTheme.headlineLarge
                      : Theme.of(context).textTheme.displayMedium)
                  ?.copyWith(
                    color: Colors.white,
                    letterSpacing: compact ? -0.8 : -1.3,
                    height: 0.94,
                    fontWeight: FontWeight.w700,
                  ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionStage extends StatelessWidget {
  const _ActionStage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final planCard = _VisualActionCard(
      title: l10n.publicHomePlanTitle,
      description: l10n.publicHomePlanBody,
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire),
      isPrimary: true,
      scene: const _PlanScene(),
    );

    final citiesCard = _VisualActionCard(
      title: l10n.publicHomeCitiesTitle,
      description: l10n.publicHomeCitiesBody,
      onTap: () => Navigator.pushNamed(context, AppRoutes.cities),
      scene: const _CitiesScene(),
      compact: true,
    );

    final questionsCard = _VisualActionCard(
      title: l10n.publicHomeQuestionsTitle,
      description: l10n.publicHomeQuestionsBody,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.documentationGuide,
        arguments: DocumentationGuideSection.documents,
      ),
      scene: const _QuestionsScene(),
      compact: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        planCard,
        const SizedBox(height: 8),
        if (width < 420)
          Column(
            children: [citiesCard, const SizedBox(height: 10), questionsCard],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: citiesCard),
              const SizedBox(width: 10),
              Expanded(child: questionsCard),
            ],
          ),
      ],
    );
  }
}

class _VisualActionCard extends StatelessWidget {
  const _VisualActionCard({
    required this.title,
    required this.description,
    required this.onTap,
    required this.scene,
    this.isPrimary = false,
    this.compact = false,
  });

  final String title;
  final String description;
  final VoidCallback onTap;
  final Widget scene;
  final bool isPrimary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cardGradient = isPrimary
        ? const LinearGradient(
            colors: [Color(0xFFF9FBFF), Color(0xFFEAF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF4F7FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final fixedHeight = compact ? 194.0 : 250.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: isPrimary ? 0.48 : 0.28),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: SizedBox(
            height: fixedHeight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 10 : 12,
                compact ? 10 : 12,
                compact ? 10 : 12,
                compact ? 8 : 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: compact ? 66 : (isPrimary ? 108 : 86),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7BC8F2),
                          Color(0xFF69B8EE),
                          Color(0xFF4E9FF0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: scene,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    title,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.titleSmall
                                : (isPrimary
                                      ? Theme.of(context).textTheme.titleLarge
                                      : Theme.of(
                                          context,
                                        ).textTheme.titleMedium))
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.05,
                              fontWeight: FontWeight.w700,
                              fontSize: compact ? 16 : null,
                            ),
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  Text(
                    description,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoft,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: compact ? 18 : 20,
                      color: isPrimary ? AppColors.primary : AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionsScene extends StatelessWidget {
  const _QuestionsScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 18,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -10,
          top: -8,
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -12,
          bottom: -16,
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(220, 64),
                topRight: Radius.elliptical(240, 68),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 178,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: _QuestionSheet(accent: const Color(0xFF2B7BE8)),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 10,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: _QuestionSheet(accent: const Color(0xFF7E4DFF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionSheet extends StatelessWidget {
  const _QuestionSheet({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.question_answer_rounded, size: 15, color: accent),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0x332B7BE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePlate extends StatelessWidget {
  const _RoutePlate({
    required this.originEmoji,
    required this.originName,
    required this.destinationEmoji,
    required this.destinationName,
  });

  final String originEmoji;
  final String originName;
  final String destinationEmoji;
  final String destinationName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RouteNode(emoji: originEmoji, name: originName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          _RouteNode(emoji: destinationEmoji, name: destinationName),
        ],
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlanScene extends StatelessWidget {
  const _PlanScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 18,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 26,
          top: 20,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -12,
          bottom: -28,
          child: Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -18,
          top: -10,
          child: Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 44,
          bottom: 34,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xD9FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(240, 70),
                topRight: Radius.elliptical(220, 60),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 190,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 8,
                  top: 30,
                  child: Transform.rotate(
                    angle: -0.10,
                    child: Container(
                      width: 102,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: CustomPaint(painter: const _ChecklistPainter()),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 8,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: Container(
                      width: 74,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2B7BE8,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: Color(0xFF2B7BE8),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0x332B7BE8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 32,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0x332B7BE8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CitiesScene extends StatelessWidget {
  const _CitiesScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 20,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -12,
          top: -6,
          child: Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -18,
          bottom: -24,
          child: Container(
            width: 102,
            height: 102,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(220, 64),
                topRight: Radius.elliptical(260, 74),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 190,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Positioned(
                  left: 10,
                  top: 24,
                  child: _MiniCityCard(
                    titleWidth: 44,
                    accent: Color(0xFF35C6F4),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _MiniCityCard(
                    titleWidth: 52,
                    accent: Color(0xFF2B7BE8),
                  ),
                ),
                Positioned(bottom: 8, child: _LocationPinCard()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniCityCard extends StatelessWidget {
  const _MiniCityCard({required this.titleWidth, required this.accent});

  final double titleWidth;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Container(
              width: titleWidth,
              height: 8,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPinCard extends StatelessWidget {
  const _LocationPinCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.location_on_rounded,
          size: 34,
          color: Color(0xFF7E4DFF),
        ),
      ),
    );
  }
}

class _ChecklistPainter extends CustomPainter {
  const _ChecklistPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x332B7BE8)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = const Color(0xFF2B7BE8);

    for (var i = 0; i < 3; i++) {
      final y = 14.0 + (i * 16.0);
      canvas.drawCircle(Offset(10, y), 3.5, dotPaint);
      canvas.drawLine(Offset(20, y), Offset(size.width - 12, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
