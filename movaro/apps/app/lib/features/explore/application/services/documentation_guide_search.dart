class DocumentationGuideSearch {
  const DocumentationGuideSearch._();

  static int score({required String query, required List<String> values}) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) {
      return 1;
    }

    final haystack = normalize(values.join(' '));
    if (haystack.contains(normalizedQuery)) {
      return 100;
    }

    final tokens = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.length > 1 && !_stopWords.contains(token))
        .toSet();
    var score = 0;
    for (final token in tokens) {
      if (haystack.contains(token)) {
        score += 8;
        continue;
      }
      final aliases = _aliases[token] ?? const <String>[];
      if (aliases.any(haystack.contains)) {
        score += 5;
      }
    }
    return score;
  }

  static String normalize(String value) {
    const replacements = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    var normalized = value.toLowerCase();
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    return normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  }

  static const _stopWords = <String>{
    'a',
    'as',
    'o',
    'os',
    'de',
    'da',
    'do',
    'das',
    'dos',
    'e',
    'em',
    'no',
    'na',
    'para',
    'por',
    'que',
    'qual',
    'quais',
    'como',
    'eu',
    'meu',
    'meus',
    'minha',
    'minhas',
    'preciso',
    'the',
    'what',
    'which',
    'how',
    'can',
    'need',
    'for',
    'and',
    'my',
    'el',
    'la',
    'los',
    'las',
    'del',
    'un',
    'una',
    'mi',
    'mis',
    'necesito',
  };

  static const _aliases = <String, List<String>>{
    'documento': ['documentos', 'certidao', 'registro', 'cpf', 'crnm'],
    'documentos': ['documento', 'certidao', 'registro', 'cpf', 'crnm'],
    'papeles': ['documento', 'documentos', 'certidao', 'registro'],
    'docs': ['documento', 'documentos', 'registro'],
    'morar': ['residencia', 'moradia', 'aluguel'],
    'viver': ['residencia', 'moradia', 'custos'],
    'residir': ['residencia', 'registro migratorio', 'crnm'],
    'matricular': ['matricula', 'escola', 'universidade'],
    'matricula': ['matricular', 'escola', 'universidade'],
    'filho': ['crianca', 'escola', 'familia'],
    'filhos': ['crianca', 'escola', 'familia'],
    'hijo': ['nino', 'escuela', 'familia'],
    'hijos': ['nino', 'escuela', 'familia'],
    'crianca': ['filho', 'escola', 'matricula'],
    'escola': ['educacao', 'matricula', 'crianca'],
    'colegio': ['escola', 'educacao', 'matricula'],
    'escuela': ['escola', 'educacao', 'matricula'],
    'faculdade': ['universidade', 'enem', 'sisu', 'estudar'],
    'universidade': ['faculdade', 'enem', 'sisu', 'estudar'],
    'universidad': ['universidade', 'enem', 'sisu', 'estudar'],
    'estudar': ['educacao', 'universidade', 'escola', 'sisu'],
    'estudiar': ['educacao', 'universidade', 'escola', 'sisu'],
    'study': ['education', 'university', 'school', 'sisu'],
    'preco': ['custo', 'custos', 'orcamento', 'taxa'],
    'valor': ['custo', 'custos', 'orcamento', 'taxa'],
    'dinheiro': ['custo', 'custos', 'orcamento', 'banco'],
    'costos': ['custo', 'custos', 'orcamento', 'taxa'],
    'cost': ['custo', 'custos', 'budget', 'fee'],
    'alugar': ['aluguel', 'moradia', 'fiador', 'deposito'],
    'alquiler': ['aluguel', 'moradia', 'fiador', 'deposito'],
    'trabalhar': ['trabalho', 'emprego', 'ctps', 'renda'],
    'emprego': ['trabalho', 'ctps', 'mercado'],
    'trabajar': ['trabalho', 'emprego', 'ctps'],
    'saude': ['sus', 'ubs', 'hospital', 'medico'],
    'salud': ['sus', 'ubs', 'hospital', 'medico'],
    'dirigir': ['cnh', 'habilitacao', 'detran', 'carteira'],
    'conducir': ['cnh', 'habilitacao', 'detran', 'carteira'],
  };
}
