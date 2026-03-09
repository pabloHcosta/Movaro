import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card.dart';

class CityHighlightSection extends StatelessWidget {
  const CityHighlightSection({
    required this.title,
    required this.cities,
    required this.highlightLabel,
    required this.onCityTap,
    super.key,
  });

  final String title;
  final List<City> cities;
  final String highlightLabel;
  final ValueChanged<City> onCityTap;

  @override
  Widget build(BuildContext context) {
    final surfaceMuted = AppColors.surfaceMutedFor(context);

    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${cities.length}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final city in cities) ...[
            CityCard(
              city: city,
              highlightLabel: highlightLabel,
              onTap: () => onCityTap(city),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
