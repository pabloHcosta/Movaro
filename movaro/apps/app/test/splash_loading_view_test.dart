import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/features/splash/presentation/pages/splash_loading_view.dart';

void main() {
  testWidgets('splash keeps the brand hero readable on a compact phone', (
    tester,
  ) async {
    await _pumpSplash(tester, size: const Size(390, 844));

    expect(find.text('Movaro'), findsOneWidget);
    expect(find.text('Seu próximo passo começa com clareza.'), findsOneWidget);
    expect(find.text('Preparando seu caminho'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _captureIfRequested(tester, 'movaro-splash-portrait.png');
  });

  testWidgets('splash switches to a horizontal hero on desktop', (
    tester,
  ) async {
    await _pumpSplash(tester, size: const Size(1280, 720));

    final mark = tester.getRect(find.byType(SvgPicture));
    final wordmark = tester.getRect(find.text('Movaro'));

    expect(mark.center.dx, lessThan(wordmark.center.dx));
    expect(find.text('Preparando seu caminho'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _captureIfRequested(tester, 'movaro-splash-landscape.png');
  });
}

Future<void> _pumpSplash(WidgetTester tester, {required Size size}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt'),
      supportedLocales: AppLocalization.supportedLocales,
      localizationsDelegates: AppLocalization.localizationsDelegates,
      theme: AppTheme.dark(),
      home: const SplashLoadingView(
        loadingLabel: 'Preparando seu caminho',
        initializingLabel: 'Inicializando experiência',
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 900));
}

Future<void> _captureIfRequested(WidgetTester tester, String filename) async {
  const capture = bool.fromEnvironment('CAPTURE_SPLASH');
  if (!capture) return;

  final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('splash-visual-root')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('/tmp/$filename').writeAsBytes(data!.buffer.asUint8List());
  });
}
