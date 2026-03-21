/// Gemini API key — loaded via `--dart-define=GEMINI_API_KEY=…` at build time.
/// Falls back to the free-tier key when no override is provided.
const geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: 'AIzaSyBHclCdpq76cEZRxmd3bkOkUvbU5zr0AQg',
);
