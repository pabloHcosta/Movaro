import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card.dart';

class CityHighlightSection extends StatelessWidget {
  const CityHighlightSection({
    required this.title,
    required this.cities,
    required this.citiesController,
    required this.onCityTap,
    required this.onFavoriteToggle,
    super.key,
  });

  final String title;
  final List<City> cities;
  final CitiesController citiesController;
  final ValueChanged<City> onCityTap;
  final ValueChanged<City> onFavoriteToggle;

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
              citiesController: citiesController,
              isFavorite: citiesController.isFavorite(city.id),
              onFavoriteToggle: () => onFavoriteToggle(city),
              onTap: () => onCityTap(city),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
