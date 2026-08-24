import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/info/application/quick_guide_question_catalog.dart';

void main() {
  test('finds a reviewed question from natural wording', () {
    final results = QuickGuideQuestionCatalog.search(
      'quero alugar mas não tenho fiador',
      languageCode: 'pt',
    );

    expect(results, isNotEmpty);
    expect(results.first.id, 'housing.guarantees');
  });

  test('tolerates a short spelling mistake without generating an answer', () {
    final results = QuickGuideQuestionCatalog.search(
      'matricla escola',
      languageCode: 'pt',
    );

    expect(results.map((item) => item.id), contains('education.school'));
  });

  test('ranks the reviewed intent above nearby housing questions', () {
    final results = QuickGuideQuestionCatalog.search(
      'rent guarantor',
      languageCode: 'en',
    );

    expect(results, isNotEmpty);
    expect(results.first.id, 'housing.guarantees');
  });

  test('returns no approximation outside reviewed coverage', () {
    final results = QuickGuideQuestionCatalog.search(
      'xyzzy assunto inexistente',
      languageCode: 'pt',
    );

    expect(results, isEmpty);
  });

  test('does not treat stop words as a supported question', () {
    final results = QuickGuideQuestionCatalog.search(
      'como eu faço para',
      languageCode: 'pt',
    );

    expect(results, isEmpty);
  });

  test('keeps the selected canonical question localized', () {
    final result = QuickGuideQuestionCatalog.search(
      'alquiler garantia',
      languageCode: 'es',
    ).first;

    expect(
      result.questionFor('es'),
      '¿Qué garantías pueden pedir para alquilar?',
    );
    expect(result.topicFor('en'), 'Housing');
  });
}
