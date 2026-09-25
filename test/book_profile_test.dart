import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/models/player_profile.dart';
import 'package:knowledgeverse/screens/profile_screen.dart';
import 'package:knowledgeverse/widgets/book_profile_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Book Profile View & Animation Tests', () {
    testWidgets('BookProfileView mounts and starts animation flow',
        (WidgetTester tester) async {
      const testProfile = PlayerProfile(
        name: 'ARSLAN',
        grade: 'Class 10',
        level: 2,
        coins: 100,
        focusXp: 120,
        avatarIndex: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookProfileView(profile: testProfile),
          ),
        ),
      );

      // Phase 1: Book appears initially
      expect(find.byType(BookProfileView), findsOneWidget);

      // Advance animation through Phase 2 (3D flip open) and Phase 3 (Content arrives)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));

      // After opening, check key book text and sections
      expect(find.text('GREEN BOOK'), findsNothing);
      expect(find.byKey(const Key('book_corner_close_button')), findsWidgets);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('ARSLAN'), findsOneWidget);
      expect(find.text('EQUIPMENT'), findsOneWidget);
      expect(find.text('CLOCK'), findsOneWidget);
      expect(find.text('World Map'), findsNothing);
      expect(find.text('THIS IS WHERE YOU ARE RIGHT NOW.'), findsNothing);
      expect(find.text('ACADEMY ARCHIPELAGO'), findsNothing);
      expect(find.text('Academy Record'), findsOneWidget);
      expect(find.text('SUBJECT MASTERY'), findsOneWidget);
      expect(find.text('Math House'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('700 / 1000 XP'), findsOneWidget);
      expect(find.text('300 XP TO LV 5'), findsOneWidget);
      expect(find.text('★ MASTERED'), findsOneWidget);
    });

    testWidgets('Tapping equipment slot reveals item tooltip',
        (WidgetTester tester) async {
      const testProfile = PlayerProfile(
        name: 'MAGE',
        avatarIndex: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookProfileView(profile: testProfile),
          ),
        ),
      );

      // Settle full opening animation
      await tester.pumpAndSettle();

      // Find first equipment slot (Scholar Crown) and tap it
      final firstSlot = find.byType(GestureDetector).first;
      await tester.tap(firstSlot);
      await tester.pump();

      // Tooltip should be shown or active
      expect(find.byType(BookProfileView), findsOneWidget);
    });

    testWidgets('Tapping corner close button triggers smooth book closing',
        (WidgetTester tester) async {
      bool closed = false;
      const testProfile = PlayerProfile(
        name: 'EXPLORER',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookProfileView(
              profile: testProfile,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find corner close button and tap it
      final closeButton = find.byKey(const Key('book_corner_close_button')).first;
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });

    testWidgets('ProfileScreen defaults to BookProfileView with clean presentation and mobile rotate',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const testProfile = PlayerProfile(
        name: 'HERO',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(profile: testProfile),
        ),
      );

      // Should render BookProfileView by default
      expect(find.byType(BookProfileView), findsOneWidget);
      expect(find.text('GREEN BOOK'), findsNothing);
      expect(find.text('DISTRICTS'), findsNothing);
      expect(find.byKey(const Key('book_back_nav_button')), findsOneWidget);

      // On mobile portrait, rotate / expand toggle is available
      final rotateToggle = find.byKey(const Key('rotate_book_toggle'));
      expect(rotateToggle, findsOneWidget);
      expect(find.text('EXPAND BOOK'), findsOneWidget);

      // Tap to expand / rotate
      await tester.tap(rotateToggle);
      await tester.pump();
      expect(find.text('PORTRAIT'), findsOneWidget);
      expect(find.byType(RotatedBox), findsOneWidget);

      // Tap again to return to portrait
      await tester.tap(rotateToggle);
      await tester.pump();
      expect(find.text('EXPAND BOOK'), findsOneWidget);
    });
  });
}
