import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class HousingSoftLandingSection extends StatelessWidget {
  const HousingSoftLandingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.housingSoftLandingTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.housingSoftLandingBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 980;
              final medium = constraints.maxWidth >= 640;
              final cardWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : medium
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _LandingCard(
                      icon: Icons.apartment_outlined,
                      tint: AppColors.primary,
                      title: l10n.housingSoftLandingTemporaryTitle,
                      body: l10n.housingSoftLandingTemporaryBody,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _LandingCard(
                      icon: Icons.people_outline_rounded,
                      tint: AppColors.secondary,
                      title: l10n.housingSoftLandingDirectTitle,
                      body: l10n.housingSoftLandingDirectBody,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _LandingCard(
                      icon: Icons.shield_outlined,
                      tint: AppColors.caution,
                      title: l10n.housingSoftLandingGuaranteeTitle,
                      body: l10n.housingSoftLandingGuaranteeBody,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.housingSoftLandingSurvivalTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                _SurvivalLine(
                  icon: Icons.sim_card_outlined,
                  label: l10n.housingSoftLandingSurvivalChip,
                ),
                const SizedBox(height: 10),
                _SurvivalLine(
                  icon: Icons.badge_outlined,
                  label: l10n.housingSoftLandingSurvivalCpf,
                ),
                const SizedBox(height: 10),
                _SurvivalLine(
                  icon: Icons.local_grocery_store_outlined,
                  label: l10n.housingSoftLandingSurvivalLocation,
                ),
                const SizedBox(height: 10),
                _SurvivalLine(
                  icon: Icons.report_gmailerrorred_outlined,
                  label: l10n.housingSoftLandingSurvivalScam,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingCard extends StatelessWidget {
  const _LandingCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tint.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurvivalLine extends StatelessWidget {
  const _SurvivalLine({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
