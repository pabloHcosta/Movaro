import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({
    required this.journeyContextController,
    this.isFirstLaunch = false,
    super.key,
  });

  final bool isFirstLaunch;
  final JourneyContextController journeyContextController;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context) async {
    await widget.journeyContextController.markIntroSeen();

    if (!context.mounted) {
      return;
    }

    if (widget.isFirstLaunch) {
      Navigator.pushReplacementNamed(context, AppRoutes.journeySetup);
      return;
    }

    Navigator.maybePop(context);
  }

  void _goNext(BuildContext context) {
    if (_currentPage == 2) {
      _finish(context);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 720;

    final slides = [
      _IntroSlideData(
        webAssetPath: 'assets/illustrations/intro_explore_web.svg',
        mobileAssetPath: 'assets/illustrations/intro_explore_mobile.svg',
        title: l10n.introExploreTitle,
        description: l10n.introExploreDescription,
      ),
      _IntroSlideData(
        webAssetPath: 'assets/illustrations/intro_plan_web.svg',
        mobileAssetPath: 'assets/illustrations/intro_plan_mobile.svg',
        title: l10n.introPlanTitle,
        description: l10n.introPlanDescription,
      ),
      _IntroSlideData(
        webAssetPath: 'assets/illustrations/intro_documents_web.svg',
        mobileAssetPath: 'assets/illustrations/intro_documents_mobile.svg',
        title: l10n.introDocumentationTitle,
        description: l10n.introDocumentationDescription,
      ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          const _IntroBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 20 : 32,
                    isCompact ? 16 : 28,
                    isCompact ? 20 : 32,
                    isCompact ? 18 : 28,
                  ),
                  child: Column(
                    children: [
                      _IntroTopBar(
                        title: l10n.introPageTitle,
                        skipLabel: l10n.introSkipAction,
                        showBack:
                            !widget.isFirstLaunch || Navigator.canPop(context),
                        onBack: () => Navigator.maybePop(context),
                        onSkip: () => _finish(context),
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 20 : 28),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slides.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _IntroStepPage(
                              data: slides[index],
                              isCompact: isCompact,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: isCompact ? 18 : 28),
                      _IntroBottomSection(
                        currentPage: _currentPage,
                        isCompact: isCompact,
                        onDotTap: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        onNext: () => _goNext(context),
                        primaryLabel: _currentPage == 2
                            ? l10n.introPrimaryAction
                            : 'Next',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroSlideData {
  const _IntroSlideData({
    required this.webAssetPath,
    required this.mobileAssetPath,
    required this.title,
    required this.description,
  });

  final String webAssetPath;
  final String mobileAssetPath;
  final String title;
  final String description;
}

class _IntroTopBar extends StatelessWidget {
  const _IntroTopBar({
    required this.title,
    required this.skipLabel,
    required this.showBack,
    required this.onBack,
    required this.onSkip,
    required this.isCompact,
  });

  final String title;
  final String skipLabel;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          _CircleGhostButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
            size: isCompact ? 40 : 46,
          )
        else
          SizedBox(width: isCompact ? 40 : 46),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isCompact ? 15 : 17,
                height: 1.2,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: 8,
            ),
          ),
          child: Text(
            skipLabel,
            style: TextStyle(
              fontSize: isCompact ? 14 : 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroStepPage extends StatelessWidget {
  const _IntroStepPage({required this.data, required this.isCompact});

  final _IntroSlideData data;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          Expanded(
            flex: 60,
            child: _IntroHeroIllustration(
              assetPath: data.mobileAssetPath,
              isCompact: true,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            flex: 24,
            child: _IntroTextContent(
              title: data.title,
              description: data.description,
              isCompact: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 11,
          child: _IntroTextContent(
            title: data.title,
            description: data.description,
            isCompact: false,
          ),
        ),
        const SizedBox(width: 36),
        Expanded(
          flex: 12,
          child: _IntroHeroIllustration(
            assetPath: data.webAssetPath,
            isCompact: false,
          ),
        ),
      ],
    );
  }
}

class _IntroHeroIllustration extends StatelessWidget {
  const _IntroHeroIllustration({
    required this.assetPath,
    required this.isCompact,
  });

  final String assetPath;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 28 : 36),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: isCompact ? 20 : 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 28 : 36),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.heroStart.withValues(alpha: 0.94),
                    AppColors.heroMiddle.withValues(alpha: 0.84),
                    AppColors.heroEnd.withValues(alpha: 0.46),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: -26,
              right: -12,
              child: IgnorePointer(
                child: Container(
                  width: isCompact ? 170 : 240,
                  height: isCompact ? 170 : 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.glowBlue.withValues(alpha: 0.16),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -36,
              bottom: -48,
              child: IgnorePointer(
                child: Container(
                  width: isCompact ? 150 : 200,
                  height: isCompact ? 150 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.glowLavender.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 8 : 18,
                isCompact ? 8 : 18,
                isCompact ? 8 : 18,
                isCompact ? 8 : 18,
              ),
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroTextContent extends StatelessWidget {
  const _IntroTextContent({
    required this.title,
    required this.description,
    required this.isCompact,
  });

  final String title;
  final String description;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: isCompact
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      crossAxisAlignment: isCompact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (!isCompact) const SizedBox(height: 22),
        Text(
          title,
          textAlign: isCompact ? TextAlign.center : TextAlign.left,
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style:
              (isCompact
                      ? Theme.of(context).textTheme.headlineLarge
                      : Theme.of(context).textTheme.displaySmall)
                  ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 0.98,
                    letterSpacing: -1.0,
                  ),
        ),
        SizedBox(height: isCompact ? 14 : 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? 340 : 480),
          child: Text(
            description,
            textAlign: isCompact ? TextAlign.center : TextAlign.left,
            maxLines: isCompact ? 4 : 5,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.5,
              fontSize: isCompact ? 16 : 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroBottomSection extends StatelessWidget {
  const _IntroBottomSection({
    required this.currentPage,
    required this.isCompact,
    required this.onDotTap,
    required this.onNext,
    required this.primaryLabel,
  });

  final int currentPage;
  final bool isCompact;
  final ValueChanged<int> onDotTap;
  final VoidCallback onNext;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageDots(
          currentPage: currentPage,
          onDotTap: onDotTap,
          darkStyle: false,
        ),
        SizedBox(height: isCompact ? 16 : 18),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? 340 : 220),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: currentPage == 2
                    ? AppColors.primary
                    : Colors.white,
                foregroundColor: currentPage == 2
                    ? Colors.white
                    : AppColors.primary,
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? 18 : 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: currentPage == 2
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.40),
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                primaryLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 16 : 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.currentPage,
    required this.onDotTap,
    required this.darkStyle,
  });

  final int currentPage;
  final ValueChanged<int> onDotTap;
  final bool darkStyle;

  @override
  Widget build(BuildContext context) {
    final activeColor = darkStyle ? Colors.white : AppColors.primary;
    final inactiveColor = darkStyle
        ? Colors.white.withValues(alpha: 0.22)
        : AppColors.primary.withValues(alpha: 0.24);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = currentPage == index;
        return GestureDetector(
          onTap: () => onDotTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _CircleGhostButton extends StatelessWidget {
  const _CircleGhostButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: size * 0.46),
      ),
    );
  }
}

class _IntroBackground extends StatelessWidget {
  const _IntroBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.heroStart,
            AppColors.heroMiddle,
            AppColors.heroEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
