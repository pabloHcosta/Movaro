import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';

class CopilotExchangeRatesRemoteDataSource {
  CopilotExchangeRatesRemoteDataSource({required AppEnvironment environment})
    : _networkClient = NetworkClient(environment: environment);

  final NetworkClient _networkClient;

  Future<Map<String, dynamic>> getCurrentRates() {
    return _networkClient.getJsonMap(
      '/api/v1/reference/exchange-rates/current',
    );
  }
}
