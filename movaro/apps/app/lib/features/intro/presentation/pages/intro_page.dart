import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({
    required this.journeyContextController,
    required this.locationController,
    this.isFirstLaunch = false,
    super.key,
  });

  final bool isFirstLaunch;
  final JourneyContextController journeyContextController;
  final LocationController locationController;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isResolvingLocation = false;

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
      Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
      return;
    }

    Navigator.maybePop(context);
  }

  Future<void> _handlePrimaryAction() async {
    final slide = _slidesFor(context)[_currentPage];
    if (!slide.isLocationStep) {
      if (_currentPage == _slidesFor(context).length - 1) {
        await _finish(context);
        return;
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    setState(() {
      _isResolvingLocation = true;
    });

    final result = await widget.locationController.requestPermissionAndCapture();
    if (!mounted) {
      return;
    }

    setState(() {
      _isResolvingLocation = false;
    });

    if (result.outcome == LocationPermissionOutcome.permanentlyDenied) {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Padding(
          padding: const EdgeInsets.all(16),
          child: FrostedPanel(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.locationSettingsTitle(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.locationSettingsBody(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await widget.locationController.openAppSettings();
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: Text(context.l10n.locationOpenSettingsAction()),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (mounted) {
      await _finish(context);
    }
  }

  Future<void> _handleSecondaryAction() async {
    await widget.locationController.deferPermission();
    if (mounted) {
      await _finish(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 720;
    final slides = _slidesFor(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          const _IntroBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 20 : 32,
                    isCompact ? 16 : 24,
                    isCompact ? 20 : 32,
                    isCompact ? 20 : 24,
                  ),
                  child: Column(
                    children: [
                      _IntroTopBar(
                        skipLabel: context.l10n.introSkipAction,
                        onSkip: () => _finish(context),
                        isCompact: isCompact,
                      ),
                      const SizedBox(height: 12),
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
                            final slide = slides[index];
                            return _IntroSlidePage(
                              slide: slide,
                              pageIndex: index,
                              currentPage: _currentPage,
                              totalPages: slides.length,
                              isCompact: isCompact,
                              isBusy: _isResolvingLocation &&
                                  slide.isLocationStep &&
                                  index == _currentPage,
                              onDotTap: (page) {
                                _pageController.animateToPage(
                                  page,
                                  duration: const Duration(milliseconds: 320),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              onPrimaryAction: _handlePrimaryAction,
                              onSecondaryAction: slide.isLocationStep
                                  ? _handleSecondaryAction
                                  : null,
                            );
                          },
                        ),
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

  List<_IntroSlideData> _slidesFor(BuildContext context) {
    final l10n = context.l10n;
    return [
      _IntroSlideData(
        title: l10n.introRedesignCityTitle(),
        description: l10n.introRedesignCityDescription(),
        primaryLabel: l10n.commonNextAction(),
        illustration: _introDiscoverCitySvg,
      ),
      _IntroSlideData(
        title: l10n.introRedesignPlanTitle(),
        description: l10n.introRedesignPlanDescription(),
        primaryLabel: l10n.commonNextAction(),
        illustration: _introPlanSvg,
      ),
      _IntroSlideData(
        title: l10n.introRedesignGuideTitle(),
        description: l10n.introRedesignGuideDescription(),
        primaryLabel: l10n.commonNextAction(),
        illustration: _introGuideSvg,
      ),
      _IntroSlideData(
        title: l10n.introRedesignLocationTitle(),
        description: l10n.introRedesignLocationDescription(),
        primaryLabel: l10n.locationPermissionAllowAction(),
        secondaryLabel: l10n.locationPermissionLaterAction(),
        illustration: _introLocationSvg,
        isLocationStep: true,
      ),
    ];
  }
}

class _IntroSlideData {
  const _IntroSlideData({
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.illustration,
    this.secondaryLabel,
    this.isLocationStep = false,
  });

  final String title;
  final String description;
  final String primaryLabel;
  final String? secondaryLabel;
  final String illustration;
  final bool isLocationStep;
}

class _IntroTopBar extends StatelessWidget {
  const _IntroTopBar({
    required this.skipLabel,
    required this.onSkip,
    required this.isCompact,
  });

  final String skipLabel;
  final VoidCallback onSkip;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isCompact ? 44 : 48,
      child: Row(
        children: [
          SizedBox(width: isCompact ? 40 : 48),
          const Expanded(
            child: Text(
              'Movaro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(
              skipLabel,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroSlidePage extends StatelessWidget {
  const _IntroSlidePage({
    required this.slide,
    required this.pageIndex,
    required this.currentPage,
    required this.totalPages,
    required this.isCompact,
    required this.isBusy,
    required this.onDotTap,
    required this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final _IntroSlideData slide;
  final int pageIndex;
  final int currentPage;
  final int totalPages;
  final bool isCompact;
  final bool isBusy;
  final ValueChanged<int> onDotTap;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 55,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320, maxHeight: 280),
              child: SvgPicture.string(
                slide.illustration,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.06,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PageDots(
                currentPage: currentPage,
                totalPages: totalPages,
                onDotTap: onDotTap,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isBusy ? null : onPrimaryAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      vertical: isCompact ? 18 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          slide.primaryLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              if (slide.secondaryLabel != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: isBusy ? null : onSecondaryAction,
                  child: Text(
                    slide.secondaryLabel!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.currentPage,
    required this.totalPages,
    required this.onDotTap,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final active = currentPage == index;
        return GestureDetector(
          onTap: () => onDotTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
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

const _introDiscoverCitySvg = r'''
<svg width="280" height="240" viewBox="0 0 280 240" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="80" y="10" width="120" height="75" rx="14" fill="rgba(255,255,255,0.22)" stroke="rgba(255,255,255,0.4)" stroke-width="1.5"/>
  <rect x="100" y="2" width="80" height="16" rx="8" fill="#1976D2" stroke="rgba(100,181,246,0.6)" stroke-width="1"/>
  <text x="140" y="13" font-size="9" fill="white" text-anchor="middle" font-family="sans-serif" font-weight="600">✦ Melhor fit</text>
  <text x="96" y="36" font-size="14" font-weight="800" fill="white" font-family="sans-serif">Curitiba</text>
  <text x="96" y="49" font-size="9" fill="rgba(255,255,255,0.65)" font-family="sans-serif">Paraná (PR) · Brasil</text>
  <rect x="90" y="56" width="30" height="22" rx="6" fill="rgba(0,0,0,0.2)"/>
  <text x="105" y="65" font-size="7" fill="rgba(255,255,255,0.5)" text-anchor="middle" font-family="sans-serif">Custo</text>
  <text x="105" y="74" font-size="9" font-weight="700" fill="#86EFAC" text-anchor="middle" font-family="sans-serif">Bom</text>
  <rect x="125" y="56" width="30" height="22" rx="6" fill="rgba(0,0,0,0.2)"/>
  <text x="140" y="65" font-size="7" fill="rgba(255,255,255,0.5)" text-anchor="middle" font-family="sans-serif">Clima</text>
  <text x="140" y="74" font-size="9" font-weight="700" fill="white" text-anchor="middle" font-family="sans-serif">18°C</text>
  <rect x="160" y="56" width="30" height="22" rx="6" fill="rgba(0,0,0,0.2)"/>
  <text x="175" y="65" font-size="7" fill="rgba(255,255,255,0.5)" text-anchor="middle" font-family="sans-serif">IDH</text>
  <text x="175" y="74" font-size="9" font-weight="700" fill="#86EFAC" text-anchor="middle" font-family="sans-serif">Alto</text>
  <rect x="8" y="65" width="95" height="62" rx="12" fill="rgba(255,255,255,0.13)" stroke="rgba(255,255,255,0.22)" stroke-width="1"/>
  <text x="20" y="84" font-size="12" font-weight="700" fill="white" font-family="sans-serif">São Paulo</text>
  <text x="20" y="96" font-size="8" fill="rgba(255,255,255,0.55)" font-family="sans-serif">SP · Brasil</text>
  <rect x="18" y="102" width="36" height="10" rx="5" fill="rgba(239,68,68,0.35)" stroke="rgba(239,68,68,0.55)" stroke-width="0.5"/>
  <text x="36" y="110" font-size="7" fill="#FCA5A5" text-anchor="middle" font-family="sans-serif">Custo alto</text>
  <rect x="58" y="102" width="36" height="10" rx="5" fill="rgba(34,197,94,0.25)" stroke="rgba(34,197,94,0.45)" stroke-width="0.5"/>
  <text x="76" y="110" font-size="7" fill="#86EFAC" text-anchor="middle" font-family="sans-serif">Mercado</text>
  <rect x="177" y="65" width="95" height="62" rx="12" fill="rgba(255,255,255,0.13)" stroke="rgba(255,255,255,0.22)" stroke-width="1"/>
  <text x="189" y="84" font-size="12" font-weight="700" fill="white" font-family="sans-serif">João Pessoa</text>
  <text x="189" y="96" font-size="8" fill="rgba(255,255,255,0.55)" font-family="sans-serif">PB · Brasil</text>
  <rect x="187" y="102" width="36" height="10" rx="5" fill="rgba(34,197,94,0.25)" stroke="rgba(34,197,94,0.45)" stroke-width="0.5"/>
  <text x="205" y="110" font-size="7" fill="#86EFAC" text-anchor="middle" font-family="sans-serif">Low cost</text>
  <rect x="227" y="102" width="36" height="10" rx="5" fill="rgba(96,165,250,0.25)" stroke="rgba(96,165,250,0.45)" stroke-width="0.5"/>
  <text x="245" y="110" font-size="7" fill="#93C5FD" text-anchor="middle" font-family="sans-serif">Litoral</text>
  <circle cx="70" cy="178" r="20" fill="rgba(255,255,255,0.1)" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
  <text x="70" y="185" font-size="22" text-anchor="middle">🇦🇷</text>
  <path d="M92 178 L118 178" stroke="rgba(255,255,255,0.4)" stroke-width="2" stroke-dasharray="4 3"/>
  <text x="128" y="184" font-size="18" text-anchor="middle">✈</text>
  <path d="M138 178 L160 178" stroke="rgba(255,255,255,0.4)" stroke-width="2" stroke-dasharray="4 3"/>
  <circle cx="178" cy="178" r="20" fill="rgba(255,255,255,0.1)" stroke="rgba(255,255,255,0.2)" stroke-width="1"/>
  <text x="178" y="185" font-size="22" text-anchor="middle">🇧🇷</text>
  <ellipse cx="140" cy="222" rx="100" ry="10" fill="rgba(255,255,255,0.04)"/>
</svg>
''';

const _introPlanSvg = r'''
<svg width="280" height="240" viewBox="0 0 280 240" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="30" y="8" width="220" height="200" rx="18" fill="rgba(255,255,255,0.12)" stroke="rgba(255,255,255,0.22)" stroke-width="1.5"/>
  <text x="46" y="32" font-size="9" fill="rgba(255,255,255,0.45)" font-family="sans-serif">Pergunta 2 de 6</text>
  <rect x="46" y="38" width="188" height="6" rx="3" fill="rgba(255,255,255,0.15)"/>
  <rect x="46" y="38" width="75" height="6" rx="3" fill="white"/>
  <text x="140" y="68" font-size="13" font-weight="800" fill="white" text-anchor="middle" font-family="sans-serif">Quando você planeja</text>
  <text x="140" y="84" font-size="13" font-weight="800" fill="white" text-anchor="middle" font-family="sans-serif">fazer essa mudança?</text>
  <rect x="46" y="96" width="188" height="26" rx="10" fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="1"/>
  <text x="140" y="113" font-size="11" fill="rgba(255,255,255,0.55)" text-anchor="middle" font-family="sans-serif">Ainda estou explorando</text>
  <rect x="46" y="126" width="188" height="26" rx="10" fill="rgba(25,118,210,0.5)" stroke="#64B5F6" stroke-width="1.5"/>
  <circle cx="60" cy="139" r="7" fill="rgba(255,255,255,0.2)" stroke="white" stroke-width="1.5"/>
  <circle cx="60" cy="139" r="3" fill="white"/>
  <text x="150" y="143" font-size="11" font-weight="600" fill="white" text-anchor="middle" font-family="sans-serif">Em 3 a 6 meses</text>
  <rect x="46" y="156" width="188" height="26" rx="10" fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="1"/>
  <text x="140" y="173" font-size="11" fill="rgba(255,255,255,0.55)" text-anchor="middle" font-family="sans-serif">Em 6 a 12 meses</text>
  <rect x="46" y="188" width="188" height="10" rx="5" fill="rgba(255,255,255,0.06)"/>
  <text x="140" y="196" font-size="8" fill="rgba(255,255,255,0.25)" text-anchor="middle" font-family="sans-serif">+ 3 opções</text>
</svg>
''';

const _introGuideSvg = r'''
<svg width="280" height="240" viewBox="0 0 280 240" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="240" height="200" rx="18" fill="rgba(255,255,255,0.12)" stroke="rgba(255,255,255,0.22)" stroke-width="1.5"/>
  <text x="40" y="36" font-size="13" font-weight="800" fill="white" font-family="sans-serif">Guia de chegada</text>
  <text x="40" y="50" font-size="9" fill="rgba(255,255,255,0.45)" font-family="sans-serif">Curitiba · Argentina → Brasil</text>
  <text x="240" y="36" font-size="11" font-weight="700" fill="#86EFAC" text-anchor="end" font-family="sans-serif">2 / 5</text>
  <line x1="40" y1="58" x2="240" y2="58" stroke="rgba(255,255,255,0.1)" stroke-width="1"/>
  <rect x="32" y="66" width="216" height="26" rx="9" fill="rgba(34,197,94,0.15)" stroke="rgba(34,197,94,0.35)" stroke-width="1"/>
  <circle cx="50" cy="79" r="8" fill="#22C55E"/>
  <text x="50" y="83" font-size="11" fill="white" text-anchor="middle" font-family="sans-serif">✓</text>
  <text x="68" y="83" font-size="11" fill="rgba(255,255,255,0.75)" font-family="sans-serif">Passaporte válido</text>
  <rect x="32" y="96" width="216" height="26" rx="9" fill="rgba(34,197,94,0.15)" stroke="rgba(34,197,94,0.35)" stroke-width="1"/>
  <circle cx="50" cy="109" r="8" fill="#22C55E"/>
  <text x="50" y="113" font-size="11" fill="white" text-anchor="middle" font-family="sans-serif">✓</text>
  <text x="68" y="113" font-size="11" fill="rgba(255,255,255,0.75)" font-family="sans-serif">Voo reservado</text>
  <rect x="32" y="126" width="216" height="26" rx="9" fill="rgba(25,118,210,0.35)" stroke="#64B5F6" stroke-width="1.5"/>
  <circle cx="50" cy="139" r="8" fill="rgba(255,255,255,0.15)" stroke="white" stroke-width="1.5"/>
  <text x="68" y="143" font-size="11" font-weight="600" fill="white" font-family="sans-serif">CPF e RNE → em andamento</text>
  <rect x="32" y="156" width="216" height="26" rx="9" fill="rgba(255,255,255,0.06)" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
  <circle cx="50" cy="169" r="8" fill="none" stroke="rgba(255,255,255,0.3)" stroke-width="1.5"/>
  <text x="68" y="173" font-size="11" fill="rgba(255,255,255,0.4)" font-family="sans-serif">Conta bancária brasileira</text>
  <rect x="32" y="186" width="216" height="16" rx="8" fill="rgba(255,255,255,0.04)" stroke="rgba(255,255,255,0.08)" stroke-width="1"/>
  <text x="68" y="198" font-size="9" fill="rgba(255,255,255,0.25)" font-family="sans-serif">+ 3 itens aguardando...</text>
</svg>
''';

const _introLocationSvg = r'''
<svg width="280" height="240" viewBox="0 0 280 240" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="8" width="240" height="160" rx="18" fill="rgba(255,255,255,0.08)" stroke="rgba(255,255,255,0.15)" stroke-width="1.5"/>
  <line x1="20" y1="48" x2="260" y2="48" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="20" y1="88" x2="260" y2="88" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="20" y1="128" x2="260" y2="128" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="60" y1="8" x2="60" y2="168" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="100" y1="8" x2="100" y2="168" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="140" y1="8" x2="140" y2="168" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="180" y1="8" x2="180" y2="168" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <line x1="220" y1="8" x2="220" y2="168" stroke="rgba(255,255,255,0.06)" stroke-width="0.5"/>
  <circle cx="140" cy="88" r="52" fill="rgba(25,118,210,0.08)" stroke="rgba(100,181,246,0.15)" stroke-width="1"/>
  <circle cx="140" cy="88" r="34" fill="rgba(25,118,210,0.15)" stroke="rgba(100,181,246,0.25)" stroke-width="1"/>
  <circle cx="140" cy="88" r="18" fill="rgba(25,118,210,0.3)" stroke="rgba(100,181,246,0.45)" stroke-width="1.5"/>
  <circle cx="140" cy="88" r="9" fill="#1976D2" stroke="#64B5F6" stroke-width="2"/>
  <circle cx="140" cy="88" r="4" fill="white"/>
  <rect x="152" y="62" width="90" height="20" rx="10" fill="rgba(255,255,255,0.2)" stroke="rgba(255,255,255,0.35)" stroke-width="1"/>
  <text x="197" y="75" font-size="9.5" fill="white" text-anchor="middle" font-family="sans-serif" font-weight="600">Buenos Aires 🇦🇷</text>
  <line x1="152" y1="74" x2="149" y2="82" stroke="rgba(255,255,255,0.35)" stroke-width="1"/>
  <circle cx="80" cy="60" r="5" fill="rgba(255,255,255,0.2)" stroke="rgba(255,255,255,0.3)" stroke-width="1"/>
  <circle cx="200" cy="120" r="5" fill="rgba(255,255,255,0.2)" stroke="rgba(255,255,255,0.3)" stroke-width="1"/>
  <circle cx="220" cy="50" r="4" fill="rgba(255,255,255,0.15)" stroke="rgba(255,255,255,0.25)" stroke-width="1"/>
  <circle cx="50" cy="130" r="4" fill="rgba(255,255,255,0.15)" stroke="rgba(255,255,255,0.25)" stroke-width="1"/>
  <rect x="20" y="178" width="240" height="20" rx="10" fill="rgba(34,197,94,0.12)" stroke="rgba(34,197,94,0.25)" stroke-width="1"/>
  <circle cx="38" cy="188" r="7" fill="#22C55E"/>
  <text x="38" y="192" font-size="10" fill="white" text-anchor="middle" font-family="sans-serif">✓</text>
  <text x="140" y="192" font-size="9" fill="rgba(255,255,255,0.7)" text-anchor="middle" font-family="sans-serif">País de origem detectado automaticamente</text>
  <rect x="20" y="202" width="240" height="20" rx="10" fill="rgba(25,118,210,0.12)" stroke="rgba(25,118,210,0.25)" stroke-width="1"/>
  <circle cx="38" cy="212" r="7" fill="#1976D2"/>
  <text x="38" y="216" font-size="10" fill="white" text-anchor="middle" font-family="sans-serif">✓</text>
  <text x="140" y="216" font-size="9" fill="rgba(255,255,255,0.7)" text-anchor="middle" font-family="sans-serif">Moeda e conteúdo na sua língua</text>
</svg>
''';
