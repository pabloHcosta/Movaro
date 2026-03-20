import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityMapCard extends StatelessWidget {
  const CityMapCard({required this.city, super.key});

  final City city;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.cityDetailMapTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.cityDetailMapDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(28)),
            child: SizedBox(
              height: 280,
              child: CityInteractiveMap(city: city),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${city.name}, ${city.stateCode}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  city.stateName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSoftFor(context),
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

class CityInteractiveMap extends StatelessWidget {
  const CityInteractiveMap({required this.city, super.key});

  final City city;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(city.latitude, city.longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 11.5,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.movaro.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 44,
              height: 44,
              child: const _CityMapMarker(),
            ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _CityMapMarker extends StatelessWidget {
  const _CityMapMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x330071E3), blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: Icon(Icons.location_on, color: Colors.white, size: 22),
    );
  }
}
