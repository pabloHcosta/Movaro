import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movaro_app/core/config/api_keys.dart';

class YouTubeVideo {
  const YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.publishedAt,
  });

  final String videoId;
  final String title;
  final String channelName;
  final String thumbnailUrl;
  final String publishedAt;

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? const {};
    final id = json['id'] as Map<String, dynamic>? ?? const {};
    final thumbnails =
        snippet['thumbnails'] as Map<String, dynamic>? ?? const {};
    final highThumb =
        thumbnails['high'] as Map<String, dynamic>? ??
        thumbnails['medium'] as Map<String, dynamic>? ??
        thumbnails['default'] as Map<String, dynamic>? ??
        const {};

    return YouTubeVideo(
      videoId: id['videoId'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      channelName: snippet['channelTitle'] as String? ?? '',
      thumbnailUrl: highThumb['url'] as String? ?? '',
      publishedAt: snippet['publishedAt'] as String? ?? '',
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
  String get youtubeAppUrl => 'youtube://www.youtube.com/watch?v=$videoId';
}

class YouTubeSearchResult {
  const YouTubeSearchResult({
    required this.videos,
    required this.queries,
    this.quotaExceeded = false,
    this.missingApiKey = false,
  });

  final List<YouTubeVideo> videos;
  final List<String> queries;
  final bool quotaExceeded;
  final bool missingApiKey;

  bool get hasInlineVideos => videos.isNotEmpty && !quotaExceeded && !missingApiKey;
}

class YouTubeService {
  YouTubeService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://www.googleapis.com/youtube/v3/search';
  static const _ttl = Duration(minutes: 30);
  static final Map<String, _YouTubeCacheEntry> _cache =
      <String, _YouTubeCacheEntry>{};

  final http.Client _client;

  static List<String> buildQueries(
    String cityName,
    String stateName, {
    required String languageCode,
  }) {
    return switch (languageCode) {
      'pt' => <String>[
        '$cityName $stateName morar brasileiros 2024',
        '$cityName $stateName vida real custo',
        '$cityName $stateName city life tour',
      ],
      'es' => <String>[
        '$cityName $stateName vivir argentinos 2024',
        '$cityName $stateName costo de vida real',
        '$cityName $stateName recorrido por la ciudad',
      ],
      _ => <String>[
        '$cityName $stateName move to brazil 2024',
        '$cityName $stateName real cost of living',
        '$cityName $stateName city life tour',
      ],
    };
  }

  Future<YouTubeSearchResult> searchVideos({
    required String cityId,
    required String cityName,
    required String stateName,
    required String languageCode,
  }) async {
    final cacheKey = '$cityId::$languageCode';
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.savedAt) < _ttl) {
      return cached.result;
    }

    final queries = buildQueries(
      cityName,
      stateName,
      languageCode: languageCode,
    );
    if (!ApiKeys.hasYoutubeApiKey) {
      final result = YouTubeSearchResult(
        videos: const <YouTubeVideo>[],
        queries: queries,
        missingApiKey: true,
      );
      _cache[cacheKey] = _YouTubeCacheEntry(
        result: result,
        savedAt: DateTime.now(),
      );
      return result;
    }

    final allVideos = <YouTubeVideo>[];
    var quotaExceeded = false;

    for (final query in queries.take(2)) {
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: <String, String>{
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': '4',
          'order': 'relevance',
          'relevanceLanguage': _relevanceLanguage(languageCode),
          'regionCode': _regionCode(languageCode),
          'key': ApiKeys.youtubeApiKey,
        },
      );

      final response = await _client.get(uri);
      if (response.statusCode == 403) {
        quotaExceeded = true;
        break;
      }
      if (response.statusCode != 200) {
        continue;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final items = decoded['items'] as List<dynamic>? ?? const <dynamic>[];
      allVideos.addAll(
        items
            .whereType<Map<String, dynamic>>()
            .map(YouTubeVideo.fromJson)
            .where((video) => video.videoId.isNotEmpty)
            .toList(growable: false),
      );
    }

    final seenIds = <String>{};
    final uniqueVideos = allVideos
        .where((video) => seenIds.add(video.videoId))
        .toList(growable: false);

    final result = YouTubeSearchResult(
      videos: quotaExceeded ? const <YouTubeVideo>[] : uniqueVideos,
      queries: queries,
      quotaExceeded: quotaExceeded,
    );
    _cache[cacheKey] = _YouTubeCacheEntry(
      result: result,
      savedAt: DateTime.now(),
    );
    return result;
  }

  static String _relevanceLanguage(String languageCode) {
    return switch (languageCode) {
      'pt' => 'pt',
      'es' => 'es',
      _ => 'en',
    };
  }

  static String _regionCode(String languageCode) {
    return switch (languageCode) {
      'pt' => 'BR',
      'es' => 'AR',
      _ => 'US',
    };
  }
}

class _YouTubeCacheEntry {
  const _YouTubeCacheEntry({
    required this.result,
    required this.savedAt,
  });

  final YouTubeSearchResult result;
  final DateTime savedAt;
}
