import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/loading_state_widget.dart';
import 'package:movaro_app/core/widgets/skeletons.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class MigrationPlanSavePage extends StatefulWidget {
  const MigrationPlanSavePage({required this.controller, super.key});

  final MigrationQuestionnaireController controller;

  @override
  State<MigrationPlanSavePage> createState() => _MigrationPlanSavePageState();
}

class _MigrationPlanSavePageState extends State<MigrationPlanSavePage> {
  bool _isSaving = true;
  Object? _saveError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _savePlan());
  }

  Future<void> _savePlan() async {
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await widget.controller.saveGeneratedPlan();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saveError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppGlassHeader(
                        title: l10n.savePlanPageTitle,
                        onBack: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(height: 20),
                      if (_isSaving)
                        LoadingStateWidget(
                          label: l10n.savePlanPageTitle,
                          compact: true,
                        ),
                      if (_isSaving) const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedStateSwitcher(
                          child: _isSaving
                              ? const SingleChildScrollView(
                                  key: ValueKey('saving'),
                                  child: FormSkeleton(
                                    showSteps: false,
                                    fieldCount: 2,
                                    compact: true,
                                  ),
                                )
                              : _saveError != null
                              ? SingleChildScrollView(
                                  key: const ValueKey('error'),
                                  child: FrostedPanel(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.savePlanPageTitle,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _saveError.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.textSoftFor(
                                                  context,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(height: 20),
                                        FilledButton.icon(
                                          onPressed: _savePlan,
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                          ),
                                          label: Text(l10n.commonRetryAction),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  key: const ValueKey('success'),
                                  child: FrostedPanel(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.savePlanSuccessTitle,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.displaySmall,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.savePlanSuccessBody(
                                            widget.controller.savedPlans.length,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.textSoftFor(
                                                  context,
                                                ),
                                              ),
                                        ),
                                        const SizedBox(height: 24),
                                        FilledButton.icon(
                                          onPressed: () =>
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                AppRoutes.authenticatedHome,
                                                (route) => false,
                                              ),
                                          icon: const Icon(
                                            Icons.person_rounded,
                                          ),
                                          label: Text(l10n.goToProfileAction),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
}
