class ArgentinaOriginClassifier {
  const ArgentinaOriginClassifier._();

  static String classify({required String city, required String province}) {
    final normalizedCity = _normalize(city);
    final normalizedProvince = _normalize(province);

    if (normalizedProvince == 'mendoza') return 'mendoza';
    if (normalizedProvince == 'cordoba') return 'cordoba';
    if (normalizedCity == 'rosario') return 'rosario';
    if (normalizedProvince == 'salta' ||
        normalizedProvince == 'jujuy' ||
        normalizedProvince == 'tucuman' ||
        normalizedProvince == 'catamarca' ||
        normalizedProvince == 'santiago del estero') {
      return 'salta_jujuy';
    }
    if (normalizedProvince == 'entre rios' ||
        normalizedProvince == 'corrientes' ||
        normalizedProvince == 'misiones' ||
        normalizedProvince == 'chaco' ||
        normalizedProvince == 'formosa' ||
        normalizedProvince == 'santa fe') {
      return 'litoral';
    }
    if (normalizedProvince == 'ciudad autonoma de buenos aires' ||
        normalizedProvince == 'buenos aires') {
      return 'buenos_aires';
    }
    return 'other_origin';
  }

  static String _normalize(String value) {
    var normalized = value.trim().toLowerCase();
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized;
  }
}
