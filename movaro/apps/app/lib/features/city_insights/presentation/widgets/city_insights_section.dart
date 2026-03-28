import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/features/cities/application/services/city_image_catalog.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/city_insights/application/city_insight_controller.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';

class CityInsightsSection extends StatefulWidget {
  const CityInsightsSection({
    required this.controller,
    required this.city,
    this.weather,
    this.goal,
    this.timeline,
    this.recommendationReasons = const [],
    super.key,
  });

  final CityInsightController controller;
  final City city;
  final CityWeather? weather;
  final String? goal;
  final String? timeline;
  final List<String> recommendationReasons;

  @override
  State<CityInsightsSection> createState() => _CityInsightsSectionState();
}

class _CityInsightsSectionState extends State<CityInsightsSection> {
  static const Duration _rotationInterval = Duration(seconds: 9);

  Timer? _rotationTimer;
  late final PageController _pageController;
  int _featuredIndex = 0;
  final Map<CityInsightTheme, List<CityInsightExplorePlaceEntity>>
  _featuredPlacesByTheme = {};
  final Map<String, List<CityInsightExplorePlaceEntity>> _featuredPlacesBySeed = {};
  final Set<CityInsightTheme> _loadingFeaturedThemes = <CityInsightTheme>{};
  final Set<String> _loadingFeaturedSeedKeys = <String>{};
  String? _lastFeaturedLocale;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _startRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_lastFeaturedLocale != locale) {
      _lastFeaturedLocale = locale;
      _queueFeaturedPlacesLoad();
    }
  }

  @override
  void didUpdateWidget(covariant CityInsightsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentLength = _featuredPool.length;
    if (currentLength == 0) {
      _featuredIndex = 0;
    } else if (_featuredIndex >= currentLength) {
      _featuredIndex = 0;
    }

    if (oldWidget.city.id != widget.city.id ||
        oldWidget.controller.items.length != widget.controller.items.length) {
      if (oldWidget.city.id != widget.city.id) {
        _featuredPlacesByTheme.clear();
        _featuredPlacesBySeed.clear();
        _loadingFeaturedThemes.clear();
        _loadingFeaturedSeedKeys.clear();
      }
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_featuredIndex);
      }
      _queueFeaturedPlacesLoad();
      _startRotation();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<_FeaturedSpotlight> get _featuredPool {
    final items = widget.controller.items;
    final normalizedGoal = widget.goal?.trim().toLowerCase() ?? '';

    final discoveryFirst = items
        .where(
          (item) => switch (item.theme) {
            CityInsightTheme.neighborhoods ||
            CityInsightTheme.beaches ||
            CityInsightTheme.nightlife ||
            CityInsightTheme.parks ||
            CityInsightTheme.cultureAndEvents ||
            CityInsightTheme.foodAndCafes ||
            CityInsightTheme.viewpoints => true,
            _ => false,
          },
        )
        .toList(growable: false);
    final workFirst = items
        .where((item) => item.type == CityInsightType.work)
        .toList(growable: false);
    final housingFirst = items
        .where((item) => item.type == CityInsightType.housing)
        .toList(growable: false);
    final aspirationFirst = items
        .where(
          (item) =>
              item.type == CityInsightType.motivation ||
              item.type == CityInsightType.lifestyle,
        )
        .toList(growable: false);
    final practicalFirst = items
        .where((item) => item.type == CityInsightType.practicalTip)
        .toList(growable: false);

    final ordered = <CityInsightEntity>[];
    if (normalizedGoal.contains('work') ||
        normalizedGoal.contains('job') ||
        normalizedGoal.contains('emple') ||
        normalizedGoal.contains('trabalh')) {
      ordered.addAll(discoveryFirst);
      ordered.addAll(workFirst);
      ordered.addAll(housingFirst);
      ordered.addAll(aspirationFirst);
    } else if (normalizedGoal.contains('study') ||
        normalizedGoal.contains('estud') ||
        normalizedGoal.contains('student')) {
      ordered.addAll(discoveryFirst);
      ordered.addAll(practicalFirst);
      ordered.addAll(aspirationFirst);
      ordered.addAll(housingFirst);
    } else {
      ordered.addAll(discoveryFirst);
      ordered.addAll(aspirationFirst);
      ordered.addAll(housingFirst);
      ordered.addAll(practicalFirst);
    }

    for (final item in items) {
      if (!ordered.any((candidate) => candidate.id == item.id)) {
        ordered.add(item);
      }
    }

    final spotlightPool = <_FeaturedSpotlight>[];
    final fallbackSpotlights = <_FeaturedSpotlight>[];
    final usedPlaceIds = <String>{};
    for (final item in ordered) {
      final highlights = item.placeHighlights
          .where((place) => place.trim().isNotEmpty)
          .toList(growable: false);
      final places = _resolvePlacesForInsight(
        item,
        highlights,
        usedPlaceIds,
      );
      if (places.isNotEmpty) {
        spotlightPool.addAll(
          places.map(
            (place) => _FeaturedSpotlight(insight: item, place: place),
          ),
        );
        continue;
      }

      if (highlights.isEmpty) {
        fallbackSpotlights.add(_FeaturedSpotlight(insight: item));
        continue;
      }

      for (final place in highlights.take(3)) {
        spotlightPool.add(_FeaturedSpotlight(insight: item, placeName: place));
      }
    }
    if (spotlightPool.isEmpty) {
      return _dedupeSpotlights(fallbackSpotlights);
    }
    if (fallbackSpotlights.isEmpty) {
      return _dedupeSpotlights(spotlightPool);
    }
    return _dedupeSpotlights(
      _mergeMapAndTipSpotlights(spotlightPool, fallbackSpotlights),
    );
  }

  List<_FeaturedSpotlight> _mergeMapAndTipSpotlights(
    List<_FeaturedSpotlight> mapSpotlights,
    List<_FeaturedSpotlight> tipSpotlights,
  ) {
    final merged = <_FeaturedSpotlight>[];
    var mapIndex = 0;
    var tipIndex = 0;

    while (mapIndex < mapSpotlights.length || tipIndex < tipSpotlights.length) {
      if (mapIndex < mapSpotlights.length) {
        merged.add(mapSpotlights[mapIndex]);
        mapIndex += 1;
      }
      if (mapIndex < mapSpotlights.length) {
        merged.add(mapSpotlights[mapIndex]);
        mapIndex += 1;
      }
      if (tipIndex < tipSpotlights.length) {
        merged.add(tipSpotlights[tipIndex]);
        tipIndex += 1;
      }
    }

    return merged;
  }

  List<_FeaturedSpotlight> _dedupeSpotlights(List<_FeaturedSpotlight> items) {
    final seen = <String>{};
    final unique = <_FeaturedSpotlight>[];
    for (final item in items) {
      final key = [
        item.place?.source ?? 'insight',
        item.effectivePlaceName ?? item.insight.title,
        item.place?.shortText ?? item.insight.shortText,
        item.place?.mapUrl ?? item.insight.theme?.name ?? 'none',
      ].map(_normalizeSpotlightKey).join('::');
      if (seen.add(key)) {
        unique.add(item);
      }
    }
    return unique;
  }

  List<CityInsightTheme> get _requestedFeaturedThemes => widget.controller.items
      .map((item) => item.theme)
      .whereType<CityInsightTheme>()
      .where(
        (theme) => switch (theme) {
          CityInsightTheme.neighborhoods ||
          CityInsightTheme.beaches ||
          CityInsightTheme.parks ||
          CityInsightTheme.nightlife ||
          CityInsightTheme.foodAndCafes ||
          CityInsightTheme.cultureAndEvents ||
          CityInsightTheme.viewpoints => true,
          CityInsightTheme.localRoutine => false,
        },
      )
      .toSet()
      .toList(growable: false);

  void _queueFeaturedPlacesLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _ensureFeaturedPlacesRequested();
    });
  }

  void _ensureFeaturedPlacesRequested() {
    final locale = Localizations.localeOf(context).languageCode;
    for (final theme in _requestedFeaturedThemes) {
      if (_featuredPlacesByTheme.containsKey(theme) ||
          _loadingFeaturedThemes.contains(theme)) {
        continue;
      }

      _loadingFeaturedThemes.add(theme);
      widget.controller
          .getExplorePlaces(
            cityId: widget.city.id,
            theme: theme,
            locale: locale,
          )
          .then((places) {
            if (!mounted) {
              return;
            }
            setState(() {
              _featuredPlacesByTheme[theme] = places;
            });
          })
          .catchError((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _featuredPlacesByTheme[theme] = const [];
            });
          })
          .whenComplete(() {
            _loadingFeaturedThemes.remove(theme);
          });
    }

    for (final item in widget.controller.items) {
      final theme = item.theme;
      if (theme == null) {
        continue;
      }
      for (final highlight in item.placeHighlights) {
        final seedPlace = highlight.trim();
        if (seedPlace.isEmpty) {
          continue;
        }
        final seedKey = _seedCacheKey(theme, seedPlace);
        if (_featuredPlacesBySeed.containsKey(seedKey) ||
            _loadingFeaturedSeedKeys.contains(seedKey)) {
          continue;
        }

        _loadingFeaturedSeedKeys.add(seedKey);
        widget.controller
            .getExplorePlaces(
              cityId: widget.city.id,
              theme: theme,
              locale: locale,
              seedPlace: seedPlace,
            )
            .then((places) {
              if (!mounted) {
                return;
              }
              setState(() {
                _featuredPlacesBySeed[seedKey] = places;
              });
            })
            .catchError((_) {
              if (!mounted) {
                return;
              }
              setState(() {
                _featuredPlacesBySeed[seedKey] = const [];
              });
            })
            .whenComplete(() {
              _loadingFeaturedSeedKeys.remove(seedKey);
            });
      }
    }
  }

  String _sectionTitle(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (locale) {
      'es' => 'Descubrí más sobre ${widget.city.name}',
      'en' => 'Discover more about ${widget.city.name}',
      _ => 'Descubra mais sobre ${widget.city.name}',
    };
  }

  String _tipEyebrow(BuildContext context, CityInsightEntity insight) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (insight.theme) {
      CityInsightTheme.neighborhoods => switch (locale) {
        'es' => 'Por dónde empezar',
        'en' => 'Where to begin',
        _ => 'Por onde começar',
      },
      CityInsightTheme.beaches => switch (locale) {
        'es' => 'Ritual de ciudad',
        'en' => 'City ritual',
        _ => 'Ritual da cidade',
      },
      CityInsightTheme.nightlife => switch (locale) {
        'es' => 'Noche local',
        'en' => 'Local nightlife',
        _ => 'Noite local',
      },
      CityInsightTheme.foodAndCafes => switch (locale) {
        'es' => 'Pequeños rituales',
        'en' => 'Small rituals',
        _ => 'Pequenos rituais',
      },
      CityInsightTheme.parks => switch (locale) {
        'es' => 'Respiro real',
        'en' => 'Real reset',
        _ => 'Respiro real',
      },
      CityInsightTheme.cultureAndEvents => switch (locale) {
        'es' => 'Ciudad viva',
        'en' => 'Living city',
        _ => 'Cidade viva',
      },
      CityInsightTheme.viewpoints => switch (locale) {
        'es' => 'Vista que prende',
        'en' => 'A view that sticks',
        _ => 'Vista que prende',
      },
      CityInsightTheme.localRoutine || null => switch (locale) {
        'es' => 'Dica rápida',
        'en' => 'Quick tip',
        _ => 'Dica rápida',
      },
    };
  }

  String _tipMoodCopy(BuildContext context, CityInsightEntity insight) {
    final locale = Localizations.localeOf(context).languageCode;
    if (insight.shortText.trim().isNotEmpty) {
      return _compactBannerCopy(insight.shortText, maxChars: 120);
    }
    return switch (locale) {
      'es' => 'Una pista corta para imaginar cómo se siente vivir la ciudad.',
      'en' => 'A short cue to imagine what living in the city could feel like.',
      _ => 'Uma pista curta para imaginar como pode ser viver a cidade.',
    };
  }

  String _tipDismissLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (locale) {
      'es' => 'Seguir descubriendo',
      'en' => 'Keep exploring',
      _ => 'Continuar descobrindo',
    };
  }

  List<CityInsightExplorePlaceEntity> _resolvePlacesForInsight(
    CityInsightEntity insight,
    List<String> highlights,
    Set<String> usedPlaceIds,
  ) {
    final theme = insight.theme;
    if (theme == null) {
      return const [];
    }

    final places = _featuredPlacesByTheme[theme] ?? const [];
    if (places.isEmpty) {
      return const [];
    }

    final matched = <CityInsightExplorePlaceEntity>[];
    if (highlights.isNotEmpty) {
      for (final highlight in highlights) {
        CityInsightExplorePlaceEntity? candidate =
            _resolveSeedPlaceForHighlight(theme, highlight, usedPlaceIds);
        candidate ??= _matchHighlightAgainstPlaces(
          highlight,
          places,
          usedPlaceIds,
        );
        if (candidate != null) {
          matched.add(candidate);
          usedPlaceIds.add(candidate.id);
        }
      }
    }

    if (matched.isNotEmpty) {
      return matched.take(3).toList(growable: false);
    }

    final realFallback = places
        .where(
          (place) =>
              !usedPlaceIds.contains(place.id) && place.source != 'template',
        )
        .take(2)
        .toList(growable: false);
    for (final place in realFallback) {
      usedPlaceIds.add(place.id);
    }
    return realFallback;
  }

  CityInsightExplorePlaceEntity? _resolveSeedPlaceForHighlight(
    CityInsightTheme theme,
    String highlight,
    Set<String> usedPlaceIds,
  ) {
    final seedPlaces = _featuredPlacesBySeed[_seedCacheKey(theme, highlight)] ??
        const <CityInsightExplorePlaceEntity>[];
    return _matchHighlightAgainstPlaces(highlight, seedPlaces, usedPlaceIds);
  }

  CityInsightExplorePlaceEntity? _matchHighlightAgainstPlaces(
    String highlight,
    List<CityInsightExplorePlaceEntity> places,
    Set<String> usedPlaceIds,
  ) {
    for (final place in places) {
      if (usedPlaceIds.contains(place.id)) {
        continue;
      }
      final normalizedHighlight = _normalizeSpotlightKey(highlight);
      final normalizedName = _normalizeSpotlightKey(place.name);
      final normalizedNeighborhood = _normalizeSpotlightKey(
        place.neighborhood ?? '',
      );
      if (normalizedName.contains(normalizedHighlight) ||
          normalizedHighlight.contains(normalizedName) ||
          (normalizedNeighborhood.isNotEmpty &&
              normalizedNeighborhood.contains(normalizedHighlight))) {
        return place;
      }
      if (place.source == 'template' &&
          normalizedName == normalizedHighlight) {
        return place;
      }
    }
    return null;
  }

  String _seedCacheKey(CityInsightTheme theme, String seedPlace) {
    return '${theme.name}::${_normalizeSpotlightKey(seedPlace)}';
  }

  String _normalizeSpotlightKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    if (_featuredPool.length <= 1) {
      return;
    }

    _rotationTimer = Timer.periodic(_rotationInterval, (_) {
      if (!mounted) {
        return;
      }
      _goToPage((_featuredIndex + 1) % _featuredPool.length);
    });
  }

  void _goToPage(int index) {
    if (_featuredPool.isEmpty) {
      return;
    }

    final safeIndex = index % _featuredPool.length;
    setState(() {
      _featuredIndex = safeIndex;
    });

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        safeIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _selectFeatured(int index) {
    if (_featuredPool.isEmpty) {
      return;
    }
    _goToPage(index);
    _startRotation();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final background = isDark ? const Color(0xFF101724) : Colors.white;
    final border = isDark ? const Color(0x1FFFFFFF) : const Color(0x140B1F33);
    final featuredPool = _featuredPool;
    final featuredSpotlight = featuredPool.isEmpty
        ? null
        : featuredPool[_featuredIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.controller.isLoading && !widget.controller.hasItems)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sectionTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => widget.controller.refresh(
                    cityId: widget.city.id,
                    goal: widget.goal,
                    timeline: widget.timeline,
                    locale: Localizations.localeOf(context).languageCode,
                  ),
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  splashRadius: 18,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PremiumBannerCarousel(
              city: widget.city,
              weather: widget.weather,
              goal: widget.goal,
              timeline: widget.timeline,
              insights: featuredPool,
              recommendationReasons: widget.recommendationReasons,
              currentIndex: featuredPool.isEmpty ? 0 : _featuredIndex,
              pageController: _pageController,
              onChanged: (index) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _featuredIndex = index;
                });
                _startRotation();
              },
              onSelectIndex: _selectFeatured,
              onTap: featuredSpotlight == null
                  ? null
                  : () => _openSpotlightFromBanner(
                      context,
                      featuredSpotlight,
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openSpotlightFromBanner(
    BuildContext context,
    _FeaturedSpotlight spotlight,
  ) {
    final exploreAction = _buildExploreAction(
      locale: Localizations.localeOf(context).languageCode,
      spotlight: spotlight,
    );
    if (spotlight.effectivePlaceName != null &&
        spotlight.effectivePlaceName!.trim().isNotEmpty) {
      return _openInsightInMaps(
        context,
        spotlight: spotlight,
        action: exploreAction,
      );
    }
    return _showTipSheet(context, spotlight);
  }

  _InsightExploreAction _buildExploreAction({
    required String locale,
    required _FeaturedSpotlight spotlight,
  }) {
    final insight = spotlight.insight;
    final hasPlace =
        spotlight.effectivePlaceName != null &&
        spotlight.effectivePlaceName!.trim().isNotEmpty;
    switch (insight.theme) {
      case CityInsightTheme.neighborhoods:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos abrir bairros reais com região, microdescrição e link direto para o mapa.',
          supportingEs:
              'Vamos abrir barrios reales con zona, microdescripción y enlace directo al mapa.',
          supportingEn:
              'We will open real neighborhoods with area, microcopy, and a direct map link.',
          theme: CityInsightTheme.neighborhoods,
        );
      case CityInsightTheme.beaches:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos buscar praias reais para você sentir a rotina de mar, fim de tarde e chegada.',
          supportingEs:
              'Vamos buscar playas reales para que sientas la rutina de mar, atardecer y llegada.',
          supportingEn:
              'We will pull real beaches so you can picture the sea, sunset, and arrival rhythm.',
          theme: CityInsightTheme.beaches,
        );
      case CityInsightTheme.parks:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos abrir parques e respiros reais com um atalho direto para mapa quando fizer sentido.',
          supportingEs:
              'Vamos abrir parques y respiros reales con acceso directo al mapa cuando valga la pena.',
          supportingEn:
              'We will open real parks and reset spots with a direct map shortcut when it fits.',
          theme: CityInsightTheme.parks,
        );
      case CityInsightTheme.nightlife:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos trazer bares e recortes de noite que ajudem a imaginar um sábado com cara de cidade viva.',
          supportingEs:
              'Vamos traer bares y recortes de noche que ayuden a imaginar un sábado con sensación de ciudad viva.',
          supportingEn:
              'We will bring bars and nightlife slices that help you picture a Saturday in a living city.',
          theme: CityInsightTheme.nightlife,
        );
      case CityInsightTheme.foodAndCafes:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos abrir cafés, encontros e lugares pequenos que ajudam a cidade a virar rotina possível.',
          supportingEs:
              'Vamos abrir cafés, encuentros y lugares pequeños que ayudan a que la ciudad se vuelva rutina posible.',
          supportingEn:
              'We will open cafes, meeting spots, and small places that help the city feel like a possible routine.',
          theme: CityInsightTheme.foodAndCafes,
        );
      case CityInsightTheme.cultureAndEvents:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos abrir museus, teatros e lugares culturais reais para reforçar a sensação de cidade viva.',
          supportingEs:
              'Vamos abrir museos, teatros y lugares culturales reales para reforzar la sensación de ciudad viva.',
          supportingEn:
              'We will open real museums, theaters, and cultural places to reinforce the feeling of a living city.',
          theme: CityInsightTheme.cultureAndEvents,
        );
      case CityInsightTheme.viewpoints:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos abrir mirantes e vistas reais que ajudam a visualizar o sonho da cidade em detalhes.',
          supportingEs:
              'Vamos abrir miradores y vistas reales que ayudan a visualizar el sueño de la ciudad en detalle.',
          supportingEn:
              'We will open real viewpoints and vistas that help you picture the city dream in detail.',
          theme: CityInsightTheme.viewpoints,
        );
      case CityInsightTheme.localRoutine:
      case null:
        return _exploreAction(
          locale: locale,
          labelPt: hasPlace ? 'Abrir no mapa' : 'Ver dica',
          labelEs: hasPlace ? 'Abrir en mapa' : 'Ver dica',
          labelEn: hasPlace ? 'Open in maps' : 'See tip',
          supportingPt:
              'Vamos abrir uma seleção de lugares reais para transformar curiosidade em sensação de chegada.',
          supportingEs:
              'Vamos abrir una selección de lugares reales para transformar curiosidad en sensación de llegada.',
          supportingEn:
              'We will open a real selection of places to turn curiosity into a feeling of arrival.',
          theme: CityInsightTheme.localRoutine,
        );
    }
  }

  _InsightExploreAction _exploreAction({
    required String locale,
    required String labelPt,
    required String labelEs,
    required String labelEn,
    required String supportingPt,
    required String supportingEs,
    required String supportingEn,
    required CityInsightTheme theme,
  }) {
    return _InsightExploreAction(
      label: switch (locale) {
        'es' => labelEs,
        'en' => labelEn,
        _ => labelPt,
      },
      supportingText: switch (locale) {
        'es' => supportingEs,
        'en' => supportingEn,
        _ => supportingPt,
      },
      theme: theme,
    );
  }

  Future<void> _openInsightInMaps(
    BuildContext context, {
    required _FeaturedSpotlight spotlight,
    required _InsightExploreAction action,
  }) async {
    final insight = spotlight.insight;
    final seedPlace = spotlight.place?.name ?? spotlight.effectivePlaceName;
    final query = _buildMapsQuery(
      theme: action.theme,
      cityName: insight.cityName,
      seedPlace: seedPlace,
    );
    await _openMapsSearch(query);
  }

  Future<void> _showTipSheet(
    BuildContext context,
    _FeaturedSpotlight spotlight,
  ) {
    final insight = spotlight.insight;
    final imageUrl = spotlight.imageUrl ?? cityImageUrlFor(widget.city.id);
    final isDark = AppColors.isDark(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101724) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0x1FFFFFFF)
                    : const Color(0x140B1F33),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _TipSheetFallbackVisual(
                            isDark: isDark,
                          ),
                        )
                      else
                        _TipSheetFallbackVisual(isDark: isDark),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.black.withValues(alpha: 0.26),
                              Colors.black.withValues(alpha: 0.62),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    _tipEyebrow(sheetContext, insight),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => Navigator.of(sheetContext).pop(),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(36, 36),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              _compactBannerCopy(insight.title, maxChars: 54),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(sheetContext).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    height: 0.98,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _tipMoodCopy(sheetContext, insight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(sheetContext).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _compactBannerCopy(insight.content, maxChars: 260),
                        style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: isDark
                              ? const Color(0xFFCDD7E5)
                              : const Color(0xFF4F6073),
                        ),
                      ),
                      if (insight.placeHighlights.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: insight.placeHighlights
                              .take(4)
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF182230)
                                        : const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0x1FFFFFFF)
                                          : const Color(0x120B1F33),
                                    ),
                                  ),
                                  child: Text(
                                    item,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark
                                ? const Color(0xFFE8EEF6)
                                : const Color(0xFF102030),
                            foregroundColor: isDark
                                ? const Color(0xFF102030)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(_tipDismissLabel(sheetContext)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipSheetFallbackVisual extends StatelessWidget {
  const _TipSheetFallbackVisual({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1C2B3A), Color(0xFF173F4F)]
              : const [Color(0xFFDCE8F2), Color(0xFFD6E5DF)],
        ),
      ),
    );
  }
}

