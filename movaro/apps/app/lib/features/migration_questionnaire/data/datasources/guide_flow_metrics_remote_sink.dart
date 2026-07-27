import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';

class GuideFlowMetricsRemoteSink implements GuideFlowMetricsSink {
  GuideFlowMetricsRemoteSink({
    required AppEnvironment environment,
    NetworkClient? networkClient,
  }) : _environment = environment,
       _networkClient =
           networkClient ?? NetworkClient(environment: environment);

  final AppEnvironment _environment;
  final NetworkClient _networkClient;

  @override
  Future<Set<String>> upload({
    required String installationToken,
    required List<GuideFlowUploadEvent> events,
  }) async {
    final response = await _networkClient.postJsonMap(
      '/api/v1/product-analytics/events',
      <String, dynamic>{
        'installationToken': installationToken,
        'appEnvironment': _environment.environmentName,
        'events': events
            .map(
              (event) => <String, dynamic>{
                'eventId': event.eventId,
                'eventName': event.metric.name,
                'occurredAt': event.occurredAt.toUtc().toIso8601String(),
                if (event.stepIndex != null) 'stepIndex': event.stepIndex,
              },
            )
            .toList(growable: false),
      },
    );
    if (response['accepted'] != true) {
      return const <String>{};
    }
    final ids = response['eventIds'];
    return ids is List<dynamic> ? ids.whereType<String>().toSet() : <String>{};
  }
}
