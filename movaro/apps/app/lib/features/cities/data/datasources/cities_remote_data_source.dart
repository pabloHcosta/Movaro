import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/json_response_cache.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/core/network/network_exception.dart';
import 'package:movaro_app/features/cities/data/datasources/cities_asset_fallback.dart';

class CitiesRemoteDataSource {
  CitiesRemoteDataSource({
    required AppEnvironment environment,
    JsonResponseCache? cache,
    CitiesAssetFallback? assetFallback,
  }) : _networkClient = NetworkClient(environment: environment),
       _cache = cache ?? JsonResponseCache(),
       _assetFallback = assetFallback ?? CitiesAssetFallback();

  final NetworkClient _networkClient;
  final JsonResponseCache _cache;
  final CitiesAssetFallback _assetFallback;

  Future<Map<String, dynamic>> postJsonMap(
    String path,
    Map<String, dynamic> body,
  ) {
    // Personalized recommendations deliberately have no local fallback. A
    // stale or different on-device ranking would create a second methodology.
    return _networkClient.postJsonMap(path, body);
  }

  Future<Map<String, dynamic>> getJsonMap(String path) async {
    try {
      final data = await _networkClient.getJsonMap(path);
      await _cache.write(path, data);
      return data;
    } on NetworkException {
      // Connectivity failure: try the last good payload, then the bundled
      // offline snapshot. Real API errors (ApiException) are not caught here
      // and still surface to the caller.
      final cached = await _cache.read(path);
      if (cached is Map<String, dynamic>) {
        return cached;
      }
      final asset = await _assetFallback.resolve(path);
      if (asset is Map<String, dynamic>) {
        return asset;
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getJsonList(String path) async {
    try {
      final data = await _networkClient.getJsonList(path);
      await _cache.write(path, data);
      return data;
    } on NetworkException {
      final cached = await _cache.read(path);
      if (cached is List<dynamic>) {
        return cached;
      }
      final asset = await _assetFallback.resolve(path);
      if (asset is List<dynamic>) {
        return asset;
      }
      rethrow;
    }
  }
}
