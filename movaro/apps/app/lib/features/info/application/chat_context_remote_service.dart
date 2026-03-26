import 'package:movaro_app/core/network/network_client.dart';
import 'package:movaro_app/features/info/application/gemini_chat_service.dart';

/// Result of a context fetch from the backend.
class ChatContextResult {
  const ChatContextResult({
    required this.appDataBlock,
    required this.coverageLevel,
    required this.supportedCorridor,
  });

  /// Formatted text block ready to be injected into the AI system prompt.
  final String appDataBlock;

  /// 'full' | 'partial' | 'unsupported'
  final String coverageLevel;

  final String supportedCorridor;

  bool get isSupported => coverageLevel != 'unsupported';
}

/// Fetches context data from the Movaro API to inject into the Gemini prompt.
///
/// This is called once before [GeminiChatService.initialize] so the AI
/// receives real city data and guide phase items instead of an empty string.
class ChatContextRemoteService {
  ChatContextRemoteService({required NetworkClient networkClient})
    : _client = networkClient;

  final NetworkClient _client;

  /// Calls `POST /api/v1/chat/context` and returns the structured app data block.
  ///
  /// Returns `null` on any network error so the caller can fall back to an
  /// empty context rather than blocking the chat from opening.
  Future<ChatContextResult?> fetchContext({
    required String originCountry,
    required String destinationCountry,
    required UserMigrationContext userContext,
    required String locale,
  }) async {
    try {
      final body = <String, dynamic>{
        'originCountry': originCountry,
        'destinationCountry': destinationCountry,
        'locale': locale,
        if (userContext.migrationGoal != null)
          'migrationGoal': userContext.migrationGoal,
        if (userContext.recommendedCity != null)
          'recommendedCityId': _toKebabCase(userContext.recommendedCity!),
        if (userContext.currentPhase != null)
          'currentPhase': userContext.currentPhase,
        if (userContext.completedItemIds.isNotEmpty)
          'completedItemIds': userContext.completedItemIds,
        if (userContext.planTimeline != null)
          'planTimeline': userContext.planTimeline,
      };

      final data = await _client.postJsonMap('/api/v1/chat/context', body);

      return ChatContextResult(
        appDataBlock: data['appDataBlock'] as String? ?? '',
        coverageLevel: data['coverageLevel'] as String? ?? 'unsupported',
        supportedCorridor: data['supportedCorridor'] as String? ?? '',
      );
    } catch (_) {
      // Fail silently — chat still works without server context.
      return null;
    }
  }

  /// Converts a city name to a kebab-case ID as expected by the cities catalog.
  /// "São Paulo" → "sao-paulo", "Florianópolis" → "florianopolis"
  static String _toKebabCase(String name) {
    const accents =
        'àáâãäåæçèéêëìíîïðñòóôõöùúûüýÿ'
        'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝŸ';
    const normalized =
        'aaaaaaaceeeeiiiidnoooooouuuuyy'
        'aaaaaaaceeeeiiiidnoooooouuuuyy';

    var result = name.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], normalized[i]);
    }
    return result
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .trim();
  }
}
