import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/home/application/city_feed_datasource.dart';
import 'package:movaro_app/features/home/presentation/widgets/city_feed_widget.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

void main() {
  test('For You fallback exposes only traceable official cards', () {
    final items = CityFeedDatasource.build(
      cityCode: null,
      stage: UserJourneyStage.explorer,
      locale: 'pt',
    );

    expect(items, isNotEmpty);
    expect(items.every((item) => item.sourceUrl != null), isTrue);
    expect(
      items.every((item) => item.sourceUrl!.startsWith('https://www.gov.br/')),
      isTrue,
    );
    expect(
      items.any(
        (item) => (item.sourceLabel ?? '').toLowerCase().contains('movaro'),
      ),
      isFalse,
    );
    expect(items.any((item) => item.id.startsWith('story_')), isFalse);
  });

  test('social card without an external traceable source is hidden', () {
    const socialProof = CityDetailSocialProof(
      cityId: 'example',
      cityName: 'Example',
      argentinaPopularityScore: 90,
      socialSignals: [],
      sources: [
        CityDetailSource(label: 'Movaro internal model', type: 'curated'),
      ],
    );

    final items = CityFeedDatasource.build(
      cityCode: 'example',
      stage: UserJourneyStage.explorer,
      locale: 'pt',
      socialProof: socialProof,
    );

    expect(items.any((item) => item.id == 'social_example'), isFalse);
  });

  testWidgets('expanded For You card has premium reading hierarchy', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt', 'BR'),
        supportedLocales: [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: Center(
            child: CityFeedWidget(
              cityCode: null,
              stage: UserJourneyStage.explorer,
              locale: 'pt',
            ),
          ),
        ),
      ),
    );

    final card = find.ancestor(
      of: find.text('CPF para brasileiros e estrangeiros'),
      matching: find.byType(InkWell),
    );
    expect(card, findsOneWidget);
    await tester.tap(card);
    await tester.pump();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('O QUE VOCÊ PRECISA SABER'), findsOneWidget);
    expect(find.text('FONTE VERIFICÁVEL'), findsOneWidget);
    expect(find.text('Receita Federal · Gov.br'), findsOneWidget);
    expect(find.text('Consultar fonte original'), findsOneWidget);
  });
}
