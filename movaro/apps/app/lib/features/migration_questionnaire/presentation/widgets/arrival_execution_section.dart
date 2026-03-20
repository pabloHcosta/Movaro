import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/arrival_execution_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class ArrivalExecutionSection extends StatelessWidget {
  const ArrivalExecutionSection({
    required this.plan,
    required this.completedItemIds,
    required this.onToggleItem,
    super.key,
  });

  final MigrationPlan plan;
  final Set<String> completedItemIds;
  final ValueChanged<String> onToggleItem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final checklist = ArrivalExecutionBuilder.build(l10n: l10n, plan: plan);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.arrivalExecutionSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            checklist.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _ProgressRow(
            label: l10n.readinessProgressLabel(
              completedItemIds.length,
              checklist.items.length,
            ),
            progress: checklist.items.isEmpty
                ? 0
                : completedItemIds.length / checklist.items.length,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 960;
              final medium = constraints.maxWidth >= 640;
              final columnWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : medium
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: columnWidth,
                    child: _StagePanel(
                      title: _stageTitle(
                        context,
                        ArrivalExecutionStage.firstWeek,
                      ),
                      badge: '07',
                      accent: AppColors.primary,
                      items: checklist.itemsFor(
                        ArrivalExecutionStage.firstWeek,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _StagePanel(
                      title: _stageTitle(
                        context,
                        ArrivalExecutionStage.firstMonth,
                      ),
                      badge: '30',
                      accent: AppColors.warning,
                      items: checklist.itemsFor(
                        ArrivalExecutionStage.firstMonth,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _StagePanel(
                      title: _stageTitle(
                        context,
                        ArrivalExecutionStage.firstQuarter,
                      ),
                      badge: '90',
                      accent: AppColors.success,
                      items: checklist.itemsFor(
                        ArrivalExecutionStage.firstQuarter,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _stageTitle(BuildContext context, ArrivalExecutionStage stage) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => switch (stage) {
        ArrivalExecutionStage.firstWeek =>
          'PRIMEIRA SEMANA — prioridade maxima',
        ArrivalExecutionStage.firstMonth => 'PRIMEIRO MES — consolidar a base',
        ArrivalExecutionStage.firstQuarter =>
          'PRIMEIROS 3 MESES — estabilizar a vida',
      },
      'es' => switch (stage) {
        ArrivalExecutionStage.firstWeek => 'PRIMERA SEMANA — prioridad maxima',
        ArrivalExecutionStage.firstMonth => 'PRIMER MES — consolidar la base',
        ArrivalExecutionStage.firstQuarter =>
          'PRIMEROS 3 MESES — estabilizar la vida',
      },
      _ => switch (stage) {
        ArrivalExecutionStage.firstWeek => 'FIRST WEEK — top priority',
        ArrivalExecutionStage.firstMonth => 'FIRST MONTH — build your base',
        ArrivalExecutionStage.firstQuarter => 'FIRST 3 MONTHS — stabilize life',
      },
    };
  }
}

class _StagePanel extends StatelessWidget {
  const _StagePanel({
    required this.title,
    required this.badge,
    required this.accent,
    required this.items,
    required this.completedItemIds,
    required this.onToggleItem,
  });

  final String title;
  final String badge;
  final Color accent;
  final List<ArrivalExecutionItem> items;
  final Set<String> completedItemIds;
  final ValueChanged<String> onToggleItem;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.surfaceFor(context),
      borderColor: AppColors.borderFor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: accent),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _ExecutionItemTile(
              item: items[i],
              accent: accent,
              completed: completedItemIds.contains(items[i].id),
              onToggle: () => onToggleItem(items[i].id),
            ),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ExecutionItemTile extends StatelessWidget {
  const _ExecutionItemTile({
    required this.item,
    required this.accent,
    required this.completed,
    required this.onToggle,
  });

  final ArrivalExecutionItem item;
  final Color accent;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed
                ? AppColors.success.withValues(alpha: 0.24)
                : accent.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (completed ? AppColors.success : accent).withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                completed ? Icons.check_rounded : item.icon,
                size: 19,
                color: completed ? AppColors.success : accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      height: 1.15,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (completed) ...[
                    const SizedBox(height: 4),
                    Text(
                      _doneLabel(context),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Checkbox.adaptive(
              value: completed,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  String _doneLabel(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'Feito ✓',
      'es' => 'Hecho ✓',
      _ => 'Done ✓',
    };
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSoftFor(context),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.surfaceMutedFor(context),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
