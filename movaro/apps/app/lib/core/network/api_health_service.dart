import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/core/network/network_exception.dart';

class ApiHealthService {
  ApiHealthService({required AppEnvironment environment})
    : _networkClient = NetworkClient(environment: environment);

  final NetworkClient _networkClient;

  Future<void> check() async {
    final response = await _networkClient.getJsonMapWithHeaders(
      '/api/v1/health',
      headers: const {
        'x-movaro-health-check': 'startup',
      },
    );

    final status = response['status'];
    if (status != 'ok') {
      throw const NetworkException('api_health_unavailable');
    }
  }
}
