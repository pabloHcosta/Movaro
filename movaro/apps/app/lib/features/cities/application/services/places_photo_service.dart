import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movaro_app/core/config/api_keys.dart';
import 'package:movaro_app/features/cities/application/services/city_image_catalog.dart';

class CityPhotoItem {
  const CityPhotoItem({
    required this.url,
    required this.label,
    required this.sourceLabel,
  });

  final String url;
  final String label;
  final String sourceLabel;
}

class CityPhotosResult {
  const CityPhotosResult({
    required this.photos,
    required this.attributionSource,
    this.usedFallback = false,
  });

  final List<CityPhotoItem> photos;
  final String attributionSource;
  final bool usedFallback;
}

class PlacesPhotoService {
  PlacesPhotoService({http.Client? client}) : _client = client ?? http.Client();

  static final Map<String, _PhotoCacheEntry> _cache =
      <String, _PhotoCacheEntry>{};
  static const _ttl = Duration(minutes: 30);

  final http.Client _client;

  Future<CityPhotosResult> getPhotos({
    required String cityId,
    required String cityName,
    required String stateName,
    String? placeId,
  }) async {
    final cached = _cache[cityId];
    if (cached != null && DateTime.now().difference(cached.savedAt) < _ttl) {
      return cached.result;
    }

    CityPhotosResult result;
    if (placeId != null && placeId.isNotEmpty && ApiKeys.hasGooglePlacesKey) {
      final googlePhotos = await _loadGooglePhotos(
        cityName: cityName,
        stateName: stateName,
        placeId: placeId,
      );
      if (googlePhotos.isNotEmpty) {
        result = CityPhotosResult(
          photos: googlePhotos,
          attributionSource: 'google_places',
        );
        _cache[cityId] = _PhotoCacheEntry(
          result: result,
          savedAt: DateTime.now(),
        );
        return result;
      }
    }

    result = CityPhotosResult(
      photos: await _loadPexelsPhotos(
        cityId: cityId,
        cityName: cityName,
        stateName: stateName,
      ),
      attributionSource: 'pexels',
      usedFallback: true,
    );
    _cache[cityId] = _PhotoCacheEntry(result: result, savedAt: DateTime.now());
    return result;
  }

  Future<List<CityPhotoItem>> _loadGooglePhotos({
    required String cityName,
    required String stateName,
    required String placeId,
  }) async {
    final detailsUri =
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json',
        ).replace(
          queryParameters: <String, String>{
            'place_id': placeId,
            'fields': 'photos',
            'key': ApiKeys.googlePlacesKey,
          },
        );

    final response = await _client.get(detailsUri);
    if (response.statusCode != 200) {
      return const <CityPhotoItem>[];
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final result = decoded['result'] as Map<String, dynamic>? ?? const {};
    final placeName = result['name'] as String?;
    final photos = result['photos'] as List<dynamic>? ?? const <dynamic>[];

    return photos
        .take(8)
        .map((photo) {
          final map = photo as Map<String, dynamic>;
          final reference = map['photo_reference'] as String? ?? '';
          return CityPhotoItem(
            url:
                'https://maps.googleapis.com/maps/api/place/photo'
                '?maxwidth=800&photo_reference=$reference&key=${ApiKeys.googlePlacesKey}',
            label: placeName ?? '',
            sourceLabel: 'Google Places',
          );
        })
        .toList(growable: false);
  }

  Future<List<CityPhotoItem>> _loadPexelsPhotos({
    required String cityId,
    required String cityName,
    required String stateName,
  }) async {
    if (!ApiKeys.hasPexelsApiKey) {
      return const <CityPhotoItem>[];
    }

    final queries = <String>[
      '$cityName $stateName Brazil city',
      '$cityName Brazil skyline',
      '$cityName Brazil downtown',
    ];

    final seenUrls = <String>{};
    final photos = <CityPhotoItem>[];
    final curatedImageUrl = cityImageUrlFor(cityId);

    if (curatedImageUrl != null) {
      seenUrls.add(curatedImageUrl);
      photos.add(
        CityPhotoItem(
          url: curatedImageUrl,
          label: cityName,
          sourceLabel: 'Wikimedia Commons',
        ),
      );
    }

    for (final query in queries) {
      final uri = Uri.parse('https://api.pexels.com/v1/search').replace(
        queryParameters: <String, String>{
          'query': query,
          'per_page': '6',
          'orientation': 'landscape',
        },
      );

      final response = await _client.get(
        uri,
        headers: <String, String>{'Authorization': ApiKeys.pexelsApiKey},
      );
      if (response.statusCode != 200) {
        continue;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items = decoded['photos'] as List<dynamic>? ?? const <dynamic>[];

      for (final item in items) {
        final map = item as Map<String, dynamic>;
        if (!_isRelevantPexelsPhoto(
          map,
          cityName: cityName,
          stateName: stateName,
        )) {
          continue;
        }
        final src = map['src'] as Map<String, dynamic>? ?? const {};
        final mediumUrl =
            (src['large'] as String?) ??
            (src['large2x'] as String?) ??
            (src['medium'] as String?) ??
            '';
        if (mediumUrl.isEmpty || !seenUrls.add(mediumUrl)) {
          continue;
        }

        final photographer = map['photographer'] as String? ?? '';
        photos.add(
          CityPhotoItem(
            url: mediumUrl,
            label: photographer.isEmpty ? '' : photographer,
            sourceLabel: 'Pexels',
          ),
        );
        if (photos.length >= 8) {
          return photos;
        }
      }
    }

    return photos;
  }

  bool _isRelevantPexelsPhoto(
    Map<String, dynamic> item, {
    required String cityName,
    required String stateName,
  }) {
    final alt = _normalizeText(item['alt'] as String? ?? '');
    if (alt.isEmpty) {
      return false;
    }

    const blockedTerms = <String>{
      'cat',
      'cats',
      'kitten',
      'dog',
      'dogs',
      'puppy',
      'horse',
      'bird',
      'cow',
      'sheep',
      'portrait',
      'person',
      'close up',
      'close-up',
    };
    if (blockedTerms.any(alt.contains)) {
      return false;
    }

    final cityPhrase = _normalizeText(cityName);
    final statePhrase = _normalizeText(stateName);
    if (alt.contains(cityPhrase)) {
      return true;
    }

    final cityTokens = cityPhrase
        .split(' ')
        .where((token) => token.length >= 3)
        .toList(growable: false);
    final hasAllCityTokens =
        cityTokens.isNotEmpty &&
        cityTokens.every((token) => alt.contains(token));
    if (hasAllCityTokens) {
      return true;
    }

    if (statePhrase.isNotEmpty &&
        alt.contains(statePhrase) &&
        (alt.contains('brazil') ||
            alt.contains('brasil') ||
            alt.contains('skyline') ||
            alt.contains('cityscape') ||
            alt.contains('downtown') ||
            alt.contains('urban'))) {
      return true;
    }

    return false;
  }

  String _normalizeText(String value) {
    final source = value.toLowerCase();
    const replacements = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    var normalized = source;
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    return normalized
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _PhotoCacheEntry {
  const _PhotoCacheEntry({required this.result, required this.savedAt});

  final CityPhotosResult result;
  final DateTime savedAt;
}
