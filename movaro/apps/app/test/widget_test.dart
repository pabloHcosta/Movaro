import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/core/catalog/data/datasources/seed_catalog_data_source.dart';
import 'package:movaro_app/core/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_preferences_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores the selected journey for the global entry flow', () async {
    final catalogRepository = CatalogRepositoryImpl(
      dataSource: SeedCatalogDataSource(),
    );
    final journeyTempDir = await Directory.systemTemp.createTemp(
      'movaro_test_journey',
    );
    final journeyContextController = JourneyContextController(
      catalogRepository: catalogRepository,
      store: JourneyPreferencesStore(
        directoryProvider: () async => journeyTempDir,
      ),
    );

    await journeyContextController.initialize();
    await journeyContextController.markIntroSeen();
    await journeyContextController.completeJourney(
      originCountryId: 'argentina',
      destinationCountryId: 'brasil',
    );

    expect(journeyContextController.hasSeenIntro, isTrue);
    expect(journeyContextController.hasSelectedJourney, isTrue);
    expect(journeyContextController.hasSupportedJourney, isTrue);
    expect(journeyContextController.selectedOrigin?.id, 'argentina');
    expect(journeyContextController.selectedDestination?.id, 'brasil');
  });
}
