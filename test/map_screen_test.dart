import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/screens/world_archipelago_screen.dart';

void main() {
  testWidgets('Test WorldArchipelagoScreen rendering', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: WorldArchipelagoScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WorldArchipelagoScreen), findsOneWidget);

    for (final island in WorldArchipelagoScreen.islands) {
      expect(find.text(island.name), findsOneWidget);
    }

    addTearDown(tester.view.resetPhysicalSize);
  });
}
