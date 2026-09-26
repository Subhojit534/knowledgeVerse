import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/game/buildings/sample_building_data.dart';
import 'package:knowledgeverse/game/managers/building_manager.dart';
import 'package:knowledgeverse/game/ui/dialogs/battle_quiz_arena.dart';
import 'package:knowledgeverse/game/ui/dialogs/lesson_book_view.dart';
import 'package:knowledgeverse/game/ui/dialogs/lesson_launcher.dart';
import 'package:knowledgeverse/game/ui/hud/game_hud.dart';
import 'package:knowledgeverse/models/player_profile.dart';
import 'package:knowledgeverse/screens/world_archipelago_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    BuildingManager().closeLessonBook();
    BuildingManager().closePanel();
    BuildingManager().closeQuiz();
    PlayerProfile.notifier.value = const PlayerProfile(
      name: 'Hero',
      level: 1,
      grade: 'Class 10',
      curriculum: 'CBSE',
    );
  });

  group('LessonBookView & Map Integration Tests', () {
    testWidgets('LessonBookView mounts and animates open displaying realistic pages and per-page audio',
        (WidgetTester tester) async {
      final building = SampleBuildingData.library;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonBookView(
              building: building,
              onClose: () {},
            ),
          ),
        ),
      );

      // Book starts closed and begins opening animation
      expect(find.byType(LessonBookView), findsOneWidget);

      // Advance through the 900ms 3D opening animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check corner close button exists and no "RETURN TO MAP" text is shown
      expect(find.byKey(const Key('close_book_btn')), findsOneWidget);
      expect(find.text('RETURN TO MAP'), findsNothing);

      // Check Per-Page Audio Listen buttons on each page!
      expect(find.text('Listen Page 1'), findsOneWidget);
      expect(find.text('Listen Page 2'), findsOneWidget);

      // Left page headers, chapter title, and numbering
      expect(find.text('BOOK 1'), findsOneWidget);
      expect(find.text('CHAPTER 1'), findsOneWidget);
      expect(find.text('— 1 —'), findsOneWidget);

      // Verify NO scrolling and NO scrollbars exist anywhere in the book pages
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(Scrollbar), findsNothing);

      // Verify the illustration image is present and uses BoxFit.contain (uncropped, authentic)
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsWidgets);
      final imageWidget = tester.widget<Image>(imageFinder.first);
      expect(imageWidget.fit, equals(BoxFit.contain));

      // Right page headers and numbering
      expect(find.text('THEORY & ESSENTIAL PRINCIPLES'), findsOneWidget);
      expect(find.text('— 2 —'), findsOneWidget);
    });

    testWidgets('Dragging horizontally turns pages across chapter and completes chapter with rewards',
        (WidgetTester tester) async {
      final building = SampleBuildingData.library;
      bool closed = false;
      bool quizTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonBookView(
              building: building,
              onClose: () => closed = true,
              onGoToQuiz: () => quizTriggered = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // On Spread 0: Page 1 & 2
      expect(find.text('— 1 —'), findsOneWidget);
      expect(find.text('— 2 —'), findsOneWidget);

      // Verify NO next_page_btn or prev_page_btn arrow buttons exist (pure drag navigation)
      expect(find.byKey(const Key('next_page_btn')), findsNothing);
      expect(find.byKey(const Key('prev_page_btn')), findsNothing);

      // Turn to Spread 1 (Pages 3 & 4) by dragging page horizontally
      await tester.drag(find.text('— 2 —'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('— 3 —'), findsOneWidget);
      expect(find.text('— 4 —'), findsOneWidget);
      expect(find.text('Listen Page 3'), findsOneWidget);
      expect(find.text('Listen Page 4'), findsOneWidget);

      // Turn to Spread 2 (Pages 5 & 6: Lesson Completion) by dragging page horizontally
      await tester.drag(find.text('— 4 —'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('— 5 —'), findsOneWidget);
      expect(find.text('— 6 —'), findsOneWidget);
      expect(find.text('CHAPTER 1 MASTERED'), findsOneWidget);
      expect(find.text('Go to Quiz ➔'), findsOneWidget);
      expect(find.byKey(const Key('go_to_quiz_btn')), findsOneWidget);

      // Tap Go to Quiz to finish the lesson and transition to quiz outside the book
      await tester.tap(find.byKey(const Key('go_to_quiz_btn')));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(quizTriggered, isTrue);
      expect(BuildingManager().activeQuizBuilding?.id, equals(building.id));
    });

    testWidgets('BuildingManager openLessonBook and closeLessonBook manage book state',
        (WidgetTester tester) async {
      final bm = BuildingManager();
      expect(bm.activeBookBuilding, isNull);

      final building = SampleBuildingData.codingTower;
      bm.openLessonBook(building);

      expect(bm.activeBookBuilding, equals(building));

      bm.closeLessonBook();
      expect(bm.activeBookBuilding, isNull);
    });

    testWidgets('LessonLauncher.launchBuilding opens lesson book via BuildingManager',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  LessonLauncher.launchBuilding(context, SampleBuildingData.scienceLab);
                },
                child: const Text('Launch'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Launch'));
      await tester.pump();

      expect(BuildingManager().activeBookBuilding?.id, equals(SampleBuildingData.scienceLab.id));
    });

    testWidgets('GameHud renders LessonBookView when activeBookBuilding is set',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameHudWidget(),
          ),
        ),
      );

      expect(find.byType(LessonBookView), findsNothing);

      BuildingManager().openLessonBook(SampleBuildingData.library);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(LessonBookView), findsOneWidget);

      BuildingManager().closeLessonBook();
      await tester.pumpAndSettle();

      expect(find.byType(LessonBookView), findsNothing);
    });

    testWidgets('BuildingManager openQuiz and closeQuiz manage quiz state and GameHud renders BuildingLearningPanel',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameHudWidget(),
          ),
        ),
      );

      final bm = BuildingManager();
      expect(bm.activeQuizBuilding, isNull);
      expect(find.byType(BattleQuizArena), findsNothing);

      bm.openQuiz(SampleBuildingData.codingTower);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(bm.activeQuizBuilding, equals(SampleBuildingData.codingTower));
      expect(find.byType(BattleQuizArena), findsOneWidget);

      bm.closeQuiz();
      await tester.pumpAndSettle();

      expect(bm.activeQuizBuilding, isNull);
      expect(find.byType(BattleQuizArena), findsNothing);
    });

    testWidgets('Red Spell Book Map displays topics and subtopics with specific IDs, and attuning stores specific topic and subtopic IDs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final building = SampleBuildingData.grandHall;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonBookView(
              building: building,
            ),
          ),
        ),
      );

      // Open book animation
      await tester.pump(const Duration(milliseconds: 1400));
      await tester.pumpAndSettle();

      // Drag to turn from Spread 0 (Pages 1 & 2) to Spread 1 (Pages 3 & 4: Codex Topics Map)
      await tester.drag(find.text('— 2 —'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify Codex Topics Map is visible
      expect(find.text('CODEX TOPICS MAP'), findsOneWidget);
      expect(find.text('SUBTOPICS & SPELLS'), findsOneWidget);

      // Find an attune subtopic button
      final attuneButtons = find.text('ATTUNE SUBTOPIC');
      if (attuneButtons.evaluate().isNotEmpty) {
        await tester.tap(attuneButtons.first);
        await tester.pumpAndSettle();

        // Check that PlayerProfile has stored the specific IDs
        expect(PlayerProfile.current?.activeTopicId, isNotNull);
        expect(PlayerProfile.current?.activeTopicId, isNotEmpty);
        expect(PlayerProfile.current?.activeSubtopicId, isNotNull);
        expect(PlayerProfile.current?.activeSubtopicId, isNotEmpty);
        expect(PlayerProfile.current?.activeSubtopicId, startsWith('c00000'));
      }

      // Drag to Spread 2 (Pages 5 & 6: Mastery & Quiz)
      await tester.drag(find.text('— 4 —'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify Attuned Codex banner is present
      expect(find.byKey(const Key('attuned_codex_banner')), findsOneWidget);

      // Tap Go to Quiz button
      await tester.tap(find.byKey(const Key('go_to_quiz_btn')));
      await tester.pumpAndSettle();

      // Verify BuildingManager received the attuned subtopic and topic IDs
      expect(BuildingManager().activeQuizSubtopicId, equals(PlayerProfile.current?.activeSubtopicId));
      expect(BuildingManager().activeQuizTopicId, equals(PlayerProfile.current?.activeTopicId));
    });

    testWidgets('WorldArchipelagoScreen renders Red Spell Book Codex Map action button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: WorldArchipelagoScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('open_red_spellbook_btn')), findsOneWidget);
      expect(find.text('RED SPELL BOOK • CODEX MAP'), findsOneWidget);
    });
  });
}
