import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';

extension JourneyCountryMetadata on CatalogCountry {
  String get flagEmoji {
    switch (id) {
      case 'argentina':
        return '🇦🇷';
      case 'brasil':
        return '🇧🇷';
      case 'chile':
        return '🇨🇱';
      case 'uruguai':
        return '🇺🇾';
      default:
        return '🌍';
    }
  }

  String get journeyValue {
    switch (id) {
      case 'brasil':
        return 'brazil';
      default:
        return id;
    }
  }
}
