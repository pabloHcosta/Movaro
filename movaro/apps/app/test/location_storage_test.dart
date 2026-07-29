import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/features/location/location_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sanRafael = LocationData(
    cityName: 'San Rafael',
    stateName: 'Mendoza',
    countryName: 'Argentina',
    countryCode: 'AR',
    latitude: -34.61,
    longitude: -68.33,
  );
  const mendoza = LocationData(
    cityName: 'Mendoza',
    stateName: 'Mendoza',
    countryName: 'Argentina',
    countryCode: 'AR',
    latitude: -32.89,
    longitude: -68.84,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('reuses only the same confirmed origin city', () async {
    final storage = LocationStorage();

    expect(await storage.isOriginLocationConfirmed(sanRafael), isFalse);

    await storage.confirmOriginLocation(sanRafael);

    expect(await storage.isOriginLocationConfirmed(sanRafael), isTrue);
    expect(await storage.isOriginLocationConfirmed(mendoza), isFalse);
  });

  test('clearing the saved location also clears its confirmation', () async {
    final storage = LocationStorage();
    await storage.saveLocation(sanRafael);
    await storage.confirmOriginLocation(sanRafael);

    await storage.clearLocation();

    expect(await storage.getSavedLocation(), isNull);
    expect(await storage.isOriginLocationConfirmed(sanRafael), isFalse);
  });
}
