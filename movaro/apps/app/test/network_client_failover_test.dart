import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movaro_app/core/environment/api_source.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/core/network/network_exception.dart';

void main() {
  const environment = AppEnvironment(
    flavor: AppFlavor.production,
    environmentName: 'production',
    apiSource: ApiSource.local,
    apiBaseUrl: 'https://expired-local-tunnel.example',
    localApiBaseUrl: 'https://expired-local-tunnel.example',
    railwayApiBaseUrl: 'https://movaro-production.up.railway.app',
    appName: 'Movaro',
  );

  test('falls back to Railway when the local transport is invalid', () async {
    final visitedHosts = <String>[];
    final client = NetworkClient(
      environment: environment,
      httpClient: MockClient((request) async {
        visitedHosts.add(request.url.host);
        if (request.url.host == 'expired-local-tunnel.example') {
          return http.Response('<html>tunnel unavailable</html>', 502);
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'status': 'ok'},
          }),
          200,
        );
      }),
    );

    final result = await client.getJsonMap('/api/v1/health');

    expect(result, {'status': 'ok'});
    expect(visitedHosts, [
      'expired-local-tunnel.example',
      'movaro-production.up.railway.app',
    ]);
  });

  test('does not mask a structured API error with failover', () async {
    var requests = 0;
    final client = NetworkClient(
      environment: environment,
      httpClient: MockClient((request) async {
        requests += 1;
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {
              'code': 'INVALID_PROFILE',
              'message': 'The profile is invalid.',
              'userMessage': 'Revise suas respostas.',
              'status': 422,
            },
          }),
          422,
        );
      }),
    );

    await expectLater(
      client.postJsonMap('/api/v1/cities/recommendations', const {}),
      throwsA(isA<ApiException>()),
    );
    expect(requests, 1);
  });
}
