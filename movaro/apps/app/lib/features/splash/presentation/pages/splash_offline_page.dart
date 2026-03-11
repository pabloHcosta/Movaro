import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';

class SplashOfflinePage extends StatelessWidget {
  const SplashOfflinePage({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          const _OfflineBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: FrostedPanel(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    borderRadius: BorderRadius.circular(36),
                    backgroundColor: const Color(0xB30A1220),
                    borderColor: Colors.white.withValues(alpha: 0.10),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xE60A1220),
                        Color(0xCC10203A),
                        Color(0xB315335B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MovaroLogo(
                          markSize: 20,
                          textColor: Colors.white,
                          markColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: 180,
                            height: 180,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  Colors.white.withValues(alpha: 0.04),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/illustrations/offline.svg',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.apiUnavailableTitle,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                height: 1.0,
                                letterSpacing: -0.8,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.apiUnavailableDescription,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            l10n.apiUnavailableSupportingText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  height: 1.45,
                                ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: onRetry,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(l10n.apiUnavailableRetryAction),
                          ),
                        ),
                      ],
                    ),
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

class _OfflineBackground extends StatelessWidget {
  const _OfflineBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.heroStart.withValues(alpha: 0.96),
            AppColors.heroMiddle.withValues(alpha: 0.82),
            AppColors.heroEnd.withValues(alpha: 0.58),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
