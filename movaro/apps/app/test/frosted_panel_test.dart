import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';

void main() {
  testWidgets('provides a visible Material surface for ListTile interactions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FrostedPanel(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              selected: true,
              title: const Text('Selectable option'),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Selectable option'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
