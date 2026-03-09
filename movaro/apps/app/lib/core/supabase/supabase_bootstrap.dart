import 'package:flutter/foundation.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  const SupabaseBootstrap._();

  static Future<void> initializeIfConfigured(AppEnvironment environment) async {
    if (!environment.hasSupabaseClientConfig) {
      debugPrint(
        'Supabase not configured for this build. Skipping client initialization.',
      );
      return;
    }

    await Supabase.initialize(
      url: environment.supabaseUrl!,
      anonKey: environment.supabaseAnonKey!,
      debug: environment.isDevelopment,
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: true,
      ),
      realtimeClientOptions: RealtimeClientOptions(
        logLevel: environment.isDevelopment
            ? RealtimeLogLevel.info
            : null,
      ),
    );
  }
}