class _FeaturedSpotlight {
  const _FeaturedSpotlight({
    required this.insight,
    this.place,
    this.placeName,
  });

  final CityInsightEntity insight;
  final CityInsightExplorePlaceEntity? place;
  final String? placeName;

  String? get effectivePlaceName => place?.name ?? placeName;
  String? get imageUrl => place?.imageUrl ?? insight.imageUrl;
}

class _InsightExploreAction {
  const _InsightExploreAction({
    required this.label,
    required this.supportingText,
    required this.theme,
  });

  final String label;
  final String supportingText;
  final CityInsightTheme theme;
}

class _PremiumBannerCarousel extends StatelessWidget {
  const _PremiumBannerCarousel({
    required this.city,
    required this.weather,
    required this.goal,
    required this.timeline,
    required this.insights,
    required this.recommendationReasons,
    required this.currentIndex,
    required this.pageController,
    required this.onChanged,
    required this.onSelectIndex,
    this.onTap,
  });

  final City city;
  final CityWeather? weather;
  final String? goal;
  final String? timeline;
  final List<_FeaturedSpotlight> insights;
  final List<String> recommendationReasons;
  final int currentIndex;
  final PageController pageController;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppColors.isDark(context);
    final surface = isDark ? const Color(0xFF141B22) : Colors.white;
    final border = isDark ? const Color(0x1FFFFFFF) : const Color(0x120B1F33);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: isDark ? const Color(0xFFF4F7FB) : const Color(0xFF102030),
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.05,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 138,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: insights.isEmpty ? 1 : insights.length,
                      onPageChanged: onChanged,
                      itemBuilder: (context, index) {
                        if (insights.isEmpty) {
                          return _BannerSlide(
                            imageUrl: cityImageUrlFor(city.id),
                            title: _headline(context),
                            subtitle: _fallbackNarrative(context),
                            ctaLabel: context.l10n.cityInsightsExploreAction,
                            onPressed: onTap,
                            titleStyle: titleStyle,
                            isDark: isDark,
                          );
                        }

                        final spotlight = insights[index];
                        final insight = spotlight.insight;
                        final title = _buildSpotlightTitle(
                          context,
                          insight: insight,
                          placeName: spotlight.effectivePlaceName,
                          place: spotlight.place,
                        );
                        final subtitle = _buildSpotlightSubtitle(
                          context,
                          insight: insight,
                          placeName: spotlight.effectivePlaceName,
                          place: spotlight.place,
                        );

                        return _BannerSlide(
                          imageUrl:
                              spotlight.imageUrl ?? cityImageUrlFor(city.id),
                          title: title,
                          subtitle: subtitle,
                          ctaLabel: _carouselCtaLabel(context, spotlight),
                          onPressed: onTap,
                          titleStyle: titleStyle,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                  if (insights.length > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        insights.length,
                        (index) => GestureDetector(
                          onTap: () => onSelectIndex(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: EdgeInsets.only(
                              right: index == insights.length - 1 ? 0 : 6,
                            ),
                            width: index == currentIndex ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: index == currentIndex
                                  ? (isDark
                                      ? const Color(0xFFF4F7FB)
                                      : const Color(0xFF17283A))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.24)
                                      : const Color(0x3317283A)),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _headline(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final normalizedGoal = goal?.trim().toLowerCase() ?? '';

    if (normalizedGoal.contains('work') ||
        normalizedGoal.contains('job') ||
        normalizedGoal.contains('emple') ||
        normalizedGoal.contains('trabalh')) {
      return switch (locale) {
        'es' => '${city.name} puede ser tu mejor base para empezar',
        'en' => '${city.name} can be your best base to start',
        _ => '${city.name} pode ser sua melhor base para começar',
      };
    }

    if (normalizedGoal.contains('study') ||
        normalizedGoal.contains('estud') ||
        normalizedGoal.contains('student')) {
      return switch (locale) {
        'es' => '${city.name} ayuda a imaginar una llegada más leve',
        'en' => '${city.name} makes a lighter arrival easier to picture',
        _ => '${city.name} ajuda a imaginar uma chegada mais leve',
      };
    }

    return switch (locale) {
      'es' => '${city.name} empieza a sentirse como tu próximo capítulo',
      'en' => '${city.name} is starting to feel like your next chapter',
      _ => '${city.name} começa a parecer seu próximo capítulo',
    };
  }

  String _fallbackNarrative(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return switch (locale) {
      'es' =>
        'Lugares reales y señales aspiracionales para reforzar tu deseo de vivir la ciudad.',
      'en' =>
        'Real places and aspirational cues to reinforce your desire to live in the city.',
      _ =>
        'Lugares reais e sinais aspiracionais para reforçar seu desejo de viver a cidade.',
    };
  }

  String _buildSpotlightTitle(
    BuildContext context, {
    required CityInsightEntity insight,
    required String? placeName,
    CityInsightExplorePlaceEntity? place,
  }) {
    if (place != null && place.name.trim().isNotEmpty) {
      return _compactBannerCopy(place.name, maxChars: 30);
    }
    if (placeName == null || placeName.trim().isEmpty) {
      return _compactBannerCopy(insight.title, maxChars: 34);
    }
    return _compactBannerCopy(placeName, maxChars: 30);
  }

  String _buildSpotlightSubtitle(
    BuildContext context, {
    required CityInsightEntity insight,
    required String? placeName,
    CityInsightExplorePlaceEntity? place,
  }) {
    if ((insight.placeHighlights.length <= 1) && insight.shortText.trim().isNotEmpty) {
      return _compactBannerCopy(insight.shortText, maxChars: 92);
    }
    if (place != null) {
      final location = [place.neighborhood, place.region]
          .where((value) => value != null && value.trim().isNotEmpty)
          .join(' • ');
      final baseText = place.shortText.trim().isNotEmpty
          ? place.shortText
          : insight.shortText;
      final fullText = location.isEmpty ? baseText : '$baseText • $location';
      return _compactBannerCopy(fullText, maxChars: 92);
    }
    if (placeName == null || placeName.trim().isEmpty) {
      return _compactBannerCopy(insight.shortText, maxChars: 68);
    }

    final locale = Localizations.localeOf(context).languageCode;
    switch (insight.theme) {
      case CityInsightTheme.beaches:
        return switch (locale) {
          'es' => 'Playa conocida por su clima de llegada y final de tarde.',
          'en' => 'A beach known for arrival energy and late-day atmosphere.',
          _ => 'Praia conhecida pelo clima de chegada e fim de tarde.',
        };
      case CityInsightTheme.neighborhoods:
        return switch (locale) {
          'es' => 'Buen recorte para imaginar cómo empieza la vida real ahí.',
          'en' => 'A strong place to picture how real life there could begin.',
          _ => 'Bom recorte para imaginar como a vida real pode começar ali.',
        };
      case CityInsightTheme.nightlife:
        return switch (locale) {
          'es' => 'Punto conocido por movimiento, encuentro y noche viva.',
          'en' => 'Known for movement, people, and a lively night rhythm.',
          _ => 'Lugar conhecido por movimento, encontro e noite viva.',
        };
      case CityInsightTheme.foodAndCafes:
        return switch (locale) {
          'es' => 'Parada buena para sentir la ciudad fuera del plan.',
          'en' => 'A good stop to feel the city beyond the plan.',
          _ => 'Boa parada para sentir a cidade fora do plano.',
        };
      case CityInsightTheme.parks:
        return switch (locale) {
          'es' => 'Espacio que muestra el lado de la ciudad que respira mejor.',
          'en' => 'A place that shows the side of the city that breathes better.',
          _ => 'Espaco que mostra o lado da cidade que respira melhor.',
        };
      case CityInsightTheme.cultureAndEvents:
        return switch (locale) {
          'es' => 'Buen punto para sentir el lado cultural de la ciudad.',
          'en' => 'A strong entry point into the city cultural rhythm.',
          _ => 'Bom ponto para sentir o lado cultural da cidade.',
        };
      case CityInsightTheme.viewpoints:
        return switch (locale) {
          'es' => 'Vista que ayuda a entender por qué tanta gente sueña con la ciudad.',
          'en' => 'A view that helps explain why people dream about this city.',
          _ => 'Vista que ajuda a entender por que tanta gente sonha com a cidade.',
        };
      case CityInsightTheme.localRoutine:
      case null:
        return switch (locale) {
          'es' => 'Dica rápida para transformar curiosidad en sensación de llegada.',
          'en' => 'A quick tip that turns curiosity into a sense of arrival.',
          _ => 'Dica rapida para transformar curiosidade em sensacao de chegada.',
        };
    }
  }
}

String _carouselCtaLabel(BuildContext context, _FeaturedSpotlight spotlight) {
  final locale = Localizations.localeOf(context).languageCode;
  final isMap =
      spotlight.effectivePlaceName != null &&
      spotlight.effectivePlaceName!.trim().isNotEmpty;
  return switch (locale) {
    'es' => isMap ? 'Abrir en mapa' : 'Ver dica',
    'en' => isMap ? 'Open in maps' : 'See tip',
    _ => isMap ? 'Abrir no mapa' : 'Ver dica',
  };
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onPressed,
    required this.titleStyle,
    required this.isDark,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback? onPressed;
  final TextStyle? titleStyle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark
        ? const Color(0xFFB8C4D1)
        : const Color(0xFF5B6B79);

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 92,
            height: double.infinity,
            child: imageUrl == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF213247), Color(0xFF1C4250)]
                            : const [Color(0xFFD7E5F1), Color(0xFFC9DDD9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  )
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [Color(0xFF213247), Color(0xFF1C4250)]
                              : const [Color(0xFFD7E5F1), Color(0xFFC9DDD9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _compactBannerCopy(title, maxChars: 34),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _compactBannerCopy(subtitle, maxChars: 92),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      fontSize: 12,
                      height: 1.22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: onPressed,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    ctaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _compactBannerCopy(String text, {required int maxChars}) {
  final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.length <= maxChars) {
    return normalized;
  }

  final candidate = normalized.substring(0, maxChars);
  final lastBreak = candidate.lastIndexOf(RegExp(r'[\s,.;:]'));
  final safe = lastBreak > maxChars * 0.55
      ? candidate.substring(0, lastBreak)
      : candidate;
  return '${safe.trimRight()}…';
}

String _buildMapsQuery({
  required CityInsightTheme theme,
  required String cityName,
  String? seedPlace,
}) {
  if (seedPlace != null && seedPlace.trim().isNotEmpty) {
    return '$seedPlace, $cityName';
  }

  switch (theme) {
    case CityInsightTheme.neighborhoods:
      return 'melhores bairros em $cityName';
    case CityInsightTheme.beaches:
      return 'melhores praias em $cityName';
    case CityInsightTheme.parks:
      return 'parques em $cityName';
    case CityInsightTheme.nightlife:
      return 'bares e vida noturna em $cityName';
    case CityInsightTheme.foodAndCafes:
      return 'cafes e restaurantes em $cityName';
    case CityInsightTheme.cultureAndEvents:
      return 'museus teatros e cultura em $cityName';
    case CityInsightTheme.viewpoints:
      return 'mirantes em $cityName';
    case CityInsightTheme.localRoutine:
      return 'lugares para conhecer em $cityName';
  }
}

Future<void> _openMapsSearch(String query) async {
  final encodedQuery = Uri.encodeComponent(query);

  if (Platform.isIOS) {
    final googleMapsUri = Uri.parse('comgooglemaps://?q=$encodedQuery');
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
      return;
    }

    final appleMapsUri = Uri.parse('https://maps.apple.com/?q=$encodedQuery');
    await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
    return;
  }

  final geoUri = Uri.parse('geo:0,0?q=$encodedQuery');
  if (await canLaunchUrl(geoUri)) {
    await launchUrl(geoUri);
    return;
  }

  final googleMapsWebUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
  );
  await launchUrl(googleMapsWebUri, mode: LaunchMode.externalApplication);
}
