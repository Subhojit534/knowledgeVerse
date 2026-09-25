import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/config/asset_paths.dart';
import 'package:knowledgeverse/game/buildings/building_data.dart';
import 'package:knowledgeverse/game/ui/dialogs/building_learning_panel.dart';
import 'package:knowledgeverse/models/learning_models.dart';
import 'package:knowledgeverse/services/learning_service.dart';

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
    LearningService.setCachedContent(
      'math_chamber_01_Mathematics_1',
      const LearningContentResponse(
        buildingId: 'math_chamber_01',
        buildingName: 'Progressions & Triangles Chamber',
        subject: 'Mathematics',
        topic: 'Linear Equations & Triangles',
        explanation: 'Linear equations can be solved by isolating variables.',
        questions: [
          MCQuestion(
            id: 1,
            question: 'Solve for x: 3x + 9 = 24',
            options: ['x = 7', 'x = 3', 'x = 5', 'x = 15'],
            correctIndex: 2, // x = 5 is correct; index 0 (x = 7) is incorrect
            explanation: 'Subtract 9 gives 15, then 15 / 3 = 5.',
          ),
          MCQuestion(
            id: 2,
            question: 'What is the sum of angles in a triangle?',
            options: ['90°', '180°', '270°', '360°'],
            correctIndex: 1,
            explanation: 'Interior angles of a triangle always sum to 180°.',
          ),
        ],
        audioAvailable: false,
        source: 'cached_test',
        cacheKey: 'math_chamber_01_Mathematics_1',
      ),
    );
  });

  testWidgets('Quiz fail animation plays when user answers incorrectly and advances to next question',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingLearningPanel(
            building: testBuilding,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to QUIZ tab
    final quizTabFinder = find.text('QUIZ');
    expect(quizTabFinder, findsOneWidget);
    await tester.tap(quizTabFinder);
    await tester.pumpAndSettle();

    // Verify Q 1 is displayed and question text is present
    expect(find.textContaining('Q 1'), findsOneWidget);
    expect(find.text('Solve for x: 3x + 9 = 24'), findsOneWidget);
    expect(find.text('SUBMIT ANSWER'), findsOneWidget);

    // Tap Option A ('x = 7', which is incorrect since correctIndex is 2)
    final optionAFinder = find.text('x = 7');
    expect(optionAFinder, findsOneWidget);
    await tester.tap(optionAFinder);
    await tester.pumpAndSettle();

    // Tap SUBMIT ANSWER
    final submitButton = find.text('SUBMIT ANSWER');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    // Advance 500ms to trigger fail animation transition
    await tester.pump(const Duration(milliseconds: 500));

    // Verify: The question text has disappeared!
    expect(find.text('Solve for x: 3x + 9 = 24'), findsNothing);

    // Verify: The whole section shows the GIF and NOT the questions in the bottom!
    expect(find.text('x = 7'), findsNothing);
    expect(find.text('x = 3'), findsNothing);
    expect(find.text('x = 5'), findsNothing);
    expect(find.text('x = 15'), findsNothing);

    // Verify: Fail animation card appears with fail animation asset and feedback
    expect(find.textContaining('WRONG ANSWER!'), findsOneWidget);
    expect(find.text('SKIP ▶'), findsOneWidget);
    expect(find.text('NEXT QUESTION  ▶'), findsOneWidget);

    // Verify fail animation GIF asset is rendered (fail_fall.gif)
    final imageWidgets = tester.widgetList<Image>(find.byType(Image));
    final hasFailGif = imageWidgets.any(
      (img) => img.image is AssetImage && (img.image as AssetImage).assetName == AssetPaths.quizFailAnimation,
    );
    expect(hasFailGif, isTrue);

    // Tap NEXT QUESTION ▶ button to proceed
    final nextBtnFinder = find.text('NEXT QUESTION  ▶');
    await tester.ensureVisible(nextBtnFinder);
    await tester.tap(nextBtnFinder);
    await tester.pumpAndSettle();

    // Verify: After that, the next question appears (Q 2) with its question text!
    expect(find.textContaining('Q 2'), findsOneWidget);
    expect(find.text('What is the sum of angles in a triangle?'), findsOneWidget);
    expect(find.textContaining('WRONG ANSWER!'), findsNothing);
  });

  testWidgets('Quiz fail animation auto-advances to next question after timer completes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingLearningPanel(
            building: testBuilding,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to QUIZ tab
    await tester.tap(find.text('QUIZ'));
    await tester.pumpAndSettle();

    // Tap wrong option A ('x = 7')
    await tester.tap(find.text('x = 7'));
    await tester.pumpAndSettle();

    // Submit answer
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pump();

    // Advance 500ms into fail animation
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('WRONG ANSWER!'), findsOneWidget);

    // Wait full timer duration (2750ms)
    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    // Verify auto-advanced to Q 2
    expect(find.textContaining('Q 2'), findsOneWidget);
    expect(find.text('What is the sum of angles in a triangle?'), findsOneWidget);
    expect(find.textContaining('WRONG ANSWER!'), findsNothing);
  });

  testWidgets('Correct answer does NOT trigger fail animation and allows normal progression',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingLearningPanel(
            building: testBuilding,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to QUIZ tab
    await tester.tap(find.text('QUIZ'));
    await tester.pumpAndSettle();

    // Tap CORRECT option C ('x = 5')
    await tester.tap(find.text('x = 5'));
    await tester.pumpAndSettle();

    // Submit answer
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify: Question does NOT disappear, NO fail animation
    expect(find.text('Solve for x: 3x + 9 = 24'), findsOneWidget);
    expect(find.textContaining('INCORRECT!'), findsNothing);
    expect(find.text('NEXT  ▶'), findsOneWidget);
  });

  testWidgets('Quiz victory animation plays when user answers all questions correctly and allows claiming rewards',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingLearningPanel(
            building: testBuilding,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to QUIZ tab
    await tester.tap(find.text('QUIZ'));
    await tester.pumpAndSettle();

    // Question 1: choose correct option 'x = 5'
    await tester.tap(find.text('x = 5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pumpAndSettle();

    // Tap NEXT ▶
    await tester.tap(find.text('NEXT  ▶'));
    await tester.pumpAndSettle();

    // Question 2: choose correct option '180°'
    expect(find.text('What is the sum of angles in a triangle?'), findsOneWidget);
    await tester.tap(find.text('180°'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pumpAndSettle();

    // Tap FINISH QUIZ ★
    final finishBtn = find.text('FINISH QUIZ ★');
    expect(finishBtn, findsOneWidget);
    await tester.tap(finishBtn);
    await tester.pumpAndSettle();

    // Verify: Perfect victory sword blast animation section is displayed!
    expect(find.textContaining('PERFECT VICTORY!'), findsOneWidget);
    expect(find.textContaining('SWORD BLAST'), findsOneWidget);
    expect(find.text('CLAIM REWARDS ★'), findsOneWidget);

    // Verify victory GIF asset is rendered (quiz_victory.gif)
    final imageWidgets = tester.widgetList<Image>(find.byType(Image));
    final hasVictoryGif = imageWidgets.any(
      (img) => img.image is AssetImage && (img.image as AssetImage).assetName == AssetPaths.quizVictoryAnimation,
    );
    expect(hasVictoryGif, isTrue);

    // Tap CLAIM REWARDS ★
    await tester.tap(find.text('CLAIM REWARDS ★'));
    await tester.pumpAndSettle();

    // Verify final rewards view appears
    expect(find.text('QUIZ COMPLETE!'), findsOneWidget);
    expect(find.text('2 / 2 CORRECT'), findsOneWidget);
    expect(find.textContaining('+5 DIAMONDS! PERFECT SCORE ★'), findsOneWidget);
  });

  testWidgets('Quiz victory animation auto-advances to completion rewards after timer',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BuildingLearningPanel(
            building: testBuilding,
            onClose: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to QUIZ tab
    await tester.tap(find.text('QUIZ'));
    await tester.pumpAndSettle();

    // Question 1: correct answer
    await tester.tap(find.text('x = 5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NEXT  ▶'));
    await tester.pumpAndSettle();

    // Question 2: correct answer
    await tester.tap(find.text('180°'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SUBMIT ANSWER'));
    await tester.pumpAndSettle();

    // Finish quiz
    await tester.tap(find.text('FINISH QUIZ ★'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('PERFECT VICTORY!'), findsOneWidget);

    // Fast forward through the 4.7s victory animation timer
    await tester.pump(const Duration(milliseconds: 4800));
    await tester.pumpAndSettle();

    // Verify automatically transitioned to completed view
    expect(find.text('QUIZ COMPLETE!'), findsOneWidget);
    expect(find.text('2 / 2 CORRECT'), findsOneWidget);
  });
}
