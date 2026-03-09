class AppLaunchPreferences {
  const AppLaunchPreferences._();

  static Future<bool> hasSeenIntro() async {
    // Temporarily disable persisted intro gating to avoid the native
    // shared_preferences/objective_c iOS build hook during beta testing.
    return true;
  }

  static Future<void> markIntroSeen() async {
    return;
  }
}
