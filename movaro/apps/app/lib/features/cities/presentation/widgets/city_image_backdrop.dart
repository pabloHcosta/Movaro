import 'dart:ui' show lerpDouble;

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

class CollapsibleCityHero extends StatelessWidget {
  const CollapsibleCityHero({
    required this.city,
    required this.scrollController,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.meta,
    this.maxHeightFactor = 0.38,
    this.minHeight = 140,
    this.maxHeight,
    super.key,
  });

  final City city;
  final ScrollController scrollController;
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? meta;
  final double maxHeightFactor;
  final double minHeight;
  final double? maxHeight;

  double _progress(double collapseRange) {
    if (!scrollController.hasClients || collapseRange <= 0) {
      return 0;
    }
    final raw = (scrollController.offset / collapseRange).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  Future<void> _toggle(BuildContext context, double collapseRange) async {
    if (!scrollController.hasClients) {
      return;
    }
    final progress = _progress(collapseRange);
    final target = progress < 0.68 ? collapseRange : 0.0;
    await scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.of(context).size.height;
    final resolvedMaxHeight =
        maxHeight ?? (viewportHeight * maxHeightFactor).clamp(240.0, 360.0);
    final collapseRange = (resolvedMaxHeight - minHeight).clamp(0.0, 240.0);

    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final progress = _progress(collapseRange);
        final currentHeight =
            lerpDouble(resolvedMaxHeight, minHeight, progress) ?? minHeight;
        final titleFontSize = lerpDouble(40, 31, progress) ?? 31;
        final subtitleOpacity = (1 - (progress * 2.4)).clamp(0.0, 1.0);
        final eyebrowOpacity = (1 - (progress * 2.0)).clamp(0.0, 1.0);
        final metaOpacity = (1 - (progress * 2.8)).clamp(0.0, 1.0);
        final imageScale = lerpDouble(1.0, 1.05, progress) ?? 1.0;
        final imageShift = lerpDouble(0, -18, progress) ?? 0;
        final bottomPadding = lerpDouble(20, 12, progress) ?? 12;
        final topOverlayAlpha = lerpDouble(0.10, 0.28, progress) ?? 0.28;
        final bottomOverlayAlpha = lerpDouble(0.74, 0.88, progress) ?? 0.88;
        final titleShadowAlpha = lerpDouble(0.18, 0.32, progress) ?? 0.32;
        final compactControlAlpha = lerpDouble(0.24, 0.42, progress) ?? 0.42;

        return SizedBox(
          height: currentHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(0, imageShift),
                child: Transform.scale(
                  scale: imageScale,
                  child: CityResolvedImage(
                    city: city,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorWidget: const SizedBox.shrink(),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: topOverlayAlpha),
                      Colors.black.withValues(alpha: bottomOverlayAlpha),
                    ],
                    stops: const [0.18, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: bottomPadding,
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (meta != null)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: metaOpacity,
                          child: IgnorePointer(
                            ignoring: metaOpacity < 0.05,
                            child: meta!,
                          ),
                        ),
                      if (meta != null) const SizedBox(height: 10),
                      if (eyebrow != null)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: eyebrowOpacity,
                          child: Text(
                            eyebrow!,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  letterSpacing: 0.4,
                                ),
                          ),
                        ),
                      if (eyebrow != null) const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: titleFontSize,
                              height: 0.98,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: titleShadowAlpha,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: subtitleOpacity,
                          child: IgnorePointer(
                            ignoring: subtitleOpacity < 0.05,
                            child: Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.84),
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 14,
                child: SafeArea(
                  top: false,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _toggle(context, collapseRange),
                      borderRadius: BorderRadius.circular(999),
                      child: Ink(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: compactControlAlpha,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Center(
                          child: AnimatedRotation(
                            duration: const Duration(milliseconds: 220),
                            turns: progress > 0.55 ? 0.5 : 0.0,
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
