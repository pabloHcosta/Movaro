import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';

class CitiesRemoteDataSource {
  CitiesRemoteDataSource({required AppEnvironment environment})
    : _networkClient = NetworkClient(environment: environment);

  final NetworkClient _networkClient;

  Future<Map<String, dynamic>> getJsonMap(String path) async {
    return _networkClient.getJsonMap(path);
  }

  Future<List<dynamic>> getJsonList(String path) async {
    return _networkClient.getJsonList(path);
  }
}
