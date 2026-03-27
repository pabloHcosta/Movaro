import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';

class CityInsightsRemoteDataSource {
  CityInsightsRemoteDataSource({required AppEnvironment environment})
    : _networkClient = NetworkClient(environment: environment);

  final NetworkClient _networkClient;

  Future<List<dynamic>> getJsonList(String path) {
    return _networkClient.getJsonList(path);
  }
}
