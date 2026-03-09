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
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/question_option_widget.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/widgets/question_progress_indicator.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({required this.controller, super.key});

  final MigrationQuestionnaireController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final question = controller.currentQuestion;
        final l10n = context.l10n;

        return Scaffold(
          body: Stack(
            children: [
              const AmbientBackground(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
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
                            title: l10n.questionnairePageTitle,
                            onBack: () => Navigator.maybePop(context),
                          ),
                          const SizedBox(height: 20),
                          if (controller.isInitializing || question == null)
                            const Expanded(
                              child: SingleChildScrollView(
                                child: FormSkeleton(
                                  fieldCount: 4,
                                  compact: true,
                                ),
                              ),
                            )
                          else ...[
                            FrostedPanel(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  QuestionProgressIndicator(
                                    currentStep: controller.currentIndex + 1,
                                    totalSteps: controller.questions.length,
                                    label: l10n.questionProgress(
                                      controller.currentIndex + 1,
                                      controller.questions.length,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    l10n.questionnaireSupportText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSoftFor(context),
                                        ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    l10n.questionTitle(question.id),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (controller.isGeneratingPlan)
                              LoadingStateWidget(
                                label: l10n.generatePlanAction,
                                compact: true,
                              ),
                            if (controller.isGeneratingPlan)
                              const SizedBox(height: 12),
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (context, index) {
                                  final option = question.options[index];
                                  final selectedValue = controller.answerFor(
                                    question.id,
                                  );

                                  return QuestionOptionWidget(
                                    label: l10n.questionOptionLabel(
                                      question.id,
                                      option.value,
                                    ),
                                    isSelected: selectedValue == option.value,
                                    onTap: () => controller.selectAnswer(
                                      question.id,
                                      option.value,
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemCount: question.options.length,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FrostedPanel(
                              padding: const EdgeInsets.all(18),
                              borderRadius: BorderRadius.circular(28),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: controller.canGoBack
                                          ? controller.goBack
                                          : null,
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                      ),
                                      label: Text(l10n.backAction),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: FilledButton.icon(
                                      onPressed:
                                          controller.canGoNext &&
                                              !controller.isGeneratingPlan
                                          ? () async {
                                              final completed = await controller
                                                  .goNext();
                                              if (completed) {
                                                if (!context.mounted) {
                                                  return;
                                                }

                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  AppRoutes.migrationPlanResult,
                                                );
                                              }
                                            }
                                          : null,
                                      icon: Icon(
                                        controller.isLastQuestion
                                            ? Icons.auto_awesome_rounded
                                            : Icons.arrow_forward_rounded,
                                      ),
                                      label: Text(
                                        controller.isLastQuestion
                                            ? l10n.generatePlanAction
                                            : l10n.nextAction,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
