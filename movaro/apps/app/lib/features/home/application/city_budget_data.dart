/// Real monthly cost breakdowns per Brazilian city, curated Mar/2025.
///
/// All amounts in BRL. Values represent lean–comfortable ranges for a single
/// person living independently (not sharing).
class CityBudgetData {
  const CityBudgetData._();

  static const _curated = 'Mar/2025';

  static CityBudget? forCity(String? cityId) {
    if (cityId == null) return null;
    final key = cityId.toLowerCase().trim();
    return _data[key] ??
        _data.entries
            .where((e) => key.contains(e.key) || e.key.contains(key))
            .map((e) => e.value)
            .firstOrNull;
  }

  static const _data = <String, CityBudget>{
    'sao-paulo': CityBudget(
      cityLabel: 'São Paulo',
      rent: CostRange(1200, 3500),
      food: CostRange(1200, 2000),
      transport: CostRange(250, 400),
      utilities: CostRange(150, 300),
      updatedAt: _curated,
    ),
    'sp': CityBudget(
      cityLabel: 'São Paulo',
      rent: CostRange(1200, 3500),
      food: CostRange(1200, 2000),
      transport: CostRange(250, 400),
      utilities: CostRange(150, 300),
      updatedAt: _curated,
    ),
    'florianopolis': CityBudget(
      cityLabel: 'Florianópolis',
      rent: CostRange(1800, 3200),
      food: CostRange(1200, 2000),
      transport: CostRange(200, 400),
      utilities: CostRange(150, 280),
      updatedAt: _curated,
    ),
    'curitiba': CityBudget(
      cityLabel: 'Curitiba',
      rent: CostRange(1200, 2200),
      food: CostRange(1000, 1700),
      transport: CostRange(200, 350),
      utilities: CostRange(130, 250),
      updatedAt: _curated,
    ),
    'rio-de-janeiro': CityBudget(
      cityLabel: 'Rio de Janeiro',
      rent: CostRange(1800, 3500),
      food: CostRange(1200, 2000),
      transport: CostRange(250, 400),
      utilities: CostRange(150, 280),
      updatedAt: _curated,
    ),
    'rj': CityBudget(
      cityLabel: 'Rio de Janeiro',
      rent: CostRange(1800, 3500),
      food: CostRange(1200, 2000),
      transport: CostRange(250, 400),
      utilities: CostRange(150, 280),
      updatedAt: _curated,
    ),
    'porto-alegre': CityBudget(
      cityLabel: 'Porto Alegre',
      rent: CostRange(1400, 2400),
      food: CostRange(1000, 1700),
      transport: CostRange(180, 320),
      utilities: CostRange(130, 250),
      updatedAt: _curated,
    ),
    'belo-horizonte': CityBudget(
      cityLabel: 'Belo Horizonte',
      rent: CostRange(1000, 2200),
      food: CostRange(1000, 1700),
      transport: CostRange(200, 350),
      utilities: CostRange(130, 250),
      updatedAt: _curated,
    ),
  };
}

class CityBudget {
  const CityBudget({
    required this.cityLabel,
    required this.rent,
    required this.food,
    required this.transport,
    required this.utilities,
    required this.updatedAt,
  });

  final String cityLabel;
  final CostRange rent;
  final CostRange food;
  final CostRange transport;
  final CostRange utilities;
  final String updatedAt;

  int get leanTotal => rent.min + food.min + transport.min + utilities.min;
  int get comfortableTotal =>
      rent.max + food.max + transport.max + utilities.max;
}

class CostRange {
  const CostRange(this.min, this.max);
  final int min;
  final int max;
}
