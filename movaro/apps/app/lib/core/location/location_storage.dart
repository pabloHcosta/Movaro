import 'dart:convert';

import 'package:movaro_app/core/location/location_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationStorage {
  static const keyLocationData = 'user_location_data';
  static const keyPermissionStatus = 'location_permission_status';
  static const keyPermissionAsked = 'location_permission_asked';
  static const keyLastAskedAt = 'location_permission_last_asked_at';

  Future<void> saveLocation(LocationData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLocationData, jsonEncode(data.toJson()));
  }

  Future<LocationData?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyLocationData);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return LocationData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyLocationData);
  }

  Future<void> savePermissionStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPermissionStatus, status);
    await prefs.setBool(keyPermissionAsked, true);
    await prefs.setString(keyLastAskedAt, DateTime.now().toIso8601String());
  }

  Future<String> getPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPermissionStatus) ?? 'not_asked';
  }

  Future<bool> wasPermissionAsked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyPermissionAsked) ?? false;
  }

  Future<DateTime?> getLastAskedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(keyLastAskedAt);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
