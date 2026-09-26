import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/game/buildings/building_data.dart';
import 'package:knowledgeverse/game/ui/dialogs/battle_quiz_arena.dart';
import 'package:knowledgeverse/models/learning_models.dart';
import 'package:knowledgeverse/models/player_profile.dart';
import 'package:knowledgeverse/services/learning_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testBuilding = BuildingData(
    id: 'math_chamber_01',
    name: 'Progressions & Triangles Chamber',
    icon: Icons.functions,
    sprite: 'game-assets/buildings/academy_hall.png',
    level: 1,
    subject: 'Mathematics',
    description: 'Learn progression arithmetic and geometric fundamentals.',
    unlocked: true,
    lessonsAvailable: 4,
    themeColor: const Color(0xFFF2CA50),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PlayerProfile.notifier.value = const PlayerProfile(
      name: 'Hero Arcanist',
      level: 1,
      xp: 150,
      focusXp: 150,
      coins: 500,
      gems: 25,
      avatarIndex: 0,
    );

    LearningService.setCachedContent(
      'math_chamber_01_Mathematics_1',
      const LearningContentResponse(
        buildingId: 'math_chamber_01',
        buildingName: 'Progressions & Triangles Chamber',
        subject: 'Mathematics',
        topic: 'Linear Equations & Triangles',
        explanation: 'Linear equations balance through equality.',
        questions: [
          MCQuestion(
            id: 1,
            question: 'Solve for x: 3x + 9 = 24',
            options: ['x = 7', 'x = 3', 'x = 5', 'x = 15'],
            correctIndex: 2, // x = 5 is correct; index 0 is wrong
            explanation: 'Subtract 9 gives 15, then 15 / 3 = 5.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the sum of angles in a triangle?',
            options: ['90°', '180°', '270°', '360°'],
            correctIndex: 1, // 180° is correct; index 0 is wrong
            explanation: 'Interior angles of a triangle always sum to 180°.',
          ),
          MCQuestion(
            id: 3,
            question: 'What is the square root of 64?',
            options: ['6', '7', '8', '9'],
            correctIndex: 2, // 8 is correct; index 0 is wrong
            explanation: '8 * 8 = 64.',
          ),
        ],
        audioAvailable: false,
        source: 'cached_test',
        cacheKey: 'math_chamber_01_Mathematics_1',
      ),
    );
  });

  group('BattleQuizArena Full-Screen Arena Tests', () {
    testWidgets('BattleQuizArena mounts with player on left and realm guardian on right',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleQuizArena(
              building: testBuilding,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top combat header
      expect(find.text('ROUND 1 / 3'), findsOneWidget);
      expect(find.text('PROGRESSIONS & TRIANGLES CHAMBER'), findsOneWidget);

      // Left Player side
      expect(find.text('Hero Arcanist'), findsOneWidget);
      expect(find.text('LVL 1'), findsOneWidget);
      expect(find.text('100/100'), findsWidgets); // HP

      // Right Boss side
      expect(find.text('Arch-Geometer Pythagoras'), findsOneWidget);
      expect(find.text('BOSS'), findsOneWidget);

      // Center Question card
      expect(find.text('Solve for x: 3x + 9 = 24'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

      // 4 Bullet-point options
      expect(find.byKey(const Key('battle_opt_0')), findsOneWidget);
      expect(find.byKey(const Key('battle_opt_1')), findsOneWidget);
      expect(find.byKey(const Key('battle_opt_2')), findsOneWidget);
      expect(find.byKey(const Key('battle_opt_3')), findsOneWidget);

      // Exit button
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(closed, isTrue);
    });

    testWidgets('Incorrect answers only show knockdown animation after 3 consecutive misses',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleQuizArena(
              building: testBuilding,
              onClose: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Miss 1 (Q1): Tap wrong option (index 0: 'x = 7')
      await tester.tap(find.byKey(const Key('battle_opt_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Shows guardian damage combat strike, but fail knockdown animation is NOT shown!
      expect(find.textContaining('GUARDIAN STRIKE!'), findsOneWidget);
      expect(find.textContaining('GUARDIAN KNOCKDOWN!'), findsNothing);

      // Advance past delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Miss 2 (Q2): Tap wrong option (index 0: '90°')
      expect(find.text('ROUND 2 / 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('battle_opt_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 2nd miss: still under 3, so knockdown animation is NOT shown!
      expect(find.textContaining('GUARDIAN STRIKE!'), findsOneWidget);
      expect(find.textContaining('GUARDIAN KNOCKDOWN!'), findsNothing);

      // Advance past delay
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Miss 3 (Q3): Tap wrong option (index 0: '6')
      expect(find.text('ROUND 3 / 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('battle_opt_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 3rd consecutive miss: knockdown animation IS shown!
      expect(find.textContaining('GUARDIAN KNOCKDOWN!'), findsOneWidget);

      // Tap to skip or wait for fail timer to recover
      await tester.pump(const Duration(milliseconds: 2800));
      await tester.pumpAndSettle();

      // Battle complete
      expect(find.text('TRIAL INCOMPLETE'), findsOneWidget);
    });

    testWidgets('Answering all questions correctly displays sword blast victory animation and awards rewards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BattleQuizArena(
              building: testBuilding,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Q1: Tap correct option (index 2: 'x = 5')
      await tester.tap(find.byKey(const Key('battle_opt_2')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Q2: Tap correct option (index 1: '180°')
      expect(find.text('ROUND 2 / 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('battle_opt_1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      // Q3: Tap correct option (index 2: '8')
      expect(find.text('ROUND 3 / 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('battle_opt_2')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      // Shows epic sword blast victory animation immediately without lag!
      expect(find.textContaining('VICTORY STRIKE! REALM LIBERATED!'), findsOneWidget);

      // Wait for victory timer or tap to advance
      await tester.pump(const Duration(milliseconds: 5000));
      await tester.pumpAndSettle();

      // Victory completion card
      expect(find.text('TRIAL CONQUERED!'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('+50 COINS'), findsOneWidget);
      expect(find.text('+5 GEMS'), findsOneWidget);

      // Claim rewards button
      expect(find.byKey(const Key('claim_battle_rewards_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('claim_battle_rewards_btn')));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      final profile = PlayerProfile.notifier.value!;
      expect(profile.focusXp, equals(250)); // 150 + 100
      expect(profile.coins, equals(550)); // 500 + 50
      expect(profile.gems, equals(30)); // 25 + 5
    });
  });
}
