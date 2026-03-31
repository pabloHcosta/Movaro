/// Monthly cost snapshots per city backed by public cost-of-living references.
///
/// fair = one-person monthly estimate excluding rent + cheaper 1-bedroom rent
/// well = one-person monthly estimate excluding rent + more expensive 1-bedroom rent
class CityBudgetData {
  const CityBudgetData._();

  static CityBudget? forCity(String? cityId) {
    if (cityId == null) return null;
    final key = _normalize(cityId);
    return _data[key] ??
        _data.entries
            .where(
              (entry) => key.contains(entry.key) || entry.key.contains(key),
            )
            .map((entry) => entry.value)
            .firstOrNull;
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('_', '-')
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }

  static const _data = <String, CityBudget>{
    'sao-paulo': CityBudget(
      cityLabel: 'São Paulo',
      singlePersonExcludingRent: 3573,
      oneBedroomOutsideCentre: 2342,
      oneBedroomCityCentre: 3469,
      monthlyTransportPass: 247,
      utilities: 436,
      updatedAt: '22 Mar 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Sao-Paulo',
    ),
    'sp': CityBudget(
      cityLabel: 'São Paulo',
      singlePersonExcludingRent: 3573,
      oneBedroomOutsideCentre: 2342,
      oneBedroomCityCentre: 3469,
      monthlyTransportPass: 247,
      utilities: 436,
      updatedAt: '22 Mar 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Sao-Paulo',
    ),
    'florianopolis': CityBudget(
      cityLabel: 'Florianópolis',
      singlePersonExcludingRent: 3201,
      oneBedroomOutsideCentre: 2194,
      oneBedroomCityCentre: 3047,
      monthlyTransportPass: 414,
      utilities: 374,
      updatedAt: '29 Mar 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Florianopolis',
    ),
    'curitiba': CityBudget(
      cityLabel: 'Curitiba',
      singlePersonExcludingRent: 3008,
      oneBedroomOutsideCentre: 1429,
      oneBedroomCityCentre: 2251,
      monthlyTransportPass: 360,
      utilities: 425,
      updatedAt: '27 Mar 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Curitiba',
    ),
    'rio-de-janeiro': CityBudget(
      cityLabel: 'Rio de Janeiro',
      singlePersonExcludingRent: 3179,
      oneBedroomOutsideCentre: 1829,
      oneBedroomCityCentre: 3227,
      monthlyTransportPass: 282,
      utilities: 589,
      updatedAt: 'Feb 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Rio-De-Janeiro',
    ),
    'rj': CityBudget(
      cityLabel: 'Rio de Janeiro',
      singlePersonExcludingRent: 3179,
      oneBedroomOutsideCentre: 1829,
      oneBedroomCityCentre: 3227,
      monthlyTransportPass: 282,
      utilities: 589,
      updatedAt: 'Feb 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Rio-De-Janeiro',
    ),
    'porto-alegre': CityBudget(
      cityLabel: 'Porto Alegre',
      singlePersonExcludingRent: 3135,
      oneBedroomOutsideCentre: 1452,
      oneBedroomCityCentre: 2098,
      monthlyTransportPass: 300,
      utilities: 355,
      updatedAt: '24 Mar 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Porto-Alegre',
    ),
    'belo-horizonte': CityBudget(
      cityLabel: 'Belo Horizonte',
      singlePersonExcludingRent: 3092,
      oneBedroomOutsideCentre: 1496,
      oneBedroomCityCentre: 2662,
      monthlyTransportPass: 345,
      utilities: 398,
      updatedAt: '15 Mar 2026',
      sourceLabel: 'Numbeo',
      sourceUrl: 'https://www.numbeo.com/cost-of-living/in/Belo-Horizonte',
    ),
  };
}

class CityBudget {
  const CityBudget({
    required this.cityLabel,
    required this.singlePersonExcludingRent,
    required this.oneBedroomOutsideCentre,
    required this.oneBedroomCityCentre,
    required this.monthlyTransportPass,
    required this.utilities,
    required this.updatedAt,
    required this.sourceLabel,
    required this.sourceUrl,
  });

  final String cityLabel;
  final int singlePersonExcludingRent;
  final int oneBedroomOutsideCentre;
  final int oneBedroomCityCentre;
  final int monthlyTransportPass;
  final int utilities;
  final String updatedAt;
  final String sourceLabel;
  final String sourceUrl;

  int get cheaperRent => oneBedroomOutsideCentre < oneBedroomCityCentre
      ? oneBedroomOutsideCentre
      : oneBedroomCityCentre;

  int get pricierRent => oneBedroomOutsideCentre > oneBedroomCityCentre
      ? oneBedroomOutsideCentre
      : oneBedroomCityCentre;

  int get fairLivingTotal => singlePersonExcludingRent + cheaperRent;
  int get wellLivingTotal => singlePersonExcludingRent + pricierRent;
}
