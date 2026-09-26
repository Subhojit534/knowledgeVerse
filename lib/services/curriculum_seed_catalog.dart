// GENERATED FROM SQL SEED DATA - KNOWLEDGEVERSE CURRICULUM
import '../models/learning_models.dart';

class SeedClass {
  final String id;
  final String name;
  final String board;
  const SeedClass({required this.id, required this.name, required this.board});
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'board': board};
}

class SeedSubtopic {
  final String id;
  final String topicId;
  final String name;
  final String description;
  final String difficulty;
  final List<MCQuestion> questions;

  const SeedSubtopic({
    required this.id,
    required this.topicId,
    required this.name,
    required this.description,
    this.difficulty = 'Medium',
    this.questions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic_id': topicId,
        'name': name,
        'description': description,
        'difficulty': difficulty,
      };
}

class SeedTopic {
  final String id;
  final String subjectId;
  final String name;
  final String subject;
  final String grade;
  final String description;
  final String difficulty;
  final List<SeedSubtopic> subtopics;
  final List<MCQuestion> questions;

  const SeedTopic({
    required this.id,
    this.subjectId = '',
    required this.name,
    required this.subject,
    required this.grade,
    required this.description,
    this.difficulty = 'Medium',
    this.subtopics = const [],
    this.questions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject_id': subjectId,
        'name': name,
        'subject': subject,
        'grade': grade,
        'description': description,
        'difficulty': difficulty,
        'subtopics': subtopics.map((s) => s.toJson()).toList(),
      };
}

abstract final class CurriculumSeedCatalog {
  static const List<SeedClass> classes = [
    SeedClass(id: '00000010-0003-0000-0000-000000000000', name: 'Class 10', board: 'BSEB'),
    SeedClass(id: '00000010-0001-0000-0000-000000000000', name: 'Class 10', board: 'CBSE'),
    SeedClass(id: '00000010-0005-0000-0000-000000000000', name: 'Class 10', board: 'DBSE'),
    SeedClass(id: '00000010-0002-0000-0000-000000000000', name: 'Class 10', board: 'ICSE'),
    SeedClass(id: '00000010-0004-0000-0000-000000000000', name: 'Class 10', board: 'WBBSE'),
    SeedClass(id: '00000011-0003-0000-0000-000000000000', name: 'Class 11', board: 'BSEB'),
    SeedClass(id: '00000011-0001-0000-0000-000000000000', name: 'Class 11', board: 'CBSE'),
    SeedClass(id: '00000011-0005-0000-0000-000000000000', name: 'Class 11', board: 'DBSE'),
    SeedClass(id: '00000011-0002-0000-0000-000000000000', name: 'Class 11', board: 'ICSE'),
    SeedClass(id: '00000011-0004-0000-0000-000000000000', name: 'Class 11', board: 'WBBSE'),
    SeedClass(id: '00000012-0003-0000-0000-000000000000', name: 'Class 12', board: 'BSEB'),
    SeedClass(id: '00000012-0001-0000-0000-000000000000', name: 'Class 12', board: 'CBSE'),
    SeedClass(id: '00000012-0005-0000-0000-000000000000', name: 'Class 12', board: 'DBSE'),
    SeedClass(id: '00000012-0002-0000-0000-000000000000', name: 'Class 12', board: 'ICSE'),
    SeedClass(id: '00000012-0004-0000-0000-000000000000', name: 'Class 12', board: 'WBBSE'),
    SeedClass(id: '00000005-0003-0000-0000-000000000000', name: 'Class 5', board: 'BSEB'),
    SeedClass(id: '00000005-0001-0000-0000-000000000000', name: 'Class 5', board: 'CBSE'),
    SeedClass(id: '00000005-0005-0000-0000-000000000000', name: 'Class 5', board: 'DBSE'),
    SeedClass(id: '00000005-0002-0000-0000-000000000000', name: 'Class 5', board: 'ICSE'),
    SeedClass(id: '00000005-0004-0000-0000-000000000000', name: 'Class 5', board: 'WBBSE'),
    SeedClass(id: '00000006-0003-0000-0000-000000000000', name: 'Class 6', board: 'BSEB'),
    SeedClass(id: '00000006-0001-0000-0000-000000000000', name: 'Class 6', board: 'CBSE'),
    SeedClass(id: '00000006-0005-0000-0000-000000000000', name: 'Class 6', board: 'DBSE'),
    SeedClass(id: '00000006-0002-0000-0000-000000000000', name: 'Class 6', board: 'ICSE'),
    SeedClass(id: '00000006-0004-0000-0000-000000000000', name: 'Class 6', board: 'WBBSE'),
    SeedClass(id: '00000007-0003-0000-0000-000000000000', name: 'Class 7', board: 'BSEB'),
    SeedClass(id: '00000007-0001-0000-0000-000000000000', name: 'Class 7', board: 'CBSE'),
    SeedClass(id: '00000007-0005-0000-0000-000000000000', name: 'Class 7', board: 'DBSE'),
    SeedClass(id: '00000007-0002-0000-0000-000000000000', name: 'Class 7', board: 'ICSE'),
    SeedClass(id: '00000007-0004-0000-0000-000000000000', name: 'Class 7', board: 'WBBSE'),
    SeedClass(id: '00000008-0003-0000-0000-000000000000', name: 'Class 8', board: 'BSEB'),
    SeedClass(id: '00000008-0001-0000-0000-000000000000', name: 'Class 8', board: 'CBSE'),
    SeedClass(id: '00000008-0005-0000-0000-000000000000', name: 'Class 8', board: 'DBSE'),
    SeedClass(id: '00000008-0002-0000-0000-000000000000', name: 'Class 8', board: 'ICSE'),
    SeedClass(id: '00000008-0004-0000-0000-000000000000', name: 'Class 8', board: 'WBBSE'),
    SeedClass(id: '00000009-0003-0000-0000-000000000000', name: 'Class 9', board: 'BSEB'),
    SeedClass(id: '00000009-0001-0000-0000-000000000000', name: 'Class 9', board: 'CBSE'),
    SeedClass(id: '00000009-0005-0000-0000-000000000000', name: 'Class 9', board: 'DBSE'),
    SeedClass(id: '00000009-0002-0000-0000-000000000000', name: 'Class 9', board: 'ICSE'),
    SeedClass(id: '00000009-0004-0000-0000-000000000000', name: 'Class 9', board: 'WBBSE'),
  ];

