import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movaro_app/core/config/api_keys.dart';

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

  static final Map<String, _PhotoCacheEntry> _cache = <String, _PhotoCacheEntry>{};
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
    if (placeId != null &&
        placeId.isNotEmpty &&
        ApiKeys.hasGooglePlacesKey) {
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
        _cache[cityId] = _PhotoCacheEntry(result: result, savedAt: DateTime.now());
        return result;
      }
    }

    result = CityPhotosResult(
      photos: _buildUnsplashPhotos(cityName: cityName, stateName: stateName),
      attributionSource: 'unsplash',
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
    final detailsUri = Uri.parse(
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

    return photos.take(8).map((photo) {
      final map = photo as Map<String, dynamic>;
      final reference = map['photo_reference'] as String? ?? '';
      return CityPhotoItem(
        url:
            'https://maps.googleapis.com/maps/api/place/photo'
            '?maxwidth=800&photo_reference=$reference&key=${ApiKeys.googlePlacesKey}',
        label: placeName ?? '',
        sourceLabel: 'Google Places',
      );
    }).toList(growable: false);
  }

  List<CityPhotoItem> _buildUnsplashPhotos({
    required String cityName,
    required String stateName,
  }) {
    final queries = <String>[
      '$cityName+$stateName+brazil+city',
      '$cityName+$stateName+brazil+urban',
      '$cityName+$stateName+brazil+architecture',
      '$cityName+$stateName+brazil+neighborhood',
      '$cityName+$stateName+brazil+coast',
      '$cityName+$stateName+brazil+downtown',
      '$cityName+$stateName+brazil+streets',
      '$cityName+$stateName+brazil+landscape',
    ];

    return List<CityPhotoItem>.generate(8, (index) {
      final query = queries[index % queries.length];
      return CityPhotoItem(
        url: 'https://source.unsplash.com/800x600/?$query&sig=$index',
        label: '',
        sourceLabel: 'Unsplash',
      );
    }, growable: false);
  }
}

class _PhotoCacheEntry {
  const _PhotoCacheEntry({
    required this.result,
    required this.savedAt,
  });

  final CityPhotosResult result;
  final DateTime savedAt;
}
