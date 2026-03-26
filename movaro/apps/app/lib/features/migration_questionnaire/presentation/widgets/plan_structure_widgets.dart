import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/visual_data_cards.dart';

class PlanSummaryCard extends StatelessWidget {
  const PlanSummaryCard({
    required this.label,
    required this.value,
    this.supporting,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final String? supporting;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final hasSupporting = supporting != null && supporting!.trim().isNotEmpty;
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
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSoftFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasSupporting) ...[
            const SizedBox(height: 8),
            ScoreBadge(label: supporting!, icon: icon, tint: AppColors.primary),
          ],
        ],
      ),
    );
  }
}

class PlanNextActionCard extends StatelessWidget {
  const PlanNextActionCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onTap,
    this.eyebrow,
    this.progressLabel,
    this.icon = Icons.arrow_forward_rounded,
    super.key,
  });

  final String? eyebrow;
  final String title;
  final String body;
  final String? progressLabel;
  final String actionLabel;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(22),
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroMiddle, AppColors.heroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      backgroundColor: const Color(0xB30B1320),
      borderColor: const Color(0x1AFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (eyebrow != null)
                _HeroPill(label: eyebrow!, icon: Icons.auto_awesome_rounded),
              if (progressLabel != null)
                _HeroPill(label: progressLabel!, icon: Icons.timeline_rounded),
            ],
          ),
          if (eyebrow != null || progressLabel != null)
            const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class PlanChecklistItem extends StatelessWidget {
  const PlanChecklistItem({
    required this.title,
    required this.body,
    required this.completed,
    required this.onTap,
    this.icon = Icons.checklist_rounded,
    super.key,
  });

  final String title;
  final String body;
  final bool completed;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedFor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed
                ? AppColors.success.withValues(alpha: 0.28)
                : AppColors.borderFor(context),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (completed ? AppColors.success : AppColors.primary)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                completed ? Icons.check_rounded : icon,
                size: 19,
                color: completed ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                height: 1.15,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusPill(completed: completed),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.3,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ChecklistActionButton(completed: completed),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final tint = completed ? AppColors.success : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Icon(
        completed ? Icons.check_rounded : Icons.arrow_forward_rounded,
        size: 16,
        color: tint,
      ),
    );
  }
}

class _ChecklistActionButton extends StatelessWidget {
  const _ChecklistActionButton({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    final tint = completed ? AppColors.success : AppColors.primary;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        completed ? Icons.check_rounded : Icons.arrow_outward_rounded,
        size: 18,
        color: tint,
      ),
    );
  }
}
