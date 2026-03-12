import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_document_readiness_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class MigrationDocumentReadinessSection extends StatelessWidget {
  const MigrationDocumentReadinessSection({
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
    final checklist = MigrationDocumentReadinessBuilder.build(
      l10n: l10n,
      plan: plan,
    );

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.documentReadinessSectionTitle,
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
                    child: _PriorityPanel(
                      title: l10n.documentReadinessPriorityCritical,
                      badge: '01',
                      accent: AppColors.warning,
                      items: checklist.itemsFor(
                        MigrationDocumentReadinessPriority.critical,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _PriorityPanel(
                      title: l10n.documentReadinessPriorityPrepare,
                      badge: '02',
                      accent: AppColors.primary,
                      items: checklist.itemsFor(
                        MigrationDocumentReadinessPriority.prepare,
                      ),
                      completedItemIds: completedItemIds,
                      onToggleItem: onToggleItem,
                    ),
                  ),
                  SizedBox(
                    width: columnWidth,
                    child: _PriorityPanel(
                      title: l10n.documentReadinessPriorityArrival,
                      badge: '03',
                      accent: AppColors.success,
                      items: checklist.itemsFor(
                        MigrationDocumentReadinessPriority.arrival,
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
}

class _PriorityPanel extends StatelessWidget {
  const _PriorityPanel({
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
  final List<MigrationDocumentReadinessItem> items;
  final Set<String> completedItemIds;
  final ValueChanged<String> onToggleItem;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      backgroundColor: AppColors.isDark(context)
          ? const Color(0xCC111927)
          : Colors.white.withValues(alpha: 0.68),
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
            _DocumentItemTile(
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

class _DocumentItemTile extends StatelessWidget {
  const _DocumentItemTile({
    required this.item,
    required this.accent,
    required this.completed,
    required this.onToggle,
  });

  final MigrationDocumentReadinessItem item;
  final Color accent;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(item.risk);

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
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.4,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: Icons.warning_amber_rounded,
                        label: _riskLabel(context, item.risk),
                        color: riskColor,
                      ),
                      _MetaChip(
                        icon: Icons.schedule_outlined,
                        label: _reviewLabel(context, item.reviewMoment),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.documentReadinessSourceLabel(item.sourceLabel),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSoftFor(context),
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

  Color _riskColor(MigrationDocumentReadinessRisk risk) {
    switch (risk) {
      case MigrationDocumentReadinessRisk.blocking:
        return AppColors.danger;
      case MigrationDocumentReadinessRisk.caution:
        return AppColors.warning;
      case MigrationDocumentReadinessRisk.review:
        return AppColors.success;
    }
  }

  String _riskLabel(BuildContext context, MigrationDocumentReadinessRisk risk) {
    switch (risk) {
      case MigrationDocumentReadinessRisk.blocking:
        return context.l10n.documentReadinessRiskBlocking;
      case MigrationDocumentReadinessRisk.caution:
        return context.l10n.documentReadinessRiskCaution;
      case MigrationDocumentReadinessRisk.review:
        return context.l10n.documentReadinessRiskReview;
    }
  }

  String _reviewLabel(
    BuildContext context,
    MigrationDocumentReadinessReviewMoment reviewMoment,
  ) {
    switch (reviewMoment) {
      case MigrationDocumentReadinessReviewMoment.beforeBooking:
        return context.l10n.documentReadinessReviewBeforeBooking;
      case MigrationDocumentReadinessReviewMoment.closeToMove:
        return context.l10n.documentReadinessReviewCloseToMove;
      case MigrationDocumentReadinessReviewMoment.onArrival:
        return context.l10n.documentReadinessReviewOnArrival;
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
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
