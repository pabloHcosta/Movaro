import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/explore/application/services/documentation_guide_search.dart';

void main() {
  group('DocumentationGuideSearch', () {
    test('understands natural questions and ignores filler words', () {
      final schoolScore = DocumentationGuideSearch.score(
        query: 'Como matricular meus filhos?',
        values: const ['Escola pública', 'Matrícula de crianças estrangeiras'],
      );
      final unrelatedScore = DocumentationGuideSearch.score(
        query: 'Como matricular meus filhos?',
        values: const ['Aluguel e garantia de moradia'],
      );

      expect(schoolScore, greaterThan(unrelatedScore));
      expect(schoolScore, greaterThan(0));
      expect(unrelatedScore, 0);
    });

    test('matches Portuguese, Spanish and common synonyms', () {
      expect(
        DocumentationGuideSearch.score(
          query: '¿Qué papeles necesito para residir?',
          values: const ['Documentos para residência e CRNM'],
        ),
        greaterThan(0),
      );
      expect(
        DocumentationGuideSearch.score(
          query: 'Quero fazer faculdade',
          values: const ['Universidade, Enem e Sisu'],
        ),
        greaterThan(0),
      );
    });

    test('is accent and punctuation insensitive', () {
      expect(
        DocumentationGuideSearch.score(
          query: 'SAÚDE!',
          values: const ['Atendimento no SUS'],
        ),
        greaterThan(0),
      );
    });
  });
}
