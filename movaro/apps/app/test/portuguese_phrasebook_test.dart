import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/language/application/portuguese_phrasebook.dart';

void main() {
  test('phrasebook has grouped, well-formed phrases', () {
    final groups = PortuguesePhrasebook.groups;
    expect(groups, isNotEmpty);
    for (final group in groups) {
      expect(group.phrases, isNotEmpty, reason: 'group ${group.key} is empty');
      expect(group.title('es').trim(), isNotEmpty);
      expect(group.title('en').trim(), isNotEmpty);
      expect(group.title('pt').trim(), isNotEmpty);
      for (final phrase in group.phrases) {
        expect(phrase.pt.trim(), isNotEmpty);
        expect(phrase.es.trim(), isNotEmpty);
        expect(phrase.en.trim(), isNotEmpty);
      }
    }
  });

  test('translation() resolves by locale; phrase is always Portuguese', () {
    final phrase = PortuguesePhrasebook.groups
        .expand((g) => g.phrases)
        .firstWhere((p) => p.pt.toLowerCase().contains('cpf'));
    expect(phrase.translation('es'), phrase.es);
    expect(phrase.translation('en'), phrase.en);
    expect(phrase.translation('pt'), phrase.pt);
  });

  test('covers the core bureaucracy situations', () {
    final keys = PortuguesePhrasebook.groups.map((g) => g.key).toSet();
    expect(keys.containsAll({'documents', 'bank', 'rental', 'health', 'work'}), isTrue);
  });
}
