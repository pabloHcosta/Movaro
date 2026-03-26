import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';

class CityWeatherBadge extends StatefulWidget {
  const CityWeatherBadge({
    required this.cityId,
    required this.citiesController,
    this.compact = false,
    this.prominent = false,
    super.key,
  });

  final String cityId;
  final CitiesController citiesController;
  final bool compact;
  final bool prominent;

  @override
  State<CityWeatherBadge> createState() => _CityWeatherBadgeState();
}

class _CityWeatherBadgeState extends State<CityWeatherBadge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.citiesController.loadWeatherForCity(widget.cityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.citiesController,
      builder: (context, _) {
        final weather = widget.citiesController.weatherFor(widget.cityId);
        if (weather == null) {
          return const SizedBox.shrink();
        }

        final tint = _resolveTint(context, weather);
        final background = widget.compact
            ? _compactBackground(context, tint)
            : tint.withValues(alpha: AppColors.isDark(context) ? 0.16 : 0.12);
        final icon = _resolveIcon(weather);
        final textTheme = Theme.of(context).textTheme;

        if (widget.prominent) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: tint),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperatureCelsius.round()}°C',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    context.l10n.cityWeatherSummary(
                      weather.temperatureCelsius.round(),
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 12,
            vertical: widget.compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: tint.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: widget.compact ? 14 : 16, color: tint),
              const SizedBox(width: 6),
              Text(
                context.l10n.cityWeatherSummary(
                  weather.temperatureCelsius.round(),
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: widget.compact ? Colors.white : tint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _compactBackground(BuildContext context, Color tint) {
    if (AppColors.isDark(context)) {
      return tint.withValues(alpha: 0.32);
    }
    return tint.withValues(alpha: 0.92);
  }

  Color _resolveTint(BuildContext context, CityWeather weather) {
    if (weather.isDay == false) {
      return const Color(0xFF7A8CFF);
    }

    if (weather.temperatureCelsius >= 28) {
      return const Color(0xFFFF8C42);
    }

    if (weather.temperatureCelsius <= 14) {
      return const Color(0xFF3E8BFF);
    }

    return AppColors.primary;
  }

  IconData _resolveIcon(CityWeather weather) {
    final code = weather.weatherCode ?? -1;
    if (weather.isDay == false) {
      return Icons.nights_stay_rounded;
    }
    if (code >= 51 && code <= 67) {
      return Icons.water_drop_rounded;
    }
    if (code >= 71 && code <= 77) {
      return Icons.ac_unit_rounded;
    }
    if (code == 0 || code == 1) {
      return Icons.wb_sunny_rounded;
    }
    if (code >= 2 && code <= 48) {
      return Icons.cloud_rounded;
    }
    if (code >= 80 && code <= 99) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.thermostat_rounded;
  }
}
