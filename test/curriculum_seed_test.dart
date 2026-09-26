import 'package:flutter_test/flutter_test.dart';
import 'package:knowledgeverse/models/learning_models.dart';
import 'package:knowledgeverse/services/curriculum_seed_catalog.dart';

void main() {
  group('CurriculumSeedCatalog Tests', () {
    test('contains classes for all 5 boards', () {
      final allClasses = CurriculumSeedCatalog.classes;
      expect(allClasses.length, equals(40));

      final cbse = CurriculumSeedCatalog.getClassesByBoard('CBSE');
      final icse = CurriculumSeedCatalog.getClassesByBoard('ICSE');
      final bseb = CurriculumSeedCatalog.getClassesByBoard('BSEB');
      final wbbse = CurriculumSeedCatalog.getClassesByBoard('WBBSE');
      final dbse = CurriculumSeedCatalog.getClassesByBoard('DBSE');

      expect(cbse.length, equals(8));
      expect(icse.length, equals(8));
      expect(bseb.length, equals(8));
      expect(wbbse.length, equals(8));
      expect(dbse.length, equals(8));
    });

    test('retrieves topics for Mathematics and Science across grades', () {
      final mathTopics = CurriculumSeedCatalog.getTopicsFor(
        subject: 'Mathematics',
        grade: 'Class 10',
      );
      expect(mathTopics, isNotEmpty);

      final scienceTopics = CurriculumSeedCatalog.getTopicsFor(
        subject: 'Science',
        grade: 'Class 10',
      );
      expect(scienceTopics, isNotEmpty);
    });

    test('generates valid LearningContentResponse fallback for learning request', () {
      const req = LearningRequest(
        buildingId: 'math_chamber_01',
        buildingName: 'Pythagoras Sanctum',
        subject: 'Mathematics',
        grade: 'Class 10',
        studentLevel: 1,
      );

      final content = CurriculumSeedCatalog.getLearningContentFor(req);
      expect(content.subject, equals('Mathematics'));
      expect(content.topic, isNotEmpty);
      expect(content.explanation, isNotEmpty);
      expect(content.questions, isNotEmpty);

      for (final q in content.questions) {
        expect(q.options.length, equals(4));
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.question, isNotEmpty);
      }
    });
  });
}
