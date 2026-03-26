import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/application/services/city_image_catalog.dart';
import 'package:movaro_app/features/cities/application/services/places_photo_service.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

/// Pre-warms the Flutter image cache for [city] before navigation.
///
/// Uses the curated catalog URL if available, otherwise fetches the first
/// Places API photo. Silently ignores errors — [CityResolvedImage] handles
/// its own fallback chain if the image isn't cached.
Future<void> precacheCityImage(BuildContext context, City city) async {
  const headers = {'User-Agent': 'Movaro/1.0'};
  final primaryUrl = cityImageUrlFor(city.id);
  if (primaryUrl != null) {
    try {
      await precacheImage(NetworkImage(primaryUrl, headers: headers), context);
    } catch (_) {}
    return;
  }
  try {
    final result = await PlacesPhotoService().getPhotos(
      cityId: city.id,
      cityName: city.name,
      stateName: city.stateName,
    );
    final fallbackUrl = result.photos.isEmpty ? null : result.photos.first.url;
    if (fallbackUrl != null && context.mounted) {
      await precacheImage(NetworkImage(fallbackUrl, headers: headers), context);
    }
  } catch (_) {}
}

class CityImageBackdrop extends StatelessWidget {
  const CityImageBackdrop({
    required this.city,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.all(16),
    this.overlayOpacity = 0.84,
    super.key,
  });

  final City city;
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final topOverlayAlpha = (overlayOpacity - (isDark ? 0.16 : 0.26)).clamp(
      0.0,
      1.0,
    );
    final bottomOverlayAlpha = (overlayOpacity - (isDark ? 0.0 : 0.14)).clamp(
      0.0,
      1.0,
    );
    final ambientTint = isDark
        ? const Color(0xFF07101C).withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.06);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.heroStart.withValues(alpha: 0.95),
                    AppColors.heroMiddle.withValues(alpha: 0.9),
                    AppColors.heroEnd.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CityResolvedImage(
              city: city,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorWidget: const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF08111E).withValues(alpha: topOverlayAlpha),
                    const Color(
                      0xFF08111E,
                    ).withValues(alpha: bottomOverlayAlpha),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(color: ambientTint)),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class CityImageHeader extends StatelessWidget {
  const CityImageHeader({
    required this.city,
    this.height = 190,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
    this.child,
    super.key,
  });

  final City city;
  final double height;
  final BorderRadius borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final layers = <Widget>[
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    AppColors.heroStart,
                    AppColors.heroMiddle,
                    AppColors.heroEnd,
                  ]
                : const [
                    Color(0xFFE8F3FF),
                    Color(0xFFD9EBFF),
                    Color(0xFFC5E1FF),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      CityResolvedImage(
        city: city,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorWidget: _CityImageFallback(city: city),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF07111F).withValues(alpha: 0.18),
              const Color(0xFF07111F).withValues(alpha: 0.58),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
    if (child != null) {
      layers.add(child!);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(fit: StackFit.expand, children: layers),
      ),
    );
  }
}

class CityResolvedImage extends StatefulWidget {
  const CityResolvedImage({
    required this.city,
    required this.fit,
    required this.errorWidget,
    this.filterQuality = FilterQuality.low,
    this.placeholder,
    super.key,
  });

  final City city;
  final BoxFit fit;
  final Widget errorWidget;
  final FilterQuality filterQuality;
  final Widget? placeholder;

  @override
  State<CityResolvedImage> createState() => _CityResolvedImageState();
}

class _CityResolvedImageState extends State<CityResolvedImage> {
  static final PlacesPhotoService _photoService = PlacesPhotoService();
  static final Map<String, String?> _fallbackUrlCache = <String, String?>{};

  String? _activeUrl;
  Future<String?>? _fallbackFuture;
  bool _didPrimaryFail = false;

  @override
  void initState() {
    super.initState();
    _primeImageState();
  }

  @override
  void didUpdateWidget(covariant CityResolvedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city.id != widget.city.id) {
      _primeImageState();
    }
  }

  void _primeImageState() {
    _didPrimaryFail = false;
    _activeUrl = cityImageUrlFor(widget.city.id);
    _fallbackFuture = _activeUrl == null ? _loadFallbackUrl(widget.city) : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_activeUrl != null) {
      return Image.network(
        _activeUrl!,
        fit: widget.fit,
        headers: const {'User-Agent': 'Movaro/1.0'},
        filterQuality: widget.filterQuality,
        loadingBuilder: widget.placeholder == null
            ? null
            : (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return widget.placeholder!;
              },
        errorBuilder: (_, _, _) {
          if (!_didPrimaryFail) {
            _didPrimaryFail = true;
            _fallbackFuture = _loadFallbackUrl(widget.city);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _activeUrl = null;
                });
              }
            });
          }
          return widget.placeholder ?? widget.errorWidget;
        },
      );
    }

    final future = _fallbackFuture ?? _loadFallbackUrl(widget.city);
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        final fallbackUrl = snapshot.data;
        if (fallbackUrl == null || fallbackUrl.isEmpty) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              widget.placeholder != null) {
            return widget.placeholder!;
          }
          return widget.errorWidget;
        }

        return Image.network(
          fallbackUrl,
          fit: widget.fit,
          headers: const {'User-Agent': 'Movaro/1.0'},
          filterQuality: widget.filterQuality,
          loadingBuilder: widget.placeholder == null
              ? null
              : (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return widget.placeholder!;
                },
          errorBuilder: (_, _, _) => widget.errorWidget,
        );
      },
    );
  }

  Future<String?> _loadFallbackUrl(City city) async {
    final cached = _fallbackUrlCache[city.id];
    if (_fallbackUrlCache.containsKey(city.id)) {
      return cached;
    }

    final result = await _photoService.getPhotos(
      cityId: city.id,
      cityName: city.name,
      stateName: city.stateName,
    );
    final url = result.photos.isEmpty ? null : result.photos.first.url;
    _fallbackUrlCache[city.id] = url;
    return url;
  }
}

class _CityImageFallback extends StatelessWidget {
  const _CityImageFallback({required this.city});

  final City city;

  @override
  Widget build(BuildContext context) {
    final initials = city.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF163457), Color(0xFF2A5F9E), Color(0xFF8AC0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Center(
                child: Text(
                  initials.isEmpty
                      ? city.name.substring(0, 1).toUpperCase()
                      : initials,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
