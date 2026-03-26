import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';

class LocationPermissionScreenArgs {
  const LocationPermissionScreenArgs({
    this.continueRoute,
    this.returnToPrevious = false,
    this.isRequired = false,
  });

  final String? continueRoute;
  final bool returnToPrevious;
  final bool isRequired;
}

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({
    required this.locationController,
    this.args = const LocationPermissionScreenArgs(),
    super.key,
  });

  final LocationController locationController;
  final LocationPermissionScreenArgs args;

  @override
  Widget build(BuildContext context) {
    final textSoft = AppColors.textSoftFor(context);

    return Scaffold(
      body: Stack(
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
                  child: AnimatedBuilder(
                    animation: locationController,
                    builder: (context, _) {
                      return FrostedPanel(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 72,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              context.l10n.locationPermissionTitle(),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.locationPermissionSubtitle(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(color: textSoft),
                            ),
                            const SizedBox(height: 24),
                            _BenefitRow(
                              icon: Icons.flag_outlined,
                              label: context.l10n
                                  .locationPermissionBenefitAutoOrigin(),
                            ),
                            const SizedBox(height: 12),
                            _BenefitRow(
                              icon: Icons.route_outlined,
                              label: context.l10n
                                  .locationPermissionBenefitDistance(),
                            ),
                            const SizedBox(height: 12),
                            _BenefitRow(
                              icon: Icons.explore_outlined,
                              label: context.l10n
                                  .locationPermissionBenefitContent(),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: locationController.isBusy
                                    ? null
                                    : () => _handleAllowLocation(context),
                                child: Text(
                                  context.l10n.locationPermissionAllowAction(),
                                ),
                              ),
                            ),
                            if (!args.isRequired) ...[
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: locationController.isBusy
                                      ? null
                                      : () => _handleNotNow(context),
                                  child: Text(
                                    context.l10n
                                        .locationPermissionLaterAction(),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAllowLocation(BuildContext context) async {
    final result = await locationController.requestPermissionAndCapture();
    await PlanNotificationService.instance.requestPermissions();
    if (!context.mounted) {
      return;
    }

    switch (result.outcome) {
      case LocationPermissionOutcome.granted:
        _continue(context);
      case LocationPermissionOutcome.denied:
        if (!args.isRequired) {
          _continue(context);
        }
      case LocationPermissionOutcome.permanentlyDenied:
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
                        await locationController.openAppSettings();
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
        if (context.mounted && !args.isRequired) {
          _continue(context);
        }
    }
  }

  Future<void> _handleNotNow(BuildContext context) async {
    await locationController.deferPermission();
    if (context.mounted) {
      _continue(context);
    }
  }

  void _continue(BuildContext context) {
    if (args.returnToPrevious) {
      Navigator.maybePop(context, true);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      args.continueRoute ?? AppRoutes.publicHome,
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
