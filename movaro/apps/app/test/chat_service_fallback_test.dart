import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/info/application/chat_service.dart';

void main() {
  test(
    'CPF question gets a curated answer (not a dead-end) with a guide pointer',
    () {
      final a = ChatService.localFallbackAnswer('How do I get my CPF?', 'es');
      expect(a.toLowerCase(), contains('cpf'));
      expect(a.toLowerCase(), contains('guías'));
    },
  );

  test('housing/fiador question is detected', () {
    final a = ChatService.localFallbackAnswer('alquiler sin fiador', 'es');
    expect(a.toLowerCase(), anyOf(contains('fiança'), contains('vivienda')));
  });

  test('residency question prioritizes the bilateral permanent route', () {
    final a = ChatService.localFallbackAnswer(
      'como hago la residencia mercosur',
      'es',
    );
    expect(a, contains('bilateral Brasil–Argentina'));
    expect(a, contains('residencia permanente'));
    expect(a, isNot(contains('plazo universal para solicitarla dentro de 90')));
  });

  test('unknown question falls back to the Guides pointer, localized', () {
    expect(
      ChatService.localFallbackAnswer(
        'asdf qualquer coisa',
        'pt',
      ).toLowerCase(),
      contains('guias'),
    );
    expect(
      ChatService.localFallbackAnswer('asdf', 'en').toLowerCase(),
      contains('guides'),
    );
  });
}
