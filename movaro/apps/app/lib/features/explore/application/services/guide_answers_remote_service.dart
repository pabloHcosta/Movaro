import 'package:movaro_app/core/network/network_client.dart';

class GuideAnswerRemoteItem {
  const GuideAnswerRemoteItem({
    required this.section,
    required this.question,
    required this.answer,
    required this.keywords,
  });

  final String section;
  final String question;
  final String answer;
  final List<String> keywords;
}

class GuideAnswersRemoteService {
  GuideAnswersRemoteService({required NetworkClient client}) : _client = client;

  final NetworkClient _client;

  Future<List<GuideAnswerRemoteItem>> fetch({
    required String destinationCountry,
    String? originCountry,
    String locale = 'pt',
  }) async {
    final body = <String, dynamic>{
      'destinationCountry': destinationCountry,
      'locale': locale,
    };
    if (originCountry != null) {
      body['originCountry'] = originCountry;
    }

    final data = await _client.postJsonMap('/v1/chat/guide-answers', body);

    final rawItems = data['items'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => GuideAnswerRemoteItem(
            section: item['section'] as String? ?? '',
            question: item['question'] as String? ?? '',
            answer: item['answer'] as String? ?? '',
            keywords: (item['keywords'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(growable: false),
          ),
        )
        .where((item) => item.section.isNotEmpty && item.question.isNotEmpty)
        .toList(growable: false);
  }
}
