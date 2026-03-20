import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/errors/error_handler.dart';
import 'package:movaro_app/core/location/location_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/auth/domain/entities/auth_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.authController,
    required this.locationController,
    super.key,
  });

  final AuthController authController;
  final LocationController locationController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final pendingActionLabel = _pendingActionLabel(context);
    final requiresAction = pendingActionLabel != null;

    return Scaffold(
      body: AnimatedBuilder(
        animation: authController,
        builder: (context, _) {
          return Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppGlassHeader(
                            title: l10n.loginPageTitle,
                            onBack: Navigator.canPop(context)
                                ? () => Navigator.maybePop(context)
                                : null,
                          ),
                          const SizedBox(height: 20),
                          FrostedPanel(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaceMuted,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    requiresAction
                                        ? l10n.loginActionRequired(
                                            pendingActionLabel,
                                          )
                                        : l10n.loginDescription,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: textSoft),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  l10n.loginHeadline,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  requiresAction
                                      ? l10n.loginDescription
                                      : l10n.publicHomeGuestSectionBody,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: textSoft),
                                ),
                                const SizedBox(height: 28),
                                FilledButton.icon(
                                  onPressed: authController.isBusy
                                      ? null
                                      : () => _handleSignIn(
                                          context,
                                          AuthProvider.apple,
                                        ),
                                  icon: const Icon(Icons.apple_rounded),
                                  label: Text(l10n.loginAppleAction),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: authController.isBusy
                                      ? null
                                      : () => _handleSignIn(
                                          context,
                                          AuthProvider.google,
                                        ),
                                  icon: const Icon(Icons.mail_outline_rounded),
                                  label: Text(l10n.loginGoogleAction),
                                ),
                                if (!requiresAction) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          Navigator.maybePop(context),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                      ),
                                      label: Text(l10n.loginLaterAction),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Text(
                                  l10n.loginDevOnlyHint,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: textSoft),
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
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleSignIn(
    BuildContext context,
    AuthProvider provider,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await authController.signIn(provider);

      if (!context.mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        authController.resolveRouteAfterLogin(),
      );
    } catch (error) {
      final uiError = ErrorHandler.resolve(context, error);
      messenger.showSnackBar(SnackBar(content: Text(uiError.description)));
    }
  }

  String? _pendingActionLabel(BuildContext context) {
    final l10n = context.l10n;

    switch (authController.pendingRoute) {
      case AppRoutes.migrationSave:
        return l10n.pendingActionSavePlan;
      case AppRoutes.communityCreate:
        return l10n.pendingActionPostCommunity;
      case String route when AppRoutes.isCityDetailRoute(route):
        return l10n.pendingActionSaveCity;
      default:
        return null;
    }
  }
}
