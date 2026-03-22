/// Intelligent city search with Argentine-friendly aliases, fuzzy matching,
/// and scored results.
///
/// Normalises diacritics (São → sao, Florianópolis → florianopolis) and
/// supports common nicknames Argentines use when searching for Brazilian
/// cities (e.g. "San Pablo" → São Paulo, "Floripa" → Florianópolis).
class CitySearchMatcher {
  const CitySearchMatcher._();

  // ──────────────────────────────────────────────────────────────────────────
  // Alias table — maps informal/Spanish names to canonical city names.
  // ──────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _aliases = {
    // São Paulo
    'san pablo': 'sao paulo',
    'san paulo': 'sao paulo',
    'sampa': 'sao paulo',
    'sp': 'sao paulo',

    // Rio de Janeiro
    'rio': 'rio de janeiro',
    'rj': 'rio de janeiro',

    // Florianópolis
    'floripa': 'florianopolis',
    'florianopolis': 'florianopolis',

    // Balneário Camboriú
    'bc': 'balneario camboriu',
    'camboriu': 'balneario camboriu',

    // Curitiba
    'ctba': 'curitiba',
    'curitiva': 'curitiba',

    // Porto Alegre
    'poa': 'porto alegre',

    // Brasília
    'brasilia': 'brasilia',
    'bsb': 'brasilia',

    // Foz do Iguaçu
    'iguazu': 'foz do iguacu',
    'iguacu': 'foz do iguacu',
    'foz': 'foz do iguacu',
    'cataratas': 'foz do iguacu',

    // Belo Horizonte
    'bh': 'belo horizonte',
    'belo': 'belo horizonte',

    // Salvador
    'bahia': 'salvador',

    // Recife
    'pernambuco': 'recife',

    // Fortaleza
    'ceara': 'fortaleza',

    // Joinville
    'joinvile': 'joinville',

    // Camboriú (city, not Balneário)
    'camboriú': 'balneario camboriu',
  };

  /// Score a city against a search query.
  ///
  /// Returns 0 when there is no match.
  /// Higher scores = better matches.
  ///
  /// Scoring tiers:
  ///   - exact name match → 100
  ///   - starts-with → 60
  ///   - alias resolves to city → 50
  ///   - contains → 30
  ///   - state match → 15
  static int score(String query, String cityName, String stateName) {
    if (query.isEmpty) return 0;

    final q = _normalize(query);
    final name = _normalize(cityName);
    final state = _normalize(stateName);

    if (q.isEmpty) return 0;

    // Exact match on city name.
    if (name == q) return 100;

    // Starts-with on city name.
    if (name.startsWith(q)) return 60;

    // Alias resolution.
    final aliasTarget = _aliases[q];
    if (aliasTarget != null && name.startsWith(aliasTarget)) return 50;

    // Partial alias — check if any alias key starts with the query.
    for (final entry in _aliases.entries) {
      if (entry.key.startsWith(q) && name.startsWith(entry.value)) return 45;
    }

    // Contains on city name.
    if (name.contains(q)) return 30;

    // State name match.
    if (state == q || state.startsWith(q)) return 15;

    // Token-level matching for multi-word queries.
    final queryTokens = q.split(' ').where((t) => t.isNotEmpty).toList();
    if (queryTokens.length > 1) {
      var tokenScore = 0;
      for (final token in queryTokens) {
        if (name.contains(token)) {
          tokenScore += 10;
        } else if (state.contains(token)) {
          tokenScore += 5;
        }
      }
      if (tokenScore > 0) return tokenScore;
    }

    return 0;
  }

  /// Normalise a string: lowercase, remove diacritics, collapse whitespace.
  static String _normalize(String value) {
    var n = value.toLowerCase().trim();
    const replacements = <String, String>{
      'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };
    replacements.forEach((src, tgt) {
      n = n.replaceAll(src, tgt);
    });
    n = n.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    n = n.replaceAll(RegExp(r'\s+'), ' ').trim();
    return n;
  }
}
