import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

class HousingDecisionSupportSection extends StatelessWidget {
  const HousingDecisionSupportSection({this.cityName, super.key});

  final String? cityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cityName == null
                ? l10n.housingDecisionSectionTitle
                : l10n.housingDecisionSectionTitleWithCity(cityName!),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            cityName == null
                ? l10n.housingDecisionSectionBody
                : l10n.housingDecisionSectionBodyWithCity(cityName!),
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
                  ? (constraints.maxWidth - 36) / 4
                  : medium
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _HousingSignalCard(
                      icon: Icons.key_outlined,
                      tint: AppColors.caution,
                      title: l10n.housingDecisionGuaranteesTitle,
                      body: l10n.housingDecisionGuaranteesBody,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _HousingSignalCard(
                      icon: Icons.home_work_outlined,
                      tint: AppColors.primary,
                      title: l10n.housingDecisionSoftLandingTitle,
                      body: l10n.housingDecisionSoftLandingBody,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _HousingSignalCard(
                      icon: Icons.folder_copy_outlined,
                      tint: AppColors.success,
                      title: l10n.housingDecisionProofPackTitle,
                      body: l10n.housingDecisionProofPackBody,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _HousingSignalCard(
                      icon: Icons.map_outlined,
                      tint: AppColors.secondary,
                      title: cityName == null
                          ? l10n.housingDecisionCityReadTitle
                          : l10n.housingDecisionCityReadTitleWithCity(
                              cityName!,
                            ),
                      body: cityName == null
                          ? l10n.housingDecisionCityReadBody
                          : l10n.housingDecisionCityReadBodyWithCity(cityName!),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedFor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderFor(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.housingDecisionSectionNote,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSoftFor(context),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HousingSignalCard extends StatelessWidget {
  const _HousingSignalCard({
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
              color: tint.withValues(
                alpha: AppColors.isDark(context) ? 0.16 : 0.10,
              ),
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
