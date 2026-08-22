import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movaro_app/core/environment/api_source.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/environment/app_flavor.dart';
import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/info/application/quick_guide_answer_service.dart';
import 'package:movaro_app/features/info/domain/entities/quick_guide_answer.dart';

void main() {
  const environment = AppEnvironment(
    flavor: AppFlavor.production,
    environmentName: 'test',
    apiSource: ApiSource.railway,
    apiBaseUrl: 'https://api.movaro.example',
    localApiBaseUrl: '',
    railwayApiBaseUrl: 'https://api.movaro.example',
    appName: 'Movaro Test',
  );

  test('parses the structured quick-guide response', () async {
    late Map<String, dynamic> requestBody;
    final networkClient = NetworkClient(
      environment: environment,
      httpClient: MockClient((request) async {
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'entryId': 'education-basics',
              'resolutionId': 'quick-help-resolution-test',
              'topic': 'education',
              'question': 'Como matricular meu filho?',
              'answer': 'Procure a rede de ensino responsável pelo endereço.',
              'coverage': 'conditional',
              'coverageReason': 'A aplicação depende da rede de ensino local.',
              'reviewedAt': '2026-08-18',
              'expiresAt': '2027-02-18',
              'context': {
                'originCountry': 'argentina',
                'destinationCountry': 'brasil',
                'cityId': 'curitiba',
              },
              'resolvedIntents': ['education.basic_enrollment'],
              'sections': [
                {
                  'intentId': 'education.basic_enrollment',
                  'topic': 'education',
                  'title': 'Matrícula escolar',
                  'answer':
                      'Procure a rede de ensino responsável pelo endereço.',
                  'coverage': 'conditional',
                  'claimIds': ['education-network'],
                },
              ],
              'steps': [
                {'id': 'basic-1', 'label': 'Confirme a rede do endereço.'},
              ],
              'nextSteps': ['Peça a lista atual de documentos.'],
              'fallbackPath': ['Peça a orientação por escrito.'],
              'decisionTitle': 'Caminho recomendado',
              'followUpQuestion': {
                'id': 'education-level',
                'contextKey': 'educationLevel',
                'prompt': 'Você quer escola ou universidade?',
                'options': [
                  {'value': 'basic', 'label': 'Escola'},
                  {'value': 'university', 'label': 'Universidade'},
                ],
              },
              'actions': <Map<String, String>>[],
              'caveats': <String>[],
              'claims': [
                {
                  'id': 'education-network',
                  'text': 'Procure a rede de ensino responsável pelo endereço.',
                  'status': 'conditional',
                  'evidenceIds': ['mec-basic-education'],
                },
              ],
              'evidence': [
                {
                  'id': 'mec-basic-education',
                  'title': 'Educação básica',
                  'publisher': 'Ministério da Educação',
                  'url': 'https://www.gov.br/mec/pt-br/assuntos/eb',
                  'checkedAt': '2026-08-18',
                  'validUntil': '2027-02-18',
                  'scope': 'Visão federal da educação básica.',
                },
              ],
              'trust': {
                'status': 'conditional',
                'reason': 'A aplicação depende da rede de ensino local.',
                'evidenceCoverage': 1,
                'freshness': 'current',
              },
              'recovery': {
                'reason': 'partial_coverage',
                'message': 'Tente uma pergunta revisada.',
                'suggestions': [
                  {
                    'id': 'education-school',
                    'topic': 'education',
                    'question': 'Como funciona a escola pública?',
                  },
                ],
              },
            },
          }),
          200,
        );
      }),
    );

    final answer = await QuickGuideAnswerService(client: networkClient).resolve(
      question: 'Como matricular meu filho?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      cityId: 'curitiba',
      locale: 'pt_BR',
      answers: const {'educationLevel': 'basic'},
    );

    expect(answer.coverage, QuickGuideCoverage.conditional);
    expect(answer.claims.single.evidenceIds, ['mec-basic-education']);
    expect(answer.trust.evidenceCoverage, 1);
    expect(answer.trust.freshness, QuickGuideFreshness.current);
    expect(answer.resolvedIntents, ['education.basic_enrollment']);
    expect(answer.sections.single.title, 'Matrícula escolar');
    expect(answer.steps.single.label, 'Confirme a rede do endereço.');
    expect(answer.nextSteps.single, 'Peça a lista atual de documentos.');
    expect(answer.fallbackPath.single, 'Peça a orientação por escrito.');
    expect(answer.followUpQuestion?.options, hasLength(2));
    expect(answer.sources.single.publisher, 'Ministério da Educação');
    expect(answer.actions, isEmpty);
    expect(answer.recovery?.reason, 'partial_coverage');
    expect(
      answer.recovery?.suggestions.single.question,
      'Como funciona a escola pública?',
    );
    expect(requestBody['locale'], 'pt');
    expect(requestBody['highlightedCityId'], 'curitiba');
    expect(requestBody['answers'], {'educationLevel': 'basic'});
  });

  test(
    'returns explicitly unverified on-device guidance when API is unavailable',
    () async {
      final networkClient = NetworkClient(
        environment: environment,
        httpClient: MockClient(
          (_) async => http.Response('<html>unavailable</html>', 503),
        ),
      );

      final answer = await QuickGuideAnswerService(client: networkClient)
          .resolve(
            question: 'Como funciona a matrícula na escola?',
            originCountry: 'argentina',
            destinationCountry: 'brasil',
            locale: 'pt',
          );

      expect(answer.offline, isTrue);
      expect(answer.topic, 'education');
      expect(answer.coverage, QuickGuideCoverage.partial);
      expect(answer.sources, isEmpty);
      expect(answer.trust.freshness, QuickGuideFreshness.notAvailable);
      expect(answer.actions, isEmpty);
    },
  );

  test(
    'keeps P0, P1 and P2 topics explicit and contained while offline',
    () async {
      final networkClient = NetworkClient(
        environment: environment,
        httpClient: MockClient(
          (_) async => http.Response('<html>unavailable</html>', 503),
        ),
      );

      for (final testCase in const [
        ('Como abrir conta e usar Pix?', 'finance'),
        ('Quando viro residente fiscal?', 'tax'),
        ('Como funciona a reunião familiar?', 'family'),
        ('Como levo meu cachorro para o Brasil?', 'pets_customs'),
        ('Como ativo um chip brasileiro?', 'utilities'),
        ('Onde denuncio xenofobia?', 'protection'),
        ('Como reclamo de uma empresa?', 'consumer'),
        ('Quando posso pedir naturalização?', 'long_term'),
        ('Meu processo de residência está parado', 'documents'),
        ('A escola recusou a matrícula por falta de documento', 'education'),
        ('O banco recusou minha conta', 'finance'),
      ]) {
        final answer = await QuickGuideAnswerService(client: networkClient)
            .resolve(
              question: testCase.$1,
              originCountry: 'argentina',
              destinationCountry: 'brasil',
              locale: 'pt',
            );

        expect(answer.topic, testCase.$2);
        expect(answer.offline, isTrue);
        expect(answer.sources, isEmpty);
        expect(answer.trust.evidenceCoverage, 0);
        expect(answer.actions, isEmpty);
      }
    },
  );
}