  static final List<SeedTopic> topics = [
    SeedTopic(
      id: 'b0000005-0001-0000-0000-000000000001',
      subjectId: 'a0000005-0001-0000-0000-000000000001',
      name: 'Numbers & Fractions',
      subject: 'Mathematics',
      grade: 'Class 5',
      description: 'Place value, large numbers, and fractional operations',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0001-0000-0000-000000000001', topicId: 'b0000005-0001-0000-0000-000000000001', name: 'Place Value & Operations', description: 'Indian & international place value, rounding off', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000005-0001-0000-0000-000000000002', topicId: 'b0000005-0001-0000-0000-000000000001', name: 'Fraction Operations', description: 'Like/unlike fractions, addition, mixed numbers', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Numbers & Fractions in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Numbers & Fractions.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0001-0000-0000-000000000002',
      subjectId: 'a0000005-0001-0000-0000-000000000001',
      name: 'Shapes, Area & Perimeter',
      subject: 'Mathematics',
      grade: 'Class 5',
      description: 'Geometric angles, 2D shapes, and perimeter calculation',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0001-0000-0000-000000000003', topicId: 'b0000005-0001-0000-0000-000000000002', name: 'Geometric Angles', description: 'Classification of acute, right, obtuse angles', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000005-0001-0000-0000-000000000004', topicId: 'b0000005-0001-0000-0000-000000000002', name: 'Perimeter & Area', description: 'Calculations for rectangles and squares', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Shapes, Area & Perimeter in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Shapes, Area & Perimeter.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0002-0000-0000-000000000003',
      subjectId: 'a0000005-0002-0000-0000-000000000002',
      name: 'Plant Life & Adaptation',
      subject: 'General Science',
      grade: 'Class 5',
      description: 'Germination, photosynthesis, and habitats',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0002-0000-0000-000000000005', topicId: 'b0000005-0002-0000-0000-000000000003', name: 'Plant Nutrition & Dispersal', description: 'Photosynthesis, chlorophyll, seed dispersal methods', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000005-0002-0000-0000-000000000006', topicId: 'b0000005-0002-0000-0000-000000000003', name: 'Aquatic & Desert Plants', description: 'Hydrophytes, xerophytes, and root adaptations', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Plant Life & Adaptation in General Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Plant Life & Adaptation.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0002-0000-0000-000000000004',
      subjectId: 'a0000005-0002-0000-0000-000000000002',
      name: 'Human Organ Systems',
      subject: 'General Science',
      grade: 'Class 5',
      description: 'Digestion, skeletal system, and respiratory functions',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0002-0000-0000-000000000007', topicId: 'b0000005-0002-0000-0000-000000000004', name: 'Human Digestive Canal', description: 'Enzymes, stomach, small intestine, absorption', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000005-0002-0000-0000-000000000008', topicId: 'b0000005-0002-0000-0000-000000000004', name: 'Skeletal & Muscular System', description: 'Joint types, tendons, ligaments, and posture', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Human Organ Systems in General Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Human Organ Systems.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0003-0000-0000-000000000005',
      subjectId: 'a0000005-0003-0000-0000-000000000003',
      name: 'Globe & Maps',
      subject: 'Social Studies',
      grade: 'Class 5',
      description: 'Latitudes, longitudes, continents, and oceans',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0003-0000-0000-000000000009', topicId: 'b0000005-0003-0000-0000-000000000005', name: 'Latitudes & Longitudes', description: 'Equator, meridians, time zones, hemispheres', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000005-0003-0000-0000-000000000010', topicId: 'b0000005-0003-0000-0000-000000000005', name: 'Continents & Oceans', description: 'Global landmasses, trenches, ocean currents', difficulty: 'Easy'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Globe & Maps in Social Studies?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Globe & Maps.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0003-0000-0000-000000000006',
      subjectId: 'a0000005-0003-0000-0000-000000000003',
      name: 'Indian Freedom Movement',
      subject: 'Social Studies',
      grade: 'Class 5',
      description: 'Pivotal national leaders, 1857 revolt, and independence',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0003-0000-0000-000000000011', topicId: 'b0000005-0003-0000-0000-000000000006', name: '1857 Uprising Leaders', description: 'Mangal Pandey, Rani Lakshmibai, Nana Sahib', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000005-0003-0000-0000-000000000012', topicId: 'b0000005-0003-0000-0000-000000000006', name: 'National Movement 1920-1947', description: 'Non-Cooperation, Dandi March, Independence', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Indian Freedom Movement in Social Studies?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Indian Freedom Movement.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0004-0000-0000-000000000007',
      subjectId: 'a0000005-0004-0000-0000-000000000004',
      name: 'Grammar Foundations',
      subject: 'English',
      grade: 'Class 5',
      description: 'Nouns, pronouns, adjectives, and verb agreement',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0004-0000-0000-000000000013', topicId: 'b0000005-0004-0000-0000-000000000007', name: 'Nouns & Pronouns', description: 'Collective nouns, abstract nouns, relative pronouns', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000005-0004-0000-0000-000000000014', topicId: 'b0000005-0004-0000-0000-000000000007', name: 'Prepositions & Articles', description: 'Prepositions of place, definite & indefinite articles', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Grammar Foundations in English?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Grammar Foundations.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000005-0004-0000-0000-000000000008',
      subjectId: 'a0000005-0004-0000-0000-000000000004',
      name: 'Vocabulary & Tenses',
      subject: 'English',
      grade: 'Class 5',
      description: 'Present, past, future tenses, and antonyms',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000005-0004-0000-0000-000000000015', topicId: 'b0000005-0004-0000-0000-000000000008', name: 'Tenses in Application', description: 'Present continuous, simple past, future forms', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000005-0004-0000-0000-000000000016', topicId: 'b0000005-0004-0000-0000-000000000008', name: 'Antonyms & Word Meanings', description: 'Lexical opposites, contextual meanings', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Vocabulary & Tenses in English?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Vocabulary & Tenses.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0001-0000-0000-000000000009',
      subjectId: 'a0000006-0001-0000-0000-000000000005',
      name: 'Integers & Number Line',
      subject: 'Mathematics',
      grade: 'Class 6',
      description: 'Negative numbers, absolute values, and arithmetic rules',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0001-0000-0000-000000000017', topicId: 'b0000006-0001-0000-0000-000000000009', name: 'Operations on Integers', description: 'Addition, subtraction, sign rules', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000006-0001-0000-0000-000000000018', topicId: 'b0000006-0001-0000-0000-000000000009', name: 'Number Line & Ordering', description: 'Ordering integers, distance between points', difficulty: 'Easy'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Integers & Number Line in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Integers & Number Line.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0001-0000-0000-000000000010',
      subjectId: 'a0000006-0001-0000-0000-000000000005',
      name: 'Introduction to Algebra & Ratio',
      subject: 'Mathematics',
      grade: 'Class 6',
      description: 'Variables, linear equations, ratios, and unitary method',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0001-0000-0000-000000000019', topicId: 'b0000006-0001-0000-0000-000000000010', name: 'Algebraic Statements', description: 'Writing terms, coefficients, constants', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000006-0001-0000-0000-000000000020', topicId: 'b0000006-0001-0000-0000-000000000010', name: 'Ratio & Unitary Method', description: 'Simplifying ratios, cost per unit calculations', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Introduction to Algebra & Ratio in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Introduction to Algebra & Ratio.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0002-0000-0000-000000000011',
      subjectId: 'a0000006-0002-0000-0000-000000000006',
      name: 'Components of Food & Separation',
      subject: 'Science',
      grade: 'Class 6',
      description: 'Nutrients, sedimentation, decantation, and filtration',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0002-0000-0000-000000000021', topicId: 'b0000006-0002-0000-0000-000000000011', name: 'Nutritional Deficiencies', description: 'Vitamins A, B, C, D deficiencies and sources', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000006-0002-0000-0000-000000000022', topicId: 'b0000006-0002-0000-0000-000000000011', name: 'Separation Techniques', description: 'Sieving, filtration, evaporation, winnowing', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Components of Food & Separation in Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Components of Food & Separation.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0002-0000-0000-000000000012',
      subjectId: 'a0000006-0002-0000-0000-000000000006',
      name: 'Electricity & Light',
      subject: 'Science',
      grade: 'Class 6',
      description: 'Circuits, conductors, rectilinear propagation of light',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0002-0000-0000-000000000023', topicId: 'b0000006-0002-0000-0000-000000000012', name: 'Electric Circuits & Switches', description: 'Circuit diagrams, switches, closed path flow', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000006-0002-0000-0000-000000000024', topicId: 'b0000006-0002-0000-0000-000000000012', name: 'Light, Shadows & Reflection', description: 'Pinhole camera, opaque/transparent bodies, mirrors', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Electricity & Light in Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Electricity & Light.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0003-0000-0000-000000000013',
      subjectId: 'a0000006-0003-0000-0000-000000000007',
      name: 'Early Civilizations & Ashoka',
      subject: 'Social Science',
      grade: 'Class 6',
      description: 'Harappan urbanism, Mauryan Empire, and Ashokan edicts',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0003-0000-0000-000000000025', topicId: 'b0000006-0003-0000-0000-000000000013', name: 'Harappan Town Architecture', description: 'Granary, Great Bath, baked bricks, seals', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000006-0003-0000-0000-000000000026', topicId: 'b0000006-0003-0000-0000-000000000013', name: 'Ashoka & Dhamma Policy', description: 'Kalinga war, rock edicts, Buddhist propagation', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Name the illustrious founder of the Mauryan Empire who was the grandfather of Emperor Ashoka.',
          options: ['Chandragupta Maurya', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Chandragupta Maurya.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0003-0000-0000-000000000014',
      subjectId: 'a0000006-0003-0000-0000-000000000007',
      name: 'Earth Domains & Diversity',
      subject: 'Social Science',
      grade: 'Class 6',
      description: 'Atmosphere, hydrosphere, government, and equality',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0003-0000-0000-000000000027', topicId: 'b0000006-0003-0000-0000-000000000014', name: 'Atmosphere & Lithosphere', description: 'Atmospheric zones, plateaus, mountains, plains', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000006-0003-0000-0000-000000000028', topicId: 'b0000006-0003-0000-0000-000000000014', name: 'Democratic Governance', description: 'Elections, rule of law, addressing discrimination', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which major relief landform is described as an elevated flat-topped tableland rising steeply above surrounding plains?',
          options: ['Plateau', 'Mountain range', 'River valley', 'Coastal plain'],
          correctIndex: 0,
          explanation: 'Correct answer is Plateau.',
        ),
        MCQuestion(
          id: 2,
          question: 'What narrow global zone of contact encompasses portions of the lithosphere, hydrosphere, and atmosphere where living organisms exist?',
          options: ['Biosphere', 'Exosphere', 'Cryosphere', 'Asthenosphere'],
          correctIndex: 0,
          explanation: 'Correct answer is Biosphere.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which stratospheric gas shield filters out carcinogenic ultraviolet (UV) radiation coming from the Sun?',
          options: ['Ozone layer', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Ozone layer.',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the highest mountain peak above sea level on Earth, towering in the Mahalangur Himal sub-range?',
          options: ['Mount Everest', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Mount Everest.',
        ),
        MCQuestion(
          id: 5,
          question: 'What core democratic principle guarantees that every citizen aged 18 or above has the constitutional right to vote without discrimination?',
          options: ['Universal Adult Franchise (Suffrage)', 'Dynastic Succession', 'Property Qualification', 'Proportional Representation'],
          correctIndex: 0,
          explanation: 'Correct answer is Universal Adult Franchise (Suffrage).',
        ),
        MCQuestion(
          id: 6,
          question: 'What is the customary statutory term of office for the Lok Sabha (Lower House of Parliament) in India before fresh elections?',
          options: ['5 years', '3 years', '4 years', '6 years'],
          correctIndex: 0,
          explanation: 'Correct answer is 5 years.',
        ),
        MCQuestion(
          id: 7,
          question: 'Which grassroots elected body forms the primary tier of rural local self-governance in Indian villages?',
          options: ['Gram Panchayat', 'Zila Parishad', 'Panchayat Samiti', 'Municipal Council'],
          correctIndex: 0,
          explanation: 'Correct answer is Gram Panchayat.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which independent branch of democratic government upholds fundamental rights and adjudicates constitutional disputes?',
          options: ['Judiciary', 'Executive', 'Legislature', 'Civil Service Bureaucracy'],
          correctIndex: 0,
          explanation: 'Correct answer is Judiciary.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0004-0000-0000-000000000015',
      subjectId: 'a0000006-0004-0000-0000-000000000008',
      name: 'Sentence Structure & Conjunctions',
      subject: 'English',
      grade: 'Class 6',
      description: 'Coordinating conjunctions, subordinate clauses, and idioms',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0004-0000-0000-000000000029', topicId: 'b0000006-0004-0000-0000-000000000015', name: 'Conjunctions & Compound Clauses', description: 'Coordinating linkers, compound sentences', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000006-0004-0000-0000-000000000030', topicId: 'b0000006-0004-0000-0000-000000000015', name: 'Complex Sentences & Clauses', description: 'Relative clauses (who, which, whose)', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which of the following sentences correctly links two independent clauses with a comma and coordinating conjunction?',
          options: ['The school bell rang, and the students hurried out to the field.', 'Because the school bell rang the students hurried out.', 'The school bell rang although the students hurried out.', 'The school bell rang when the students hurried out.'],
          correctIndex: 0,
          explanation: 'Correct answer is The school bell rang, and the students hurried out to the field..',
        ),
        MCQuestion(
          id: 2,
          question: 'What mnemonic acronym represents the seven coordinating conjunctions: For, And, Nor, But, Or, Yet, So?',
          options: ['FANBOYS', 'PEMDAS', 'HOMES', 'VIBGYOR'],
          correctIndex: 0,
          explanation: 'Correct answer is FANBOYS.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which of the following sentences represents a complex sentence containing an independent clause and a dependent clause?',
          options: ['When the train pulled into the station, the passengers stood up.', 'The train arrived and the passengers quickly boarded it.', 'The train blew its loud horn at the junction.', 'The train was late, but the passengers waited patiently.'],
          correctIndex: 0,
          explanation: 'Correct answer is When the train pulled into the station, the passengers stood up..',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000006-0004-0000-0000-000000000016',
      subjectId: 'a0000006-0004-0000-0000-000000000008',
      name: 'Voice & Direct Speech',
      subject: 'English',
      grade: 'Class 6',
      description: 'Active to passive voice conversions, reporting verbs',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000006-0004-0000-0000-000000000031', topicId: 'b0000006-0004-0000-0000-000000000016', name: 'Active & Passive Voice', description: 'Present, past, and modal auxiliary transformations', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000006-0004-0000-0000-000000000032', topicId: 'b0000006-0004-0000-0000-000000000016', name: 'Direct to Indirect Speech', description: 'Reporting statements, tense backshift basics', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Voice & Direct Speech in English?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Voice & Direct Speech.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0001-0000-0000-000000000017',
      subjectId: 'a0000007-0001-0000-0000-000000000009',
      name: 'Rational Numbers & Exponents',
      subject: 'Mathematics',
      grade: 'Class 7',
      description: 'Properties of rational numbers, laws of indices',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0001-0000-0000-000000000033', topicId: 'b0000007-0001-0000-0000-000000000017', name: 'Rational Number Arithmetic', description: 'Standard form, addition, multiplication of rationals', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000007-0001-0000-0000-000000000034', topicId: 'b0000007-0001-0000-0000-000000000017', name: 'Laws of Exponents', description: 'Power of a product, zero exponent, negative powers', difficulty: 'Easy'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Rational Numbers & Exponents in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Rational Numbers & Exponents.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0001-0000-0000-000000000018',
      subjectId: 'a0000007-0001-0000-0000-000000000009',
      name: 'Triangles & Algebraic Expressions',
      subject: 'Mathematics',
      grade: 'Class 7',
      description: 'Pythagoras theorem, exterior angles, algebraic terms',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0001-0000-0000-000000000035', topicId: 'b0000007-0001-0000-0000-000000000018', name: 'Properties of Triangles', description: 'Angle sum property, exterior angle theorem, Pythagoras', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000007-0001-0000-0000-000000000036', topicId: 'b0000007-0001-0000-0000-000000000018', name: 'Operations on Algebraic Expressions', description: 'Adding polynomials, finding values of expressions', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Triangles & Algebraic Expressions in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Triangles & Algebraic Expressions.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0002-0000-0000-000000000019',
      subjectId: 'a0000007-0002-0000-0000-000000000010',
      name: 'Nutrition & Chemical Changes',
      subject: 'Science',
      grade: 'Class 7',
      description: 'Autotrophic/heterotrophic nutrition, neutralization',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0002-0000-0000-000000000037', topicId: 'b0000007-0002-0000-0000-000000000019', name: 'Photosynthesis & Insectivorous Plants', description: 'Pitcher plant, saprotrophs, symbiotic fungi', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000007-0002-0000-0000-000000000038', topicId: 'b0000007-0002-0000-0000-000000000019', name: 'Acids, Bases and Indicators', description: 'Litmus paper, phenolphthalein, neutralization reaction', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which green photosynthetic pigment present in plant chloroplasts absorbs solar energy?',
          options: ['Chlorophyll', 'Anthocyanin', 'Xanthophyll', 'Carotene'],
          correctIndex: 0,
          explanation: 'Correct answer is Chlorophyll.',
        ),
        MCQuestion(
          id: 2,
          question: 'What are the microscopic pores surrounded by guard cells on leaf surfaces called?',
          options: ['Stomata', 'Lenticels', 'Hydathodes', 'Xylem vessels'],
          correctIndex: 0,
          explanation: 'Correct answer is Stomata.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which of the following plants is classified as an insectivorous plant?',
          options: ['Venus flytrap', 'Cuscuta (Amarbel)', 'Mushroom', 'Spirogyra'],
          correctIndex: 0,
          explanation: 'Correct answer is Venus flytrap.',
        ),
        MCQuestion(
          id: 4,
          question: 'Name the vital gas released by autotrophic green plants during photosynthesis.',
          options: ['Oxygen', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Oxygen.',
        ),
        MCQuestion(
          id: 5,
          question: 'Why do insectivorous plants trap and digest small insects even though they possess chlorophyll?',
          options: ['To obtain nitrogen compounds deficient in their boggy soil', 'Because they cannot synthesize carbohydrates via sunlight', 'To acquire extra water molecules during drought periods', 'To defend their floral petals against herbivorous animals'],
          correctIndex: 0,
          explanation: 'Correct answer is To obtain nitrogen compounds deficient in their boggy soil.',
        ),
        MCQuestion(
          id: 6,
          question: 'Name the common fungal organism that exhibits saprotrophic nutrition on stale moist bread.',
          options: ['Rhizopus (Bread mould)', 'Spirogyra', 'Amoeba', 'Paramecium'],
          correctIndex: 0,
          explanation: 'Correct answer is Rhizopus (Bread mould).',
        ),
        MCQuestion(
          id: 7,
          question: 'What characteristic taste is typically associated with acidic chemical substances?',
          options: ['Sour', 'Bitter', 'Sweet', 'Salty'],
          correctIndex: 0,
          explanation: 'Correct answer is Sour.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which natural organic acid is found in sour milk and curd?',
          options: ['Lactic acid', 'Citric acid', 'Tartaric acid', 'Oxalic acid'],
          correctIndex: 0,
          explanation: 'Correct answer is Lactic acid.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0002-0000-0000-000000000020',
      subjectId: 'a0000007-0002-0000-0000-000000000010',
      name: 'Heat Transfer & Circulatory System',
      subject: 'Science',
      grade: 'Class 7',
      description: 'Conduction, convection, radiation, heart and blood',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0002-0000-0000-000000000039', topicId: 'b0000007-0002-0000-0000-000000000020', name: 'Modes of Heat Transfer', description: 'Conduction in solids, convection in fluids, radiation', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000007-0002-0000-0000-000000000040', topicId: 'b0000007-0002-0000-0000-000000000020', name: 'Human Blood & Heart Function', description: 'RBCs, WBCs, platelets, chambers of heart, pulse rate', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which fundamental mode of heat transmission can take place through vacuum without requiring any physical medium?',
          options: ['Radiation', 'Conduction', 'Convection', 'Advection'],
          correctIndex: 0,
          explanation: 'Correct answer is Radiation.',
        ),
        MCQuestion(
          id: 2,
          question: 'In which state of matter does thermal energy transfer take place predominantly by conduction?',
          options: ['Solids', 'Liquids', 'Gases', 'Plasma'],
          correctIndex: 0,
          explanation: 'Correct answer is Solids.',
        ),
        MCQuestion(
          id: 3,
          question: 'Why does a sea breeze develop during daytime along coastal land masses?',
          options: ['Land warms up faster than sea water creating a low pressure zone over land', 'Sea water warms up faster than coastal land creating a vacuum above sea', 'Dense cold air over coastal mountains descends directly into the ocean', 'The Moon gravitational tidal pull displaces air masses inland'],
          correctIndex: 0,
          explanation: 'Correct answer is Land warms up faster than sea water creating a low pressure zone over land.',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the standard measurement temperature range of a human clinical thermometer in degrees Celsius?',
          options: ['35 degrees C to 42 degrees C', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 35 degrees C to 42 degrees C.',
        ),
        MCQuestion(
          id: 5,
          question: 'Why do thick woollen garments protect the human body effectively from severe winter cold?',
          options: ['Wool fibres trap stationary air which acts as an excellent insulator of heat', 'Wool fibres continuously generate internal chemical calories', 'Wool actively absorbs infrared electromagnetic radiation from surroundings', 'Wool speeds up convection currents between clothing layers'],
          correctIndex: 0,
          explanation: 'Correct answer is Wool fibres trap stationary air which acts as an excellent insulator of heat.',
        ),
        MCQuestion(
          id: 6,
          question: 'Name the heat transfer process occurring in fluids where heated warmer fluid rises and cooler denser fluid sinks.',
          options: ['Convection', 'Conduction', 'Radiation', 'Insulation'],
          correctIndex: 0,
          explanation: 'Correct answer is Convection.',
        ),
        MCQuestion(
          id: 7,
          question: 'How many distinct muscular pumping chambers exist in the human heart?',
          options: ['4 chambers', '3 chambers', '2 chambers', '6 chambers'],
          correctIndex: 0,
          explanation: 'Correct answer is 4 chambers.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which cellular component of blood acts as microscopic soldiers defending against disease-causing germs?',
          options: ['White Blood Cells (WBCs)', 'Red Blood Cells (RBCs)', 'Blood platelets (Thrombocytes)', 'Blood plasma proteins'],
          correctIndex: 0,
          explanation: 'Correct answer is White Blood Cells (WBCs).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0003-0000-0000-000000000021',
      subjectId: 'a0000007-0003-0000-0000-000000000011',
      name: 'Delhi Sultanate & Mughals',
      subject: 'Social Science',
      grade: 'Class 7',
      description: 'Raziya Sultan, Alauddin Khalji, Akbar administrative reforms',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0003-0000-0000-000000000041', topicId: 'b0000007-0003-0000-0000-000000000021', name: 'Rulers of Delhi Sultanate', description: 'Mamluk, Khalji, Tughlaq dynasties and administration', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000007-0003-0000-0000-000000000042', topicId: 'b0000007-0003-0000-0000-000000000021', name: 'Akbar Administrative System', description: 'Mansabdari system, Sulh-i Kul, revenue administration', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Who was the Turkish commander that founded the Slave (Mamluk) Dynasty in Delhi in 1206 CE?',
          options: ['Qutb-ud-din Aibak', 'Shams-ud-din Iltutmish', 'Ghiyas-ud-din Balban', 'Alauddin Khalji'],
          correctIndex: 0,
          explanation: 'Correct answer is Qutb-ud-din Aibak.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which Delhi Sultan notoriously transferred his imperial capital from Delhi to Daulatabad (Devagiri) in 1327 CE?',
          options: ['Muhammad bin Tughlaq', 'Firoz Shah Tughlaq', 'Ghiyas-ud-din Tughlaq', 'Bahlul Lodi'],
          correctIndex: 0,
          explanation: 'Correct answer is Muhammad bin Tughlaq.',
        ),
        MCQuestion(
          id: 3,
          question: 'What title was assigned to military commanders entrusted with revenue administration of territories (Iqtas) during the Sultanate?',
          options: ['Muqti or Iqtadar', 'Mansabdar', 'Subadar', 'Kotwal'],
          correctIndex: 0,
          explanation: 'Correct answer is Muqti or Iqtadar.',
        ),
        MCQuestion(
          id: 4,
          question: 'In which historic battle in 1526 did Babur defeat Ibrahim Lodi, bringing an end to the Delhi Sultanate?',
          options: ['First Battle of Panipat', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is First Battle of Panipat.',
        ),
        MCQuestion(
          id: 5,
          question: 'What agricultural tax on peasant crop yield (roughly amounting to 50 percent) was strictly levied by Alauddin Khalji?',
          options: ['Kharaj', 'Jizya', 'Zakat', 'Chauth'],
          correctIndex: 0,
          explanation: 'Correct answer is Kharaj.',
        ),
        MCQuestion(
          id: 6,
          question: 'Which thirteenth-century Persian court chronicler praised Raziya Sultan for being more competent than her brothers?',
          options: ['Minhaj-i Siraj', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Minhaj-i Siraj.',
        ),
        MCQuestion(
          id: 7,
          question: 'What were the administrative provinces called in the Mughal Empire under Emperor Akbar?',
          options: ['Subas', 'Sarkars', 'Parganas', 'Mahals'],
          correctIndex: 0,
          explanation: 'Correct answer is Subas.',
        ),
        MCQuestion(
          id: 8,
          question: 'Name the high-ranking imperial officer who served as the military paymaster in Akbar administration.',
          options: ['Mir Bakshi', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Mir Bakshi.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0003-0000-0000-000000000022',
      subjectId: 'a0000007-0003-0000-0000-000000000011',
      name: 'Atmosphere & Water Circulation',
      subject: 'Social Science',
      grade: 'Class 7',
      description: 'Hydrological cycle, ocean tides, atmospheric pressure',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0003-0000-0000-000000000043', topicId: 'b0000007-0003-0000-0000-000000000022', name: 'Composition of Air & Winds', description: 'Atmospheric pressure, planetary winds, cyclone basics', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000007-0003-0000-0000-000000000044', topicId: 'b0000007-0003-0000-0000-000000000022', name: 'Ocean Currents & Tides', description: 'Spring tides, neap tides, warm and cold ocean streams', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which gas forms the largest constituent of the Earth atmosphere, accounting for roughly 78 percent by volume?',
          options: ['Nitrogen', 'Oxygen', 'Carbon dioxide', 'Argon'],
          correctIndex: 0,
          explanation: 'Correct answer is Nitrogen.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which lowest atmospheric layer extends up to about 13 km where almost all rainfall, fog, and weather occur?',
          options: ['Troposphere', 'Stratosphere', 'Mesosphere', 'Thermosphere'],
          correctIndex: 0,
          explanation: 'Correct answer is Troposphere.',
        ),
        MCQuestion(
          id: 3,
          question: 'Why is the stratosphere considered ideal for flying commercial passenger jet aeroplanes?',
          options: ['It is largely devoid of clouds and turbulent convective weather phenomena', 'It contains dense oxygen gas facilitating combustion without turbines', 'It has zero gravitational pull allowing aircraft to float effortlessly', 'It experiences strong downward gravitational winds preventing stalls'],
          correctIndex: 0,
          explanation: 'Correct answer is It is largely devoid of clouds and turbulent convective weather phenomena.',
        ),
        MCQuestion(
          id: 4,
          question: 'Name the meteorological instrument fitted with an arrow used to indicate the exact direction of prevailing winds.',
          options: ['Wind vane', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Wind vane.',
        ),
        MCQuestion(
          id: 5,
          question: 'What are the trade winds, westerlies, and easterlies that blow consistently throughout the year termed?',
          options: ['Permanent or planetary winds', 'Seasonal monsoon winds', 'Local breeze winds', 'Cyclonic gust winds'],
          correctIndex: 0,
          explanation: 'Correct answer is Permanent or planetary winds.',
        ),
        MCQuestion(
          id: 6,
          question: 'What is the searing, scorching local summer wind blowing across the northern plains of India called?',
          options: ['Loo', 'Mistral', 'Chinook', 'Harmattan'],
          correctIndex: 0,
          explanation: 'Correct answer is Loo.',
        ),
        MCQuestion(
          id: 7,
          question: 'What are exceptionally high ocean tides occurring when the Sun, Moon, and Earth align in a straight line called?',
          options: ['Spring tides', 'Neap tides', 'Diurnal tides', 'Ebb currents'],
          correctIndex: 0,
          explanation: 'Correct answer is Spring tides.',
        ),
        MCQuestion(
          id: 8,
          question: 'When the Moon is in its first or third quarter, the gravitational forces of the Sun and Moon act perpendicular to each other causing:',
          options: ['Neap tides', 'Spring tides', 'Tsunami surges', 'Equatorial swells'],
          correctIndex: 0,
          explanation: 'Correct answer is Neap tides.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0004-0000-0000-000000000023',
      subjectId: 'a0000007-0004-0000-0000-000000000012',
      name: 'Modals & Active-Passive',
      subject: 'English',
      grade: 'Class 7',
      description: 'Can, could, must, should, passive voice transformations',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0004-0000-0000-000000000045', topicId: 'b0000007-0004-0000-0000-000000000023', name: 'Modal Auxiliaries', description: 'Expressing obligation, possibility, ability with modals', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000007-0004-0000-0000-000000000046', topicId: 'b0000007-0004-0000-0000-000000000023', name: 'Passive with Continuous Tenses', description: 'Transforming present/past continuous into passive', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which modal auxiliary verb is correctly used to express general physical ability in the past?',
          options: ['Could', 'Can', 'May', 'Shall'],
          correctIndex: 0,
          explanation: 'Correct answer is Could.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000007-0004-0000-0000-000000000024',
      subjectId: 'a0000007-0004-0000-0000-000000000012',
      name: 'Direct and Indirect Speech',
      subject: 'English',
      grade: 'Class 7',
      description: 'Reporting commands, interrogatives, statement conversion',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000007-0004-0000-0000-000000000047', topicId: 'b0000007-0004-0000-0000-000000000024', name: 'Indirect Speech for Questions', description: 'Conversion of Wh-questions and Yes/No questions', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000007-0004-0000-0000-000000000048', topicId: 'b0000007-0004-0000-0000-000000000024', name: 'Indirect Speech for Imperatives', description: 'Reporting commands, requests, and warnings', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Direct and Indirect Speech in English?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Direct and Indirect Speech.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0001-0000-0000-000000000025',
      subjectId: 'a0000008-0001-0000-0000-000000000013',
      name: 'Linear Equations & Quadrilaterals',
      subject: 'Mathematics',
      grade: 'Class 8',
      description: 'Transposition, angle sum property, parallelogram rules',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0001-0000-0000-000000000049', topicId: 'b0000008-0001-0000-0000-000000000025', name: 'Linear Equations with Variables on Both Sides', description: 'Solving equations, cross multiplication', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000008-0001-0000-0000-000000000050', topicId: 'b0000008-0001-0000-0000-000000000025', name: 'Types of Quadrilaterals & Angles', description: 'Trapezium, rhombus, rectangle, diagonal properties', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Solve the linear equation for x: 5x + 9 = 2x + 24.',
          options: ['5', '3', '7', '4'],
          correctIndex: 0,
          explanation: 'Correct answer is 5.',
        ),
        MCQuestion(
          id: 2,
          question: 'Solve for x: (2x + 1) / (3x - 2) = 5/9.',
          options: ['-19/3', '19/3', '-3/19', '7'],
          correctIndex: 0,
          explanation: 'Correct answer is -19/3.',
        ),
        MCQuestion(
          id: 3,
          question: 'Solve the decimal linear equation: 0.25(4f - 3) = 0.05(10f - 9). What is f?',
          options: ['0.6', '0.8', '1.2', '0.4'],
          correctIndex: 0,
          explanation: 'Correct answer is 0.6.',
        ),
        MCQuestion(
          id: 4,
          question: 'Solve for y: 7y - 4 = 3y + 16.',
          options: ['5', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 5.',
        ),
        MCQuestion(
          id: 5,
          question: 'The perimeter of a rectangle is 40 cm. If its length is 4 cm greater than its breadth, find the breadth.',
          options: ['8 cm', '12 cm', '10 cm', '6 cm'],
          correctIndex: 0,
          explanation: 'Correct answer is 8 cm.',
        ),
        MCQuestion(
          id: 6,
          question: 'Solve the linear equation for x: (x - 5)/3 = (x - 3)/5.',
          options: ['8', '6', '10', '4'],
          correctIndex: 0,
          explanation: 'Correct answer is 8.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the sum of the measures of the exterior angles of any convex polygon?',
          options: ['360 degrees', '180 degrees', '540 degrees', '720 degrees'],
          correctIndex: 0,
          explanation: 'Correct answer is 360 degrees.',
        ),
        MCQuestion(
          id: 8,
          question: 'A parallelogram having all four sides of equal length and diagonals perpendicular to each other is a:',
          options: ['Rhombus', 'Trapezium', 'Kite', 'Scalene quadrilateral'],
          correctIndex: 0,
          explanation: 'Correct answer is Rhombus.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0001-0000-0000-000000000026',
      subjectId: 'a0000008-0001-0000-0000-000000000013',
      name: 'Mensuration & Algebraic Identities',
      subject: 'Mathematics',
      grade: 'Class 8',
      description: 'Cylinder, cone, surface area, (a+b)^2, factorisation',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0001-0000-0000-000000000051', topicId: 'b0000008-0001-0000-0000-000000000026', name: 'Standard Algebraic Identities', description: '(a+b)^2, (a-b)^2, and (a^2-b^2) expansions', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000008-0001-0000-0000-000000000052', topicId: 'b0000008-0001-0000-0000-000000000026', name: 'Solid Figures & Mensuration', description: 'Surface area and volume of cuboids and cylinders', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which of the following standard algebraic identities correctly represents (a - b)^2?',
          options: ['a^2 - 2ab + b^2', 'a^2 + 2ab + b^2', 'a^2 - b^2', 'a^2 - 2ab - b^2'],
          correctIndex: 0,
          explanation: 'Correct answer is a^2 - 2ab + b^2.',
        ),
        MCQuestion(
          id: 2,
          question: 'Evaluate (103)^2 by applying the identity (a + b)^2 = a^2 + 2ab + b^2.',
          options: ['10,609', '10,909', '10,309', '10,606'],
          correctIndex: 0,
          explanation: 'Correct answer is 10,609.',
        ),
        MCQuestion(
          id: 3,
          question: 'Factorise the difference of squares: 49x^2 - 36.',
          options: ['(7x - 6)(7x + 6)', '(7x - 6)^2', '(7x + 6)^2', '(49x - 6)(x + 6)'],
          correctIndex: 0,
          explanation: 'Correct answer is (7x - 6)(7x + 6).',
        ),
        MCQuestion(
          id: 4,
          question: 'Expand using the appropriate algebraic identity: (2x + 5y)^2.',
          options: ['4x^2 + 20xy + 25y^2', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 4x^2 + 20xy + 25y^2.',
        ),
        MCQuestion(
          id: 5,
          question: 'If x + 1/x = 5, calculate the value of x^2 + 1/x^2.',
          options: ['23', '25', '27', '21'],
          correctIndex: 0,
          explanation: 'Correct answer is 23.',
        ),
        MCQuestion(
          id: 6,
          question: 'Compute the product 98 * 102 by applying the identity (a - b)(a + b) = a^2 - b^2.',
          options: ['9996', '9986', '9994', '10004'],
          correctIndex: 0,
          explanation: 'Correct answer is 9996.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the formula for the curved surface area (CSA) of a right circular cylinder with radius r and height h?',
          options: ['2 * pi * r * h', 'pi * r^2 * h', '2 * pi * r * (r + h)', '4 * pi * r^2'],
          correctIndex: 0,
          explanation: 'Correct answer is 2 * pi * r * h.',
        ),
        MCQuestion(
          id: 8,
          question: 'Find the total surface area of a cube whose side edge length is 5 cm.',
          options: ['150 cm^2', '125 cm^2', '100 cm^2', '175 cm^2'],
          correctIndex: 0,
          explanation: 'Correct answer is 150 cm^2.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0002-0000-0000-000000000027',
      subjectId: 'a0000008-0002-0000-0000-000000000014',
      name: 'Microorganisms & Crop Management',
      subject: 'Science',
      grade: 'Class 8',
      description: 'Bacteria, fungi, vaccines, drip irrigation, fertilizers',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0002-0000-0000-000000000053', topicId: 'b0000008-0002-0000-0000-000000000027', name: 'Agricultural Implements & Irrigation', description: 'Sowing, seed drill, drip system, sprinkler system', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000008-0002-0000-0000-000000000054', topicId: 'b0000008-0002-0000-0000-000000000027', name: 'Beneficial & Harmful Microbes', description: 'Lactobacillus, penicillin, fermentation, pathogens', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which modern tractor-driven agricultural implement is widely used for ploughing and turning soil efficiently?',
          options: ['Cultivator', 'Sickle', 'Khurpi', 'Combine harvester'],
          correctIndex: 0,
          explanation: 'Correct answer is Cultivator.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which water-saving irrigation method delivers water like artificial rain and is ideal for uneven land?',
          options: ['Sprinkler system', 'Moat (pulley system)', 'Chain pump', 'Rahat (lever system)'],
          correctIndex: 0,
          explanation: 'Correct answer is Sprinkler system.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the post-harvest agricultural process of separating edible grain seeds from husk and chaff?',
          options: ['Threshing and winnowing', 'Tilling and harrowing', 'Weeding and hoeing', 'Levelling and harrowing'],
          correctIndex: 0,
          explanation: 'Correct answer is Threshing and winnowing.',
        ),
        MCQuestion(
          id: 4,
          question: 'Name the seasonal crops sown during the monsoon season from June to September in India.',
          options: ['Kharif crops', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Kharif crops.',
        ),
        MCQuestion(
          id: 5,
          question: 'Which organic manure is prepared by utilizing earthworms to decompose biodegradable organic farm matter?',
          options: ['Vermicompost', 'Urea fertiliser', 'Superphosphate', 'Potassium chloride'],
          correctIndex: 0,
          explanation: 'Correct answer is Vermicompost.',
        ),
        MCQuestion(
          id: 6,
          question: 'Name the agricultural tool used for sowing seeds uniformly at proper depths and equal intervals.',
          options: ['Seed drill', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Seed drill.',
        ),
        MCQuestion(
          id: 7,
          question: 'Which bacterial microorganism multiplies in warm milk and promotes its curdling into yogurt?',
          options: ['Lactobacillus', 'Rhizobium', 'Bacillus anthracis', 'Streptococcus pneumoniae'],
          correctIndex: 0,
          explanation: 'Correct answer is Lactobacillus.',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the biological conversion of natural sugars into alcohol and carbon dioxide by yeast called?',
          options: ['Fermentation', 'Pasteurization', 'Nitrogen fixation', 'Sterilization'],
          correctIndex: 0,
          explanation: 'Correct answer is Fermentation.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0002-0000-0000-000000000028',
      subjectId: 'a0000008-0002-0000-0000-000000000014',
      name: 'Forces, Pressure & Sound',
      subject: 'Science',
      grade: 'Class 8',
      description: 'Atmospheric pressure, friction reduction, sound frequency',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0002-0000-0000-000000000055', topicId: 'b0000008-0002-0000-0000-000000000028', name: 'Contact and Non-Contact Forces', description: 'Gravitation, electrostatic force, normal reaction', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000008-0002-0000-0000-000000000056', topicId: 'b0000008-0002-0000-0000-000000000028', name: 'Sound Waves & Human Hearing', description: 'Frequency, pitch, amplitude, loudness in decibels', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'What is the standard International System (SI) unit of physical force?',
          options: ['Newton (N)', 'Pascal (Pa)', 'Joule (J)', 'Watt (W)'],
          correctIndex: 0,
          explanation: 'Correct answer is Newton (N).',
        ),
        MCQuestion(
          id: 2,
          question: 'Which of the following forces represents a direct contact mechanical force?',
          options: ['Muscular force', 'Gravitational force', 'Electrostatic force', 'Magnetic force'],
          correctIndex: 0,
          explanation: 'Correct answer is Muscular force.',
        ),
        MCQuestion(
          id: 3,
          question: 'In classical physics, how is mechanical pressure mathematically defined?',
          options: ['Thrust force acting per unit surface area', 'Force multiplied by the contact area', 'Mass per unit volume of an object', 'Work accomplished per unit of time'],
          correctIndex: 0,
          explanation: 'Correct answer is Thrust force acting per unit surface area.',
        ),
        MCQuestion(
          id: 4,
          question: 'What contact force consistently opposes the relative sliding or rolling motion between two surfaces?',
          options: ['Friction', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Friction.',
        ),
        MCQuestion(
          id: 5,
          question: 'If a perpendicular force of 400 N is exerted across an area of 0.02 m^2, calculate the resulting pressure.',
          options: ['20,000 Pascals', '8,000 Pascals', '4,000 Pascals', '800 Pascals'],
          correctIndex: 0,
          explanation: 'Correct answer is 20,000 Pascals.',
        ),
        MCQuestion(
          id: 6,
          question: 'What non-contact force is exerted between stationary electrical charges on rubbed insulating objects?',
          options: ['Electrostatic force', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Electrostatic force.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the normal audible frequency range of acoustic waves perceptible to the average human ear?',
          options: ['20 Hz to 20,000 Hz', '5 Hz to 500 Hz', '100 Hz to 100,000 Hz', '10 Hz to 1,000 Hz'],
          correctIndex: 0,
          explanation: 'Correct answer is 20 Hz to 20,000 Hz.',
        ),
        MCQuestion(
          id: 8,
          question: 'The physiological loudness or intensity of a sound wave is primarily determined by its:',
          options: ['Amplitude of vibration', 'Wave frequency', 'Acoustic pitch', 'Speed in air'],
          correctIndex: 0,
          explanation: 'Correct answer is Amplitude of vibration.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0003-0000-0000-000000000029',
      subjectId: 'a0000008-0003-0000-0000-000000000015',
      name: 'Indian Constitution & Secularism',
      subject: 'Social Science',
      grade: 'Class 8',
      description: 'Fundamental Rights, separation of powers, judicial review',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0003-0000-0000-000000000057', topicId: 'b0000008-0003-0000-0000-000000000029', name: 'Key Features of Constitution', description: 'Federalism, parliamentary form, separation of powers', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000008-0003-0000-0000-000000000058', topicId: 'b0000008-0003-0000-0000-000000000029', name: 'Role of the Independent Judiciary', description: 'Supreme Court, High Courts, PIL, judicial independence', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Who was the Chairman of the Drafting Committee of the Constituent Assembly, known as the Father of the Indian Constitution?',
          options: ['Dr. B.R. Ambedkar', 'Mahatma Gandhi', 'Jawaharlal Nehru', 'Dr. Rajendra Prasad'],
          correctIndex: 0,
          explanation: 'Correct answer is Dr. B.R. Ambedkar.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which Fundamental Right in the Constitution of India guarantees the freedom of conscience and religious practice to all individuals?',
          options: ['Right to Freedom of Religion (Articles 25-28)', 'Right to Equality (Articles 14-18)', 'Cultural and Educational Rights (Articles 29-30)', 'Right against Exploitation (Articles 23-24)'],
          correctIndex: 0,
          explanation: 'Correct answer is Right to Freedom of Religion (Articles 25-28).',
        ),
        MCQuestion(
          id: 3,
          question: 'In which calendar year did the Constitution of India formally come into operational effect on Republic Day?',
          options: ['1950', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 1950.',
        ),
        MCQuestion(
          id: 4,
          question: 'What constitutional term designates the existence of more than one level of government (Union and State) in India?',
          options: ['Federalism', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Federalism.',
        ),
        MCQuestion(
          id: 5,
          question: 'Which judicial institution stands at the apex of the integrated judicial hierarchy in the Republic of India?',
          options: ['Supreme Court of India', 'State High Court', 'District and Sessions Court', 'National Green Tribunal'],
          correctIndex: 0,
          explanation: 'Correct answer is Supreme Court of India.',
        ),
        MCQuestion(
          id: 6,
          question: 'In which metropolitan city is the permanent seat of the Supreme Court of India located?',
          options: ['New Delhi', 'Mumbai', 'Kolkata', 'Chennai'],
          correctIndex: 0,
          explanation: 'Correct answer is New Delhi.',
        ),
        MCQuestion(
          id: 7,
          question: 'What judicial innovation devised in the early 1980s allows citizens to file cases directly on behalf of underprivileged groups?',
          options: ['Public Interest Litigation (PIL)', 'Habeas Corpus Petition', 'Caveat Petition', 'Special Leave Petition'],
          correctIndex: 0,
          explanation: 'Correct answer is Public Interest Litigation (PIL).',
        ),
        MCQuestion(
          id: 8,
          question: 'Name the highest ranking judicial official who presides over the Supreme Court of India.',
          options: ['Chief Justice of India', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Chief Justice of India.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0003-0000-0000-000000000030',
      subjectId: 'a0000008-0003-0000-0000-000000000015',
      name: 'Mineral & Power Resources',
      subject: 'Social Science',
      grade: 'Class 8',
      description: 'Metallic/non-metallic minerals, thermal and solar power',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0003-0000-0000-000000000059', topicId: 'b0000008-0003-0000-0000-000000000030', name: 'Types of Natural Resources', description: 'Renewable vs non-renewable, conservation methods', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000008-0003-0000-0000-000000000060', topicId: 'b0000008-0003-0000-0000-000000000030', name: 'Classification of Industries', description: 'Agro-based, mineral-based, cottage, public/private sector', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Which Asian country ranks as the leading global producer of iron ore, lead, zinc, and tin?',
          options: ['China', 'Japan', 'Indonesia', 'Malaysia'],
          correctIndex: 0,
          explanation: 'Correct answer is China.',
        ),
        MCQuestion(
          id: 2,
          question: 'What non-conventional renewable energy utilizes hydrothermal steam and heat tapped from deep within Earth magma?',
          options: ['Geothermal energy', 'Tidal energy', 'Biomass gas', 'Nuclear fission'],
          correctIndex: 0,
          explanation: 'Correct answer is Geothermal energy.',
        ),
        MCQuestion(
          id: 3,
          question: 'Name the primary reddish rock ore mined for the commercial smelting of aluminium metal.',
          options: ['Bauxite', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Bauxite.',
        ),
        MCQuestion(
          id: 4,
          question: 'What term is used for electricity generated by water rushing through high dam turbines?',
          options: ['Hydroelectricity', 'Thermal power', 'Geothermal power', 'Nuclear power'],
          correctIndex: 0,
          explanation: 'Correct answer is Hydroelectricity.',
        ),
        MCQuestion(
          id: 5,
          question: 'In which geographic region of California is the world famous tech agglomeration Silicon Valley located?',
          options: ['Santa Clara Valley', 'Death Valley', 'San Joaquin Valley', 'Sacramento Valley'],
          correctIndex: 0,
          explanation: 'Correct answer is Santa Clara Valley.',
        ),
        MCQuestion(
          id: 6,
          question: 'To which sector of economic activities does manufacturing finished commodities from raw natural resources belong?',
          options: ['Secondary sector', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Secondary sector.',
        ),
        MCQuestion(
          id: 7,
          question: 'In which industrial category do traditional pottery, handloom weaving, and bamboo handicraft businesses fall?',
          options: ['Cottage or household industries', 'Large-scale public sector industries', 'Joint sector ventures', 'Cooperative corporate sector'],
          correctIndex: 0,
          explanation: 'Correct answer is Cottage or household industries.',
        ),
        MCQuestion(
          id: 8,
          question: 'Name the pioneering private steel company established in 1907 at Sakchi (now Jamshedpur) by Jamsetji Tata.',
          options: ['TISCO (Tata Iron and Steel Company)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is TISCO (Tata Iron and Steel Company).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0004-0000-0000-000000000031',
      subjectId: 'a0000008-0004-0000-0000-000000000016',
      name: 'Subject-Verb Concord & Clauses',
      subject: 'English',
      grade: 'Class 8',
      description: 'Compound subjects, either/neither rules, noun clauses',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0004-0000-0000-000000000061', topicId: 'b0000008-0004-0000-0000-000000000031', name: 'Rules of Subject-Verb Agreement', description: 'Compound subjects, collective nouns, neither-nor rules', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000008-0004-0000-0000-000000000062', topicId: 'b0000008-0004-0000-0000-000000000031', name: 'Noun and Adverbial Clauses', description: 'Identification and synthesis of complex clauses', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Select the grammatically accurate sentence showing proper subject-verb agreement:',
          options: ['The quality of these organic Kashmiri apples was exceptional.', 'The quality of these organic Kashmiri apples were exceptional.', 'The qualities of this organic Kashmiri apple was poor.', 'The quality of these organic Kashmiri apples are having praise.'],
          correctIndex: 0,
          explanation: 'Correct answer is The quality of these organic Kashmiri apples was exceptional..',
        ),
        MCQuestion(
          id: 2,
          question: 'Identify the sentence that contains a noun clause functioning as the object of a preposition:',
          options: ['Pay close attention to what your mentor advises.', 'The ancient manuscript which is in the glass display is fragile.', 'Because he was ill, he missed the chemistry practical exam.', 'I reached the airport after the flight had departed.'],
          correctIndex: 0,
          explanation: 'Correct answer is Pay close attention to what your mentor advises..',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000008-0004-0000-0000-000000000032',
      subjectId: 'a0000008-0004-0000-0000-000000000016',
      name: 'Phrasal Verbs & Vocabulary',
      subject: 'English',
      grade: 'Class 8',
      description: 'Common idioms, phrasal combinations, context clues',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000008-0004-0000-0000-000000000063', topicId: 'b0000008-0004-0000-0000-000000000032', name: 'Common Phrasal Verbs', description: 'Look after, bring up, give in, put off usages', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000008-0004-0000-0000-000000000064', topicId: 'b0000008-0004-0000-0000-000000000032', name: 'Idiomatic Expressions', description: 'Contextual usage of literary and spoken idioms', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Phrasal Verbs & Vocabulary in English?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Phrasal Verbs & Vocabulary.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0001-0000-0000-000000000033',
      subjectId: 'a0000009-0001-0000-0000-000000000017',
      name: 'Number Systems & Polynomials',
      subject: 'Mathematics',
      grade: 'Class 9',
      description: 'Irrational numbers, real numbers, remainder theorem, factor theorem',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0001-0000-0000-000000000065', topicId: 'b0000009-0001-0000-0000-000000000033', name: 'Irrational Numbers & Real Lines', description: 'Proving irrationality, rationalizing denominators', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000009-0001-0000-0000-000000000066', topicId: 'b0000009-0001-0000-0000-000000000033', name: 'Factorization of Polynomials', description: 'Splitting middle term, algebraic identities', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Number Systems & Polynomials in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Number Systems & Polynomials.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0001-0000-0000-000000000034',
      subjectId: 'a0000009-0001-0000-0000-000000000017',
      name: 'Coordinate Geometry & Triangles',
      subject: 'Mathematics',
      grade: 'Class 9',
      description: 'Cartesian plane, congruency criteria (SAS, ASA, SSS, RHS)',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0001-0000-0000-000000000067', topicId: 'b0000009-0001-0000-0000-000000000034', name: 'Cartesian Coordinates & Quadrants', description: 'Abscissa, ordinate, plotting points on plane', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000009-0001-0000-0000-000000000068', topicId: 'b0000009-0001-0000-0000-000000000034', name: 'Congruence Criteria of Triangles', description: 'SAS, ASA, AAS, SSS, RHS congruence proofs', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Coordinate Geometry & Triangles in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Coordinate Geometry & Triangles.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0002-0000-0000-000000000035',
      subjectId: 'a0000009-0002-0000-0000-000000000018',
      name: 'Matter, Atoms & Molecules',
      subject: 'Science',
      grade: 'Class 9',
      description: 'States of matter, Dalton atomic theory, mole concept, valency',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0002-0000-0000-000000000069', topicId: 'b0000009-0002-0000-0000-000000000035', name: 'Atomic Mass & Mole Concept', description: 'Avogadro number, molar mass calculation', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000009-0002-0000-0000-000000000070', topicId: 'b0000009-0002-0000-0000-000000000035', name: 'Structure of the Atom', description: 'Electrons, protons, neutrons, Bohr model, valency', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Matter, Atoms & Molecules in Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Matter, Atoms & Molecules.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0002-0000-0000-000000000036',
      subjectId: 'a0000009-0002-0000-0000-000000000018',
      name: 'Motion, Force & Gravitation',
      subject: 'Science',
      grade: 'Class 9',
      description: 'Equations of motion, Newton laws, universal law of gravitation',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0002-0000-0000-000000000071', topicId: 'b0000009-0002-0000-0000-000000000036', name: 'Equations of Motion', description: 'v = u + at, s = ut + 0.5at^2, v^2 = u^2 + 2as', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000009-0002-0000-0000-000000000072', topicId: 'b0000009-0002-0000-0000-000000000036', name: 'Universal Law of Gravitation & Free Fall', description: 'Gravitational constant G, acceleration due to gravity g', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Motion, Force & Gravitation in Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Motion, Force & Gravitation.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0003-0000-0000-000000000037',
      subjectId: 'a0000009-0003-0000-0000-000000000019',
      name: 'French Revolution & Russian Socialism',
      subject: 'Social Science',
      grade: 'Class 9',
      description: 'Storming of Bastille, Jacobins, Bolshevik revolution under Lenin',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0003-0000-0000-000000000073', topicId: 'b0000009-0003-0000-0000-000000000037', name: 'Outbreak of French Revolution', description: 'Estate system, National Assembly, Tennis Court Oath', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000009-0003-0000-0000-000000000074', topicId: 'b0000009-0003-0000-0000-000000000037', name: 'Russian Revolution 1917', description: 'Tsar Nicholas II, Bolsheviks, Vladimir Lenin April Theses', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing French Revolution & Russian Socialism in Social Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across French Revolution & Russian Socialism.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0003-0000-0000-000000000038',
      subjectId: 'a0000009-0003-0000-0000-000000000019',
      name: 'Physiography of India & Democracy',
      subject: 'Social Science',
      grade: 'Class 9',
      description: 'Himalayas, Northern plains, Election Commission, democratic features',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0003-0000-0000-000000000075', topicId: 'b0000009-0003-0000-0000-000000000038', name: 'Major Physiographic Divisions of India', description: 'Himalayan ranges, peninsular plateau, coastal plains', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000009-0003-0000-0000-000000000076', topicId: 'b0000009-0003-0000-0000-000000000038', name: 'Electoral Politics & Election Commission', description: 'Voter lists, constituencies, code of conduct', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Physiography of India & Democracy in Social Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Physiography of India & Democracy.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0004-0000-0000-000000000039',
      subjectId: 'a0000009-0004-0000-0000-000000000020',
      name: 'Complex Grammar & Conditionals',
      subject: 'English Language',
      grade: 'Class 9',
      description: 'Zero, first, second, third conditional structures',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0004-0000-0000-000000000077', topicId: 'b0000009-0004-0000-0000-000000000039', name: 'Conditional Sentences', description: 'Type 1, Type 2, and Type 3 conditional clauses', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000009-0004-0000-0000-000000000078', topicId: 'b0000009-0004-0000-0000-000000000039', name: 'Inversion and Subjunctive Mood', description: 'Inversion with negative adverbs, unreal conditions', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Complex Grammar & Conditionals in English Language?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Complex Grammar & Conditionals.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000009-0004-0000-0000-000000000040',
      subjectId: 'a0000009-0004-0000-0000-000000000020',
      name: 'Reported Speech & Vocabulary',
      subject: 'English Language',
      grade: 'Class 9',
      description: 'Commands, reporting dialogue, advanced lexical terms',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000009-0004-0000-0000-000000000079', topicId: 'b0000009-0004-0000-0000-000000000040', name: 'Reported Speech for Exclamations', description: 'Conversion of exclamations and wishes', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000009-0004-0000-0000-000000000080', topicId: 'b0000009-0004-0000-0000-000000000040', name: 'Advanced Lexical Synonyms', description: 'High-register vocabulary replacements', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Reported Speech & Vocabulary in English Language?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Reported Speech & Vocabulary.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0001-0000-0000-000000000041',
      subjectId: 'a0000010-0001-0000-0000-000000000021',
      name: 'Real Numbers & Quadratic Equations',
      subject: 'Mathematics',
      grade: 'Class 10',
      description: 'Fundamental Theorem of Arithmetic, quadratic formula, discriminant',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0001-0000-0000-000000000081', topicId: 'b0000010-0001-0000-0000-000000000041', name: 'Fundamental Theorem of Arithmetic', description: 'Unique prime factorization, HCF and LCM relationship', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000010-0001-0000-0000-000000000082', topicId: 'b0000010-0001-0000-0000-000000000041', name: 'Nature of Roots & Discriminant', description: 'D = b^2 - 4ac, real, equal, and distinct roots', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Real Numbers & Quadratic Equations in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Real Numbers & Quadratic Equations.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0001-0000-0000-000000000042',
      subjectId: 'a0000010-0001-0000-0000-000000000021',
      name: 'Trigonometry & Arithmetic Progression',
      subject: 'Mathematics',
      grade: 'Class 10',
      description: 'Trigonometric ratios, identities, nth term and sum of AP',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0001-0000-0000-000000000083', topicId: 'b0000010-0001-0000-0000-000000000042', name: 'Trigonometric Identities & Values', description: 'sin^2 + cos^2 = 1, values of 30, 45, 60 degrees', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000010-0001-0000-0000-000000000084', topicId: 'b0000010-0001-0000-0000-000000000042', name: 'Arithmetic Progression nth Term and Sum', description: 'an = a + (n-1)d, Sn = n/2[2a + (n-1)d]', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'In the Arithmetic Progression: 2, 7, 12, ..., what is the common difference d?',
          options: ['5', '2', '7', '-5'],
          correctIndex: 0,
          explanation: 'Correct answer is 5.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the 10th term of the Arithmetic Progression: 5, 8, 11, 14, ...?',
          options: ['32', '35', '29', '30'],
          correctIndex: 0,
          explanation: 'Correct answer is 32.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which term of the AP: 21, 18, 15, ... is -81?',
          options: ['35th term', '34th term', '36th term', '32nd term'],
          correctIndex: 0,
          explanation: 'Correct answer is 35th term.',
        ),
        MCQuestion(
          id: 4,
          question: 'If the 3rd and 9th terms of an AP are 4 and -8 respectively, which term of this AP is 0?',
          options: ['5th term', '4th term', '6th term', '7th term'],
          correctIndex: 0,
          explanation: 'Correct answer is 5th term.',
        ),
        MCQuestion(
          id: 5,
          question: 'The sum of the first n terms of an AP is given by S_n = 3n^2 + 5n. Find its 15th term.',
          options: ['92', '88', '90', '96'],
          correctIndex: 0,
          explanation: 'Correct answer is 92.',
        ),
        MCQuestion(
          id: 6,
          question: 'Find the sum of the first 24 terms of the AP: 5, 2, -1, -4, ...',
          options: ['-708', '-696', '-720', '708'],
          correctIndex: 0,
          explanation: 'Correct answer is -708.',
        ),
        MCQuestion(
          id: 7,
          question: 'How many terms of the AP: 24, 21, 18, ... must be taken so that their sum is 78?',
          options: ['4 or 13', '4 only', '13 only', '5 or 12'],
          correctIndex: 0,
          explanation: 'Correct answer is 4 or 13.',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the sum of the first 100 positive integers?',
          options: ['5050', '5000', '5100', '10100'],
          correctIndex: 0,
          explanation: 'Correct answer is 5050.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0002-0000-0000-000000000043',
      subjectId: 'a0000010-0002-0000-0000-000000000022',
      name: 'Chemical Reactions & Carbon Compounds',
      subject: 'Science',
      grade: 'Class 10',
      description: 'Redox reactions, homologous series, functional groups, saponification',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0002-0000-0000-000000000085', topicId: 'b0000010-0002-0000-0000-000000000043', name: 'Types of Chemical Reactions', description: 'Combination, decomposition, displacement, redox', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000010-0002-0000-0000-000000000086', topicId: 'b0000010-0002-0000-0000-000000000043', name: 'Carbon Covalent Bonding & Allotropes', description: 'Tetravalency, catenation, diamond, graphite, fullerenes', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'What type of chemical reaction is represented by: 2Mg(s) + O2(g) -> 2MgO(s)?',
          options: ['Combination reaction', 'Decomposition reaction', 'Displacement reaction', 'Double displacement reaction'],
          correctIndex: 0,
          explanation: 'Correct answer is Combination reaction.',
        ),
        MCQuestion(
          id: 2,
          question: 'Heating of limestone (CaCO3 -> CaO + CO2) is an example of which reaction?',
          options: ['Thermal decomposition reaction', 'Combination reaction', 'Photochemical reaction', 'Neutralization reaction'],
          correctIndex: 0,
          explanation: 'Correct answer is Thermal decomposition reaction.',
        ),
        MCQuestion(
          id: 3,
          question: 'What happens when dilute hydrochloric acid is added to zinc granules?',
          options: ['Hydrogen gas and zinc chloride are produced', 'Chlorine gas and zinc hydroxide are produced', 'No chemical reaction occurs', 'Zinc oxide and water are produced'],
          correctIndex: 0,
          explanation: 'Correct answer is Hydrogen gas and zinc chloride are produced.',
        ),
        MCQuestion(
          id: 4,
          question: 'In the redox reaction: MnO2 + 4HCl -> MnCl2 + 2H2O + Cl2, which substance is oxidized?',
          options: ['HCl', 'MnO2', 'MnCl2', 'H2O'],
          correctIndex: 0,
          explanation: 'Correct answer is HCl.',
        ),
        MCQuestion(
          id: 5,
          question: 'Which of the following processes is endothermic in nature?',
          options: ['Decomposition of ferrous sulphate crystals', 'Burning of natural gas', 'Cellular respiration', 'Slaking of quicklime with water'],
          correctIndex: 0,
          explanation: 'Correct answer is Decomposition of ferrous sulphate crystals.',
        ),
        MCQuestion(
          id: 6,
          question: 'What type of reaction occurs when aqueous lead nitrate is mixed with potassium iodide solution?',
          options: ['Precipitation and double displacement reaction', 'Combination reaction', 'Thermal decomposition reaction', 'Simple displacement reaction'],
          correctIndex: 0,
          explanation: 'Correct answer is Precipitation and double displacement reaction.',
        ),
        MCQuestion(
          id: 7,
          question: 'Fatty and oily food items develop an unpleasant smell and taste over time primarily due to:',
          options: ['Aerial oxidation of fats and oils', 'Reduction of carbohydrates', 'Hydrolysis of proteins', 'Evaporation of moisture content'],
          correctIndex: 0,
          explanation: 'Correct answer is Aerial oxidation of fats and oils.',
        ),
        MCQuestion(
          id: 8,
          question: 'When copper powder is heated in air, its surface turns black due to the formation of:',
          options: ['Copper(II) oxide (CuO)', 'Copper(I) oxide (Cu2O)', 'Basic copper carbonate', 'Copper sulphate'],
          correctIndex: 0,
          explanation: 'Correct answer is Copper(II) oxide (CuO).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0002-0000-0000-000000000044',
      subjectId: 'a0000010-0002-0000-0000-000000000022',
      name: 'Optics & Electric Current',
      subject: 'Science',
      grade: 'Class 10',
      description: 'Snell law, lens formula, Ohm law, Joule heating, electromagnetic induction',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0002-0000-0000-000000000087', topicId: 'b0000010-0002-0000-0000-000000000044', name: 'Spherical Mirrors & Refraction', description: 'Mirror formula, magnification, Snell law, refractive index', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000010-0002-0000-0000-000000000088', topicId: 'b0000010-0002-0000-0000-000000000044', name: 'Ohm Law & Electric Power', description: 'V = IR, equivalent resistance in series and parallel, P = VI', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'What is the focal length of a spherical mirror whose radius of curvature is 30 cm?',
          options: ['15 cm', '30 cm', '60 cm', '10 cm'],
          correctIndex: 0,
          explanation: 'Correct answer is 15 cm.',
        ),
        MCQuestion(
          id: 2,
          question: 'Where must an object be placed in front of a concave mirror to obtain an erect and enlarged virtual image?',
          options: ['Between the pole and principal focus', 'At the center of curvature', 'At the principal focus', 'Beyond the center of curvature'],
          correctIndex: 0,
          explanation: 'Correct answer is Between the pole and principal focus.',
        ),
        MCQuestion(
          id: 3,
          question: 'A convex mirror used on a bus has a radius of curvature of 3.0 m. If another vehicle is 5.0 m away, what is the image position?',
          options: ['+1.15 m behind the mirror', '-1.15 m in front of the mirror', '+2.50 m behind the mirror', '-2.50 m in front of the mirror'],
          correctIndex: 0,
          explanation: 'Correct answer is +1.15 m behind the mirror.',
        ),
        MCQuestion(
          id: 4,
          question: 'If the speed of light in water is 2.25 x 10^8 m/s and in vacuum is 3.0 x 10^8 m/s, find the refractive index of water.',
          options: ['1.33', '1.50', '1.25', '1.66'],
          correctIndex: 0,
          explanation: 'Correct answer is 1.33.',
        ),
        MCQuestion(
          id: 5,
          question: 'A convex lens forms a real image of the same size as the needle at 50 cm. Where is the needle located in front of the lens?',
          options: ['At 50 cm in front of the lens', 'At 25 cm in front of the lens', 'At 100 cm in front of the lens', 'At infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is At 50 cm in front of the lens.',
        ),
        MCQuestion(
          id: 6,
          question: 'What is the focal length and optical nature of a lens having power +2.0 D?',
          options: ['+50 cm, convex lens', '-50 cm, concave lens', '+20 cm, convex lens', '-20 cm, concave lens'],
          correctIndex: 0,
          explanation: 'Correct answer is +50 cm, convex lens.',
        ),
        MCQuestion(
          id: 7,
          question: 'A ray of light traveling in water falls obliquely on a glass slab (n_water = 1.33, n_glass = 1.50). How does the ray bend?',
          options: ['It bends towards the normal', 'It bends away from the normal', 'It proceeds without deviation', 'It reflects totally back into water'],
          correctIndex: 0,
          explanation: 'Correct answer is It bends towards the normal.',
        ),
        MCQuestion(
          id: 8,
          question: 'If the linear magnification produced by a spherical mirror is negative (m < 0), what does it signify about the image?',
          options: ['The image is real and inverted', 'The image is virtual and erect', 'The image is diminished and erect', 'The image is virtual and magnified'],
          correctIndex: 0,
          explanation: 'Correct answer is The image is real and inverted.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0003-0000-0000-000000000045',
      subjectId: 'a0000010-0003-0000-0000-000000000023',
      name: 'Nationalism in India & Federalism',
      subject: 'Social Science',
      grade: 'Class 10',
      description: 'Non-Cooperation, Civil Disobedience, Union and State lists',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0003-0000-0000-000000000089', topicId: 'b0000010-0003-0000-0000-000000000045', name: 'Gandhian Movements in India', description: 'Rowlatt Satyagraha, Jallianwala Bagh, Dandi Salt March', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000010-0003-0000-0000-000000000090', topicId: 'b0000010-0003-0000-0000-000000000045', name: 'Federal System & Power Sharing', description: 'Union, State, Concurrent lists, linguistic states', difficulty: 'Easy'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Nationalism in India & Federalism in Social Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Nationalism in India & Federalism.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0003-0000-0000-000000000046',
      subjectId: 'a0000010-0003-0000-0000-000000000023',
      name: 'Money, Credit & Globalization',
      subject: 'Social Science',
      grade: 'Class 10',
      description: 'Formal/informal loans, RBI role, MNCs and trade liberalization',
      difficulty: 'Easy',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0003-0000-0000-000000000091', topicId: 'b0000010-0003-0000-0000-000000000046', name: 'Money as Medium of Exchange & Credit', description: 'Barter system difficulties, currency, collateral security', difficulty: 'Easy'),
      SeedSubtopic(id: 'c0000010-0003-0000-0000-000000000092', topicId: 'b0000010-0003-0000-0000-000000000046', name: 'Globalization & WTO', description: 'Multinational corporations, trade barriers, World Trade Organization', difficulty: 'Medium'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Money, Credit & Globalization in Social Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Money, Credit & Globalization.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0004-0000-0000-000000000047',
      subjectId: 'a0000010-0004-0000-0000-000000000024',
      name: 'Computer Networking & Cyber Ethics',
      subject: 'Computer Applications',
      grade: 'Class 10',
      description: 'LAN/WAN, IP addresses, phishing, digital footprint, firewall',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0004-0000-0000-000000000093', topicId: 'b0000010-0004-0000-0000-000000000047', name: 'Computer Networks & Topology', description: 'Star, bus, ring topologies, routers, TCP/IP protocol', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000010-0004-0000-0000-000000000094', topicId: 'b0000010-0004-0000-0000-000000000047', name: 'Cyber Security & IT Act', description: 'Phishing, malware, SSL certificates, Indian IT Act 2000', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Computer Networking & Cyber Ethics in Computer Applications?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Computer Networking & Cyber Ethics.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000010-0004-0000-0000-000000000048',
      subjectId: 'a0000010-0004-0000-0000-000000000024',
      name: 'HTML, CSS & Python Scripting',
      subject: 'Computer Applications',
      grade: 'Class 10',
      description: 'Semantic HTML, CSS selectors, loops, lists, and functions in Python',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000010-0004-0000-0000-000000000095', topicId: 'b0000010-0004-0000-0000-000000000048', name: 'HTML5 Forms & CSS Styling', description: 'Form inputs, tables, CSS box model, external stylesheets', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000010-0004-0000-0000-000000000096', topicId: 'b0000010-0004-0000-0000-000000000048', name: 'Python Fundamentals', description: 'Conditional branching, for/while loops, lists, functions', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing HTML, CSS & Python Scripting in Computer Applications?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across HTML, CSS & Python Scripting.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0001-0000-0000-000000000049',
      subjectId: 'a0000011-0001-0000-0000-000000000025',
      name: 'Mechanics & Thermodynamics',
      subject: 'Physics',
      grade: 'Class 11',
      description: 'Vectors, projectile motion, Newton laws, First & Second law of thermodynamics',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000011-0001-0000-0000-000000000097', topicId: 'b0000011-0001-0000-0000-000000000049', name: 'Projectile Motion & Work-Energy', description: 'Range, maximum height, work-energy theorem', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000011-0001-0000-0000-000000000098', topicId: 'b0000011-0001-0000-0000-000000000049', name: 'Laws of Thermodynamics & Heat Engines', description: 'Carnot cycle, efficiency, entropy change', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'What is the direction of acceleration of a projectile at the highest point of its trajectory?',
          options: ['Vertically downward towards the center of Earth', 'Horizontally in the direction of motion', 'Zero since vertical velocity is zero', 'Tangential to the curved trajectory path'],
          correctIndex: 0,
          explanation: 'Correct answer is Vertically downward towards the center of Earth.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the horizontal range R of a projectile fired with speed u at an angle theta to the horizontal?',
          options: ['R = (u^2 * sin(2*theta)) / g', 'R = (u^2 * cos(2*theta)) / g', 'R = (u * sin(theta)) / (2 * g)', 'R = (u^2 * sin^2(theta)) / (2 * g)'],
          correctIndex: 0,
          explanation: 'Correct answer is R = (u^2 * sin(2*theta)) / g.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the net work done by gravitational force when a satellite completes one full circular orbit around Earth?',
          options: ['Zero (0 Joules)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Zero (0 Joules).',
        ),
        MCQuestion(
          id: 4,
          question: 'What geometrical curve describes the trajectory of a projectile moving under uniform gravity in vacuum?',
          options: ['Parabola (Parabolic trajectory)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Parabola (Parabolic trajectory).',
        ),
        MCQuestion(
          id: 5,
          question: 'What is the gravitational potential energy U of two point masses m1 and m2 separated by distance r?',
          options: ['U = - (G * m1 * m2) / r', 'U = + (G * m1 * m2) / r', 'U = - (G * m1 * m2) / r^2', 'U = + (G * m1 * m2) / r^2'],
          correctIndex: 0,
          explanation: 'Correct answer is U = - (G * m1 * m2) / r.',
        ),
        MCQuestion(
          id: 6,
          question: 'State the SI unit and approximate standard value of the universal gravitational constant G.',
          options: ['6.674 x 10^-11 N m^2 kg^-2', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 6.674 x 10^-11 N m^2 kg^-2.',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the average translational kinetic energy of a single molecule of an ideal gas at absolute temperature T?',
          options: ['(3/2) * k_B * T', '(1/2) * k_B * T', '(5/2) * k_B * T', '3 * k_B * T'],
          correctIndex: 0,
          explanation: 'Correct answer is (3/2) * k_B * T.',
        ),
        MCQuestion(
          id: 8,
          question: 'Which thermodynamic state variable remains constant throughout an isothermal process?',
          options: ['Temperature (T = constant)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Temperature (T = constant).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0002-0000-0000-000000000050',
      subjectId: 'a0000011-0002-0000-0000-000000000026',
      name: 'Chemical Bonding & Equilibrium',
      subject: 'Chemistry',
      grade: 'Class 11',
      description: 'Hybridization, molecular orbital theory, Le Chatelier principle, pH buffer',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000011-0002-0000-0000-000000000099', topicId: 'b0000011-0002-0000-0000-000000000050', name: 'Hybridization & Molecular Geometry', description: 'sp, sp2, sp3 hybridization, VSEPR shapes', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000011-0002-0000-0000-000000000100', topicId: 'b0000011-0002-0000-0000-000000000050', name: 'Chemical Equilibrium & pH', description: 'Equilibrium constant Kc/Kp, Henderson equation', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'According to VSEPR theory, what is the geometric shape of the ammonia (NH3) molecule?',
          options: ['Trigonal pyramidal', 'Trigonal planar', 'Tetrahedral', 'T-shaped'],
          correctIndex: 0,
          explanation: 'Correct answer is Trigonal pyramidal.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the hybridization of the central sulfur atom in sulfur hexafluoride (SF6)?',
          options: ['sp3d2', 'sp3d', 'sp3', 'dsp2'],
          correctIndex: 0,
          explanation: 'Correct answer is sp3d2.',
        ),
        MCQuestion(
          id: 3,
          question: 'According to Molecular Orbital Theory, what is the bond order of the dinitrogen molecule (N2)?',
          options: ['3 (Triple bond)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 3 (Triple bond).',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the molecular geometry and bond angle in boron trifluoride (BF3)?',
          options: ['Trigonal planar with 120 degree bond angles', 'Trigonal pyramidal with 107 degree bond angles', 'T-shaped with 90 degree bond angles', 'Linear with 180 degree bond angles'],
          correctIndex: 0,
          explanation: 'Correct answer is Trigonal planar with 120 degree bond angles.',
        ),
        MCQuestion(
          id: 5,
          question: 'How many sigma (sigma) and pi (pi) bonds are present in an ethyne (acetylene, C2H2) molecule?',
          options: ['3 sigma bonds and 2 pi bonds', '2 sigma bonds and 3 pi bonds', '4 sigma bonds and 1 pi bond', '5 sigma bonds and 0 pi bonds'],
          correctIndex: 0,
          explanation: 'Correct answer is 3 sigma bonds and 2 pi bonds.',
        ),
        MCQuestion(
          id: 6,
          question: 'The paramagnetism of the oxygen molecule (O2) with two unpaired electrons is successfully explained by which theory?',
          options: ['Molecular Orbital Theory (MOT)', 'Valence Bond Theory (VBT)', 'Lewis Octet Theory', 'Resonance Theory'],
          correctIndex: 0,
          explanation: 'Correct answer is Molecular Orbital Theory (MOT).',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the formal charge on the central oxygen atom in the ozone (O3) resonance structure?',
          options: ['+1', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is +1.',
        ),
        MCQuestion(
          id: 8,
          question: 'Why is the H-O-H bond angle in water (H2O) 104.5 degrees rather than the tetrahedral angle of 109.5 degrees?',
          options: ['Lone pair - lone pair repulsion is greater than bond pair - bond pair repulsion', 'High electronegativity of hydrogen attracts oxygen core electrons', 'Steric hindrance between large hydrogen atoms pushes them closer', 'Involvement of d-orbitals in oxygen sp3 hybridization'],
          correctIndex: 0,
          explanation: 'Correct answer is Lone pair - lone pair repulsion is greater than bond pair - bond pair repulsion.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0003-0000-0000-000000000051',
      subjectId: 'a0000011-0003-0000-0000-000000000027',
      name: 'Calculus & Combinatorics',
      subject: 'Mathematics',
      grade: 'Class 11',
      description: 'Limits, derivatives, permutations, combinations, binomial theorem',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000011-0003-0000-0000-000000000101', topicId: 'b0000011-0003-0000-0000-000000000051', name: 'Limits and Standard Derivatives', description: 'Evaluation of limits, derivative of trig functions', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000011-0003-0000-0000-000000000102', topicId: 'b0000011-0003-0000-0000-000000000051', name: 'Permutations & Combinations', description: 'nPr, nCr, circular arrangements', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Evaluate the trigonometric limit: lim (x -> 0) [(1 - cos(x)) / x^2].',
          options: ['1/2', '1', '0', '2'],
          correctIndex: 0,
          explanation: 'Correct answer is 1/2.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the derivative of f(x) = sin(x) with respect to x?',
          options: ['cos(x)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is cos(x).',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the first derivative of f(x) = x * ln(x) for x > 0 with respect to x?',
          options: ['1 + ln(x)', 'ln(x)', '1 / x', 'x + ln(x)'],
          correctIndex: 0,
          explanation: 'Correct answer is 1 + ln(x).',
        ),
        MCQuestion(
          id: 4,
          question: 'Evaluate the algebraic limit: lim (x -> 2) [(x^2 - 4) / (x - 2)].',
          options: ['4', '2', '0', 'Undefined'],
          correctIndex: 0,
          explanation: 'Correct answer is 4.',
        ),
        MCQuestion(
          id: 5,
          question: 'What is the derivative of f(x) = cot(x) with respect to x?',
          options: ['-csc^2(x)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is -csc^2(x).',
        ),
        MCQuestion(
          id: 6,
          question: 'Evaluate the limit at infinity: lim (x -> infinity) [(3x^2 + 5x) / (2x^2 - 7)].',
          options: ['3/2', '5/2', '0', 'Infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is 3/2.',
        ),
        MCQuestion(
          id: 7,
          question: 'If y = sqrt(x), what is the value of dy/dx evaluated at x = 4?',
          options: ['1/4 (0.25)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 1/4 (0.25).',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the value of the exponential limit: lim (x -> 0) [(e^x - 1) / x]?',
          options: ['1', 'e', '0', 'Infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is 1.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0004-0000-0000-000000000052',
      subjectId: 'a0000011-0004-0000-0000-000000000028',
      name: 'Cell Biology & Physiology',
      subject: 'Biology',
      grade: 'Class 11',
      description: 'Mitosis, meiosis, Calvin cycle, Krebs cycle, action potential',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000011-0004-0000-0000-000000000103', topicId: 'b0000011-0004-0000-0000-000000000052', name: 'Photosynthesis (C3 & C4 Pathways)', description: 'RuBisCO, light reaction, ATP synthesis', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000011-0004-0000-0000-000000000104', topicId: 'b0000011-0004-0000-0000-000000000052', name: 'Cell Division (Mitosis & Meiosis)', description: 'Phases of mitosis, crossing over in pachynema', difficulty: 'Hard'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'Where in chloroplasts do the light-dependent photochemical reactions of photosynthesis occur?',
          options: ['Thylakoid membranes (grana)', 'Stroma matrix', 'Inner chloroplast envelope', 'Periplastidial space'],
          correctIndex: 0,
          explanation: 'Correct answer is Thylakoid membranes (grana).',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the peak absorption wavelength of the reaction center chlorophyll a in Photosystem I (PSI)?',
          options: ['700 nm (P700)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is 700 nm (P700).',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the first stable 3-carbon intermediate compound formed during carbon fixation in C3 plants?',
          options: ['3-Phosphoglyceric acid (3-PGA)', 'Oxaloacetic acid (OAA)', 'Phosphoenolpyruvate (PEP)', 'Glyceraldehyde 3-phosphate (G3P)'],
          correctIndex: 0,
          explanation: 'Correct answer is 3-Phosphoglyceric acid (3-PGA).',
        ),
        MCQuestion(
          id: 4,
          question: 'In C4 plants, initial atmospheric CO2 fixation takes place in which specific leaf cells?',
          options: ['Mesophyll cells', 'Bundle sheath cells', 'Epidermal cells', 'Xylem parenchyma cells'],
          correctIndex: 0,
          explanation: 'Correct answer is Mesophyll cells.',
        ),
        MCQuestion(
          id: 5,
          question: 'What are the two 3-carbon end-product molecules produced by glycolysis from one molecule of glucose?',
          options: ['Pyruvic acid (Pyruvate)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is Pyruvic acid (Pyruvate).',
        ),
        MCQuestion(
          id: 6,
          question: 'Which metal ions are indispensable for the water-splitting complex during photolysis in Photosystem II?',
          options: ['Manganese (Mn) and Chlorine (Cl)', 'Magnesium (Mg) and Iron (Fe)', 'Copper (Cu) and Zinc (Zn)', 'Molybdenum (Mo) and Cobalt (Co)'],
          correctIndex: 0,
          explanation: 'Correct answer is Manganese (Mn) and Chlorine (Cl).',
        ),
        MCQuestion(
          id: 7,
          question: 'What is the Respiratory Quotient (RQ) when glucose or starch is completely oxidized in aerobic respiration?',
          options: ['1.0', '0.7', '0.9', 'Infinity'],
          correctIndex: 0,
          explanation: 'Correct answer is 1.0.',
        ),
        MCQuestion(
          id: 8,
          question: 'How many ATP molecules are synthesized on average when one molecule of NADH is oxidized in the mitochondrial ETC?',
          options: ['3 (or approx 2.5) ATP molecules', '2 (or approx 1.5) ATP molecules', '1 ATP molecule', '4 ATP molecules'],
          correctIndex: 0,
          explanation: 'Correct answer is 3 (or approx 2.5) ATP molecules.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000011-0005-0000-0000-000000000053',
      subjectId: 'a0000011-0005-0000-0000-000000000029',
      name: 'Python Algorithms & Logic',
      subject: 'Computer Science',
      grade: 'Class 11',
      description: 'Dictionary mappings, tuples, bubble sort, insertion sort',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000011-0005-0000-0000-000000000105', topicId: 'b0000011-0005-0000-0000-000000000053', name: 'Python Dictionaries & Sorting', description: 'Key-value pairs, bubble sort time complexity', difficulty: 'Medium'),
      ],
      questions: [
        MCQuestion(
          id: 1,
          question: 'What is the average time complexity of indexing (random access) an element in a Python list?',
          options: ['O(1)', 'O(n)', 'O(log n)', 'O(n^2)'],
          correctIndex: 0,
          explanation: 'Correct answer is O(1).',
        ),
        MCQuestion(
          id: 2,
          question: 'Which built-in Python sequence type is mutable and maintains insertion order?',
          options: ['list', 'tuple', 'frozenset', 'str'],
          correctIndex: 0,
          explanation: 'Correct answer is list.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which Python dictionary method removes the specified key and returns its associated value?',
          options: ['pop()', 'remove()', 'discard()', 'delete()'],
          correctIndex: 0,
          explanation: 'Correct answer is pop().',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the average-case time complexity of searching for a key in a Python dictionary?',
          options: ['O(1) (Constant time)', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is O(1) (Constant time).',
        ),
        MCQuestion(
          id: 5,
          question: 'Which list method adds all elements of an iterable (e.g., another list) to the end of the list?',
          options: ['extend()', 'append()', 'insert()', 'update()'],
          correctIndex: 0,
          explanation: 'Correct answer is extend().',
        ),
        MCQuestion(
          id: 6,
          question: 'What will be the output of the list comprehension: [x**2 for x in range(5) if x % 2 == 0]?',
          options: ['[0, 4, 16]', '[1, 9]', '[0, 1, 4, 9, 16]', '[4, 16]'],
          correctIndex: 0,
          explanation: 'Correct answer is [0, 4, 16].',
        ),
        MCQuestion(
          id: 7,
          question: 'Which built-in sequence type in Python is enclosed in parentheses and is completely immutable?',
          options: ['tuple', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          explanation: 'Correct answer is tuple.',
        ),
        MCQuestion(
          id: 8,
          question: 'What is the worst-case time complexity of inserting an item at the beginning of a Python list of n elements?',
          options: ['O(n)', 'O(1)', 'O(log n)', 'O(n log n)'],
          correctIndex: 0,
          explanation: 'Correct answer is O(n).',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000012-0001-0000-0000-000000000054',
      subjectId: 'a0000012-0001-0000-0000-000000000030',
      name: 'Electrodynamics & Optics',
      subject: 'Physics',
      grade: 'Class 12',
      description: 'Gauss law, capacitors, Kirchhoff laws, wave optics, photoelectric effect',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000012-0001-0000-0000-000000000106', topicId: 'b0000012-0001-0000-0000-000000000054', name: 'Electrostatic Potential & Capacitance', description: 'Parallel plate capacitor, dielectric constant, energy stored', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000012-0001-0000-0000-000000000107', topicId: 'b0000012-0001-0000-0000-000000000054', name: 'Electromagnetic Induction & Alternating Current', description: 'Faraday law, Lenz law, AC impedance, resonance', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000012-0001-0000-0000-000000000108', topicId: 'b0000012-0001-0000-0000-000000000054', name: 'Wave Optics & Modern Physics', description: 'Interference, fringe width, de Broglie wavelength', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Electrodynamics & Optics in Physics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Electrodynamics & Optics.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000012-0002-0000-0000-000000000055',
      subjectId: 'a0000012-0002-0000-0000-000000000031',
      name: 'Physical & Organic Chemistry',
      subject: 'Chemistry',
      grade: 'Class 12',
      description: 'Nernst equation, rate laws, Aldol, Cannizzaro, coordination isomers',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000012-0002-0000-0000-000000000109', topicId: 'b0000012-0002-0000-0000-000000000055', name: 'Electrochemistry & Chemical Kinetics', description: 'EMF, Nernst equation, first-order rate constant, half-life', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000012-0002-0000-0000-000000000110', topicId: 'b0000012-0002-0000-0000-000000000055', name: 'Coordination Compounds & Named Reactions', description: 'Werner theory, crystal field splitting, Aldol, Cannizzaro', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Physical & Organic Chemistry in Chemistry?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Physical & Organic Chemistry.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000012-0003-0000-0000-000000000056',
      subjectId: 'a0000012-0003-0000-0000-000000000032',
      name: 'Advanced Calculus & Vectors',
      subject: 'Mathematics',
      grade: 'Class 12',
      description: 'Definite integrals, differential equations, dot and cross products, Bayes theorem',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000012-0003-0000-0000-000000000111', topicId: 'b0000012-0003-0000-0000-000000000056', name: 'Definite Integrals & Differential Equations', description: 'Fundamental theorem of calculus, integrating factor', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000012-0003-0000-0000-000000000112', topicId: 'b0000012-0003-0000-0000-000000000056', name: 'Vector Algebra & 3D Lines', description: 'Direction cosines, shortest distance between skew lines', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Advanced Calculus & Vectors in Mathematics?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Advanced Calculus & Vectors.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000012-0004-0000-0000-000000000057',
      subjectId: 'a0000012-0004-0000-0000-000000000033',
      name: 'Genetics & Biotechnology',
      subject: 'Biology',
      grade: 'Class 12',
      description: 'DNA replication, transcription, operon model, recombinant DNA, PCR',
      difficulty: 'Hard',
      subtopics: const [
      SeedSubtopic(id: 'c0000012-0004-0000-0000-000000000113', topicId: 'b0000012-0004-0000-0000-000000000057', name: 'Molecular Basis of Inheritance', description: 'DNA double helix, transcription, translation, genetic code', difficulty: 'Hard'),
      SeedSubtopic(id: 'c0000012-0004-0000-0000-000000000114', topicId: 'b0000012-0004-0000-0000-000000000057', name: 'Biotechnology Principles & Processes', description: 'Restriction endonucleases, plasmid vectors, PCR, agarose gel', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Genetics & Biotechnology in Biology?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Genetics & Biotechnology.',
        ),
      ],
    ),
    SeedTopic(
      id: 'b0000012-0005-0000-0000-000000000058',
      subjectId: 'a0000012-0005-0000-0000-000000000034',
      name: 'Data Structures & SQL',
      subject: 'Computer Science',
      grade: 'Class 12',
      description: 'Stack push/pop, queue enqueue/dequeue, relational SQL joins, aggregation',
      difficulty: 'Medium',
      subtopics: const [
      SeedSubtopic(id: 'c0000012-0005-0000-0000-000000000115', topicId: 'b0000012-0005-0000-0000-000000000058', name: 'Linear Data Structures (Stack & Queue)', description: 'LIFO, FIFO, push, pop, enqueue, dequeue implementation', difficulty: 'Medium'),
      SeedSubtopic(id: 'c0000012-0005-0000-0000-000000000116', topicId: 'b0000012-0005-0000-0000-000000000058', name: 'Relational Database Queries & Joins', description: 'INNER JOIN, LEFT JOIN, GROUP BY, HAVING, subqueries', difficulty: 'Hard'),
      ],
      questions: const [
        MCQuestion(
          id: 1,
          question: 'What is the foundational law governing Data Structures & SQL in Computer Science?',
          options: ['Preservation of structural and physical balance', 'Arbitrary divergence of parameters', 'Unconstrained scalar decay', 'Irreversible loss of constraints'],
          correctIndex: 0,
          explanation: 'Core curriculum theorems require preservation of structural balance across Data Structures & SQL.',
        ),
      ],
    ),
  ];

  static List<SeedClass> getClassesForBoard(String board) {
    final b = board.trim().toUpperCase();
    return classes.where((c) => c.board.toUpperCase() == b).toList();
  }

  /// Find a topic by its exact UUID
  static SeedTopic? findTopicById(String id) {
    try {
      return topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find a subtopic by its exact UUID
  static SeedSubtopic? findSubtopicById(String id) {
    for (final topic in topics) {
      for (final sub in topic.subtopics) {
        if (sub.id == id) return sub;
      }
    }
    return null;
  }

  /// Get subtopics for a specific topic ID
  static List<SeedSubtopic> getSubtopicsForTopic(String topicId) {
    final t = findTopicById(topicId);
    return t?.subtopics ?? const [];
  }

  /// Resolve topics matching subject and grade
  static List<SeedTopic> getTopicsFor({required String subject, String? grade}) {
    final cleanSubj = subject.trim().toLowerCase();
    final cleanGrade = grade?.trim().toLowerCase();

    return topics.where((t) {
      final tSubj = t.subject.toLowerCase();
      bool matchSubj = tSubj.contains(cleanSubj) || cleanSubj.contains(tSubj);
      if (cleanSubj.contains('math') && tSubj.contains('math')) matchSubj = true;
      if (cleanSubj.contains('phys') && (tSubj.contains('phys') || tSubj.contains('science'))) matchSubj = true;
      if (cleanSubj.contains('chem') && (tSubj.contains('chem') || tSubj.contains('science'))) matchSubj = true;
      if (cleanSubj.contains('bio') && (tSubj.contains('bio') || tSubj.contains('science'))) matchSubj = true;
      if (cleanSubj.contains('code') || cleanSubj.contains('prog') || cleanSubj.contains('comp')) {
        if (tSubj.contains('comp') || tSubj.contains('code')) matchSubj = true;
      }
      if (cleanSubj.contains('hist') || cleanSubj.contains('social')) {
        if (tSubj.contains('social') || tSubj.contains('hist')) matchSubj = true;
      }
      if (!matchSubj) return false;

      if (cleanGrade != null && cleanGrade.isNotEmpty) {
        return t.grade.toLowerCase().contains(cleanGrade) || cleanGrade.contains(t.grade.toLowerCase());
      }
      return true;
    }).toList();
  }

  /// Get fallback learning content response from seed dataset
  static LearningContentResponse getLearningContentFor(LearningRequest req) {
    final matchingTopics = getTopicsFor(subject: req.subject, grade: req.grade);
    SeedTopic? selected;
    if (req.topicId != null && req.topicId!.isNotEmpty) {
      selected = findTopicById(req.topicId!);
    }
    if (selected == null && req.topic != null && req.topic!.isNotEmpty) {
      final tName = req.topic!.toLowerCase();
      selected = matchingTopics.firstWhere(
        (t) => t.name.toLowerCase().contains(tName) || tName.contains(t.name.toLowerCase()),
        orElse: () => matchingTopics.isNotEmpty ? matchingTopics.first : topics.first,
      );
    }
    selected ??= matchingTopics.isNotEmpty ? matchingTopics.first : topics.first;

    SeedSubtopic? selectedSub;
    if (req.subtopicId != null && req.subtopicId!.isNotEmpty) {
      selectedSub = findSubtopicById(req.subtopicId!);
    } else if (selected.subtopics.isNotEmpty) {
      selectedSub = selected.subtopics.first;
    }

    final questions = (selectedSub != null && selectedSub.questions.isNotEmpty)
        ? selectedSub.questions
        : (selected.questions.isNotEmpty
            ? selected.questions
            : const [
                MCQuestion(
                  id: 1,
                  question: 'What is the primary governing principle of this lesson?',
                  options: ['Conservation of systemic balance', 'Random divergence of constants', 'Unconstrained scalar decay', 'Arbitrary index mapping'],
                  correctIndex: 0,
                  explanation: 'Core curriculum theorems require preservation and balance across dimensional systems.',
                ),
              ]);

    final activeTitle = selectedSub != null ? '${selected.name} • ${selectedSub.name}' : selected.name;
    final activeDesc = selectedSub?.description.isNotEmpty == true
        ? selectedSub!.description
        : (selected.description.isNotEmpty
            ? selected.description
            : 'Master fundamental principles of ${selected.name} calibrated for ${req.grade ?? "Class 10"}.');

    return LearningContentResponse(
      buildingId: req.buildingId,
      buildingName: req.buildingName,
      subject: req.subject,
      topic: activeTitle,
      explanation: activeDesc,
      questions: questions,
      audioAvailable: false,
      source: 'curriculum-seed-dataset',
      cacheKey: 'seed_${req.subject}_${req.buildingId}_${req.studentLevel}_${req.topicId ?? ""}_${req.subtopicId ?? ""}',
    );
  }

  /// Resolves the deterministic Class UUID for a given grade and curriculum board.
  static String findClassId({required String grade, required String board}) {
    final g = grade.trim().toLowerCase();
    final b = board.trim().toUpperCase();
    for (final c in classes) {
      if (c.name.toLowerCase() == g && c.board.toUpperCase() == b) {
        return c.id;
      }
    }
    for (final c in classes) {
      if (c.name.toLowerCase() == g) {
        return c.id;
      }
    }
    return '00000010-0001-0000-0000-000000000000';
  }

  /// Returns all classes belonging to a given education board.
  static List<SeedClass> getClassesByBoard(String board) {
    final b = board.trim().toUpperCase();
    return classes.where((c) => c.board.toUpperCase() == b).toList();
  }
}
