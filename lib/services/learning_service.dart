import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/learning_models.dart';
import '../models/player_profile.dart';
import 'api_config.dart';
import 'api_service.dart';

/// Centralized service handling AI content fetching and ElevenLabs TTS integration.
class LearningService {
  LearningService._();

  static const Duration _timeout = Duration(seconds: 60);

  /// Cache for fetched learning content
  static final Map<String, LearningContentResponse> _cache = {};

  /// Fetches AI-generated learning explanation and 4 MCQs for a given subject building.
  static Future<LearningContentResponse> fetchLearningContent(LearningRequest request) async {
    final cacheKey = '${request.buildingId}_${request.subject}_${request.studentLevel}';
    if (_cache.containsKey(cacheKey)) {
      debugPrint('📦 [LearningService]: Returning cached content for $cacheKey');
      return _cache[cacheKey]!;
    }

    final base = ApiConfig.baseUrl;

    try {
      final response = await ApiService.post(
        '/api/learning/content',
        body: request.toJson(),
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final result = LearningContentResponse.fromJson(data, base);
        _cache[cacheKey] = result;
        return result;
      }
      debugPrint('❌ [LearningService]: Backend error ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception fetching AI content: $e');
    }

    // Offline / fallback fallback path
    final fallback = _createOfflineContent(request);
    _cache[cacheKey] = fallback;
    return fallback;
  }

  /// Submits quiz completion results to the backend to update XP, Coins, Level, and Supabase progress.
  static Future<Map<String, dynamic>?> submitQuizResult({
    required String buildingId,
    required String subject,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    try {
      final currentProfile = PlayerProfile.current;
      final userId = (currentProfile != null && currentProfile.id.isNotEmpty)
          ? currentProfile.id
          : (currentProfile?.name.isNotEmpty == true ? currentProfile!.name : 'demo-user-123');

      final response = await ApiService.post(
        '/api/learning/submit-quiz',
        body: {
          'user_id': userId,
          'building_id': buildingId,
          'subject': subject,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions,
        },
        timeout: _timeout,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        debugPrint('✅ [LearningService]: Quiz submitted successfully! XP Earned: ${data['xp_earned']}');
        return data;
      }
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception submitting quiz result: $e');
    }
    return null;
  }

  /// Synthesizes speech for custom text (e.g., question reading, how-to-play tutorial).
  static Future<String?> fetchTTSAudioUrl(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final response = await ApiService.post(
        '/api/tts',
        body: {'text': text},
        timeout: const Duration(seconds: 12),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final rawPath = data['audio_url'] as String?;
        if (rawPath != null && rawPath.isNotEmpty) {
          final base = ApiConfig.baseUrl;
          return rawPath.startsWith('http') ? rawPath : '$base$rawPath';
        }
      }
    } catch (e) {
      debugPrint('❌ [LearningService]: Exception fetching TTS audio: $e');
    }
    return null;
  }

  /// Generates offline default content if backend is completely offline.
  static LearningContentResponse _createOfflineContent(LearningRequest req) {
    final subj = req.subject.toLowerCase();
    final bId = req.buildingId.toLowerCase();
    final bName = req.buildingName;

    String topic = '$bName - Core Concepts';
    String explanation =
      'Mastery of $bName in ${req.subject} requires understanding definitions, applying standard formulae, and verifying solutions through step-by-step reasoning.';
    List<MCQuestion> questions = [];

    if (bId.contains('trig') || bId.contains('angle')) {
      topic = 'Trigonometric Ratios & Pythagorean Identities';
      explanation =
          'In right triangles: sin θ = opp/hyp, cos θ = adj/hyp, tan θ = opp/adj. Key identities: sin²θ + cos²θ = 1, 1 + tan²θ = sec²θ, and 1 + cot²θ = cosec²θ.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'What is the value of sin²(30°) + cos²(30°)?',
          options: ['0', '1/2', '1', '2'],
          correctIndex: 2,
          explanation: 'For any angle θ, sin²θ + cos²θ is always equal to 1.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the value of tan(45°)?',
          options: ['0', '1/2', '1', '√3'],
          correctIndex: 2,
          explanation: 'tan(45°) = 1.',
        ),
        MCQuestion(
          id: 3,
          question: 'If sin θ = 3/5 in a right triangle, what is cos θ?',
          options: ['4/5', '3/4', '5/3', '1/5'],
          correctIndex: 0,
          explanation: 'Using the 3-4-5 right triangle: cos θ = √(1 - 9/25) = 4/5.',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the reciprocal of sin θ?',
          options: ['cos θ', 'cosec θ', 'sec θ', 'cot θ'],
          correctIndex: 1,
          explanation: 'cosec θ = 1 / sin θ.',
        ),
      ];
    } else if (bId.contains('real') || bId.contains('number') || bId.contains('prime')) {
      topic = 'Real Numbers, LCM/HCF & Primes';
      explanation =
          'The Fundamental Theorem of Arithmetic guarantees that every composite number has a unique prime factorization. HCF × LCM = Product of two positive integers.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'If HCF(a, b) = 12 and a × b = 1800, what is LCM(a, b)?',
          options: ['120', '150', '180', '200'],
          correctIndex: 1,
          explanation: 'HCF × LCM = a × b => LCM = 1800 / 12 = 150.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which of the following is an irrational number?',
          options: ['√4', '√9', '√7', '0.75'],
          correctIndex: 2,
          explanation: '√7 cannot be written as a ratio of two integers.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the HCF of any two consecutive natural numbers?',
          options: ['0', '1', '2', 'Product of the two numbers'],
          correctIndex: 1,
          explanation: 'Consecutive natural numbers are always coprime.',
        ),
        MCQuestion(
          id: 4,
          question: 'Every composite number can be uniquely expressed as:',
          options: ['Sum of primes', 'Product of primes', 'Difference of squares', 'Ratio of evens'],
          correctIndex: 1,
          explanation: 'Fundamental Theorem of Arithmetic states unique prime factorization.',
        ),
      ];
    } else if (bId.contains('poly') || bId.contains('quad')) {
      topic = 'Polynomials & Quadratic Equations';
      explanation =
          'A quadratic equation ax² + bx + c = 0 has roots given by the quadratic formula. The discriminant D = b² - 4ac determines root nature (D > 0 distinct, D = 0 equal, D < 0 imaginary).';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'What is the sum of roots (α + β) for ax² + bx + c = 0?',
          options: ['-b/a', 'c/a', 'b/a', '-c/a'],
          correctIndex: 0,
          explanation: 'Sum of roots = -b/a, product = c/a.',
        ),
        MCQuestion(
          id: 2,
          question: 'If the discriminant D = 0, the quadratic roots are:',
          options: ['Real and distinct', 'Real and equal', 'Complex', 'Undefined'],
          correctIndex: 1,
          explanation: 'D = 0 means both roots equal -b / (2a).',
        ),
        MCQuestion(
          id: 3,
          question: 'What are the roots of x² - 5x + 6 = 0?',
          options: ['x = 1, 6', 'x = 2, 3', 'x = -2, -3', 'x = 0, 5'],
          correctIndex: 1,
          explanation: '(x - 2)(x - 3) = 0 gives roots 2 and 3.',
        ),
        MCQuestion(
          id: 4,
          question: 'What is the degree of a quadratic polynomial?',
          options: ['1', '2', '3', '4'],
          correctIndex: 1,
          explanation: 'Quadratics have highest exponent 2.',
        ),
      ];
    } else if (bId.contains('light') || bId.contains('optic')) {
      topic = 'Light Reflection & Refraction';
      explanation =
          'Spherical mirrors obey 1/f = 1/v + 1/u. Convex mirrors create virtual upright images for rear views. Lenses obey 1/f = 1/v - 1/u. Power P = 1/f in dioptres.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'What is the SI unit of power of a lens?',
          options: ['Watt', 'Joule', 'Dioptre', 'Lumen'],
          correctIndex: 2,
          explanation: 'Lens power is measured in Dioptres (D = 1/m).',
        ),
        MCQuestion(
          id: 2,
          question: 'Which mirror is used in car side mirrors for wide view?',
          options: ['Concave mirror', 'Convex mirror', 'Plane mirror', 'Cylindrical mirror'],
          correctIndex: 1,
          explanation: 'Convex mirrors provide wider field of view.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the approximate speed of light in vacuum?',
          options: ['3 × 10⁶ m/s', '3 × 10⁸ m/s', '3 × 10¹⁰ m/s', '300 m/s'],
          correctIndex: 1,
          explanation: 'c ≈ 3.0 × 10⁸ m/s.',
        ),
        MCQuestion(
          id: 4,
          question: 'What phenomenon splits white light into a rainbow in prisms?',
          options: ['Refraction', 'Dispersion', 'Diffraction', 'Reflection'],
          correctIndex: 1,
          explanation: 'Dispersion separates wavelengths into colors.',
        ),
      ];
    } else if (bId.contains('react') || bId.contains('chem') || bId.contains('acid')) {
      topic = 'Chemical Reactions & Matter';
      explanation =
          'Chemical reactions rearrange atoms while conserving mass. Acids (pH < 7) turn blue litmus red, bases (pH > 7) turn red litmus blue. Neutralization yields salt and water.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'What color does blue litmus paper turn in acidic solutions?',
          options: ['Blue', 'Red', 'Green', 'Yellow'],
          correctIndex: 1,
          explanation: 'Acids turn blue litmus red.',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the chemical formula of Baking Soda?',
          options: ['Na₂CO₃', 'NaHCO₃', 'CaCO₃', 'NaOH'],
          correctIndex: 1,
          explanation: 'Sodium hydrogen carbonate is NaHCO₃.',
        ),
        MCQuestion(
          id: 3,
          question: 'What gas is released when metals react with dilute acids?',
          options: ['Oxygen', 'Carbon Dioxide', 'Hydrogen', 'Nitrogen'],
          correctIndex: 2,
          explanation: 'Metal + Acid → Salt + Hydrogen gas.',
        ),
        MCQuestion(
          id: 4,
          question: 'Why do we balance chemical equations?',
          options: ['Law of Definite Proportions', 'Law of Conservation of Mass', 'Boyle\'s Law', 'Ohm\'s Law'],
          correctIndex: 1,
          explanation: 'Total mass of reactants equals total mass of products.',
        ),
      ];
    } else if (subj.contains('bio') || bId.contains('cell') || bId.contains('life') || bId.contains('hered')) {
      topic = 'Cell Biology & Life Processes';
      explanation =
          'Life processes include nutrition, respiration, transportation, and excretion. In cells, mitochondria produce ATP via cellular respiration, while DNA carries genetic instructions.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'Which organelle is known as the powerhouse of the cell?',
          options: ['Ribosome', 'Mitochondria', 'Golgi apparatus', 'Nucleus'],
          correctIndex: 1,
          explanation: 'Mitochondria produce ATP energy for cellular activities.',
        ),
        MCQuestion(
          id: 2,
          question: 'What green pigment absorbs sunlight in plant photosynthesis?',
          options: ['Hemoglobin', 'Chlorophyll', 'Carotene', 'Melanin'],
          correctIndex: 1,
          explanation: 'Chlorophyll in chloroplasts absorbs light energy.',
        ),
        MCQuestion(
          id: 3,
          question: 'What is the basic functional unit of the human nervous system?',
          options: ['Nephron', 'Neuron', 'Alveolus', 'Erythrocyte'],
          correctIndex: 1,
          explanation: 'Neurons transmit electrical impulses across synapses.',
        ),
        MCQuestion(
          id: 4,
          question: 'In genetics, who is known as the Father of Genetics for studying pea plants?',
          options: ['Charles Darwin', 'Gregor Mendel', 'Louis Pasteur', 'Robert Hooke'],
          correctIndex: 1,
          explanation: 'Gregor Mendel formulated laws of inheritance through pea plant experiments.',
        ),
      ];
    } else if (subj.contains('hist') || subj.contains('civic') || subj.contains('social') || bId.contains('natio')) {
      topic = 'World History & Civilizations';
      explanation =
          'History examines human societies, institutions, revolutions, and cultural transformations that shaped modern constitutional democracies and global trade networks.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'In which year did the French Revolution begin with the storming of the Bastille?',
          options: ['1776', '1789', '1804', '1848'],
          correctIndex: 1,
          explanation: 'The French Revolution began in 1789.',
        ),
        MCQuestion(
          id: 2,
          question: 'What was the primary goal of the Indian Non-Cooperation Movement in 1920?',
          options: ['Industrial growth', 'Swaraj (Self-rule)', 'Tax expansion', 'Annexing territory'],
          correctIndex: 1,
          explanation: 'Mahatma Gandhi launched the movement to attain self-rule non-violently.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which ancient civilization was famous for Harappa and Mohenjo-daro town planning?',
          options: ['Mesopotamian', 'Indus Valley', 'Egyptian', 'Mayan'],
          correctIndex: 1,
          explanation: 'The Indus Valley Civilization pioneered advanced urban drainage and grid streets.',
        ),
        MCQuestion(
          id: 4,
          question: 'What does a democratic federal constitution guarantee?',
          options: ['Monarchy rule', 'Division of powers between center & states', 'Single party control', 'No elections'],
          correctIndex: 1,
          explanation: 'Federalism divides sovereign powers between federal and state levels.',
        ),
      ];
    } else if (bId.contains('elect') || bId.contains('magnet') || subj.contains('phys')) {
      topic = 'Electricity, Circuits & Magnetism';
      explanation =
          'Ohm\'s law states V = I × R. Electric current is charge per unit time (I = Q/t). Magnetic fields exert forces on moving charges given by Fleming\'s Left-Hand Rule.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'According to Ohm\'s Law, what is the formula relating V, I, and R?',
          options: ['V = I / R', 'V = I × R', 'V = I² × R', 'V = R / I'],
          correctIndex: 1,
          explanation: 'Potential difference V is directly proportional to current I (V = I R).',
        ),
        MCQuestion(
          id: 2,
          question: 'What is the SI unit of electrical resistance?',
          options: ['Volt', 'Ampere', 'Ohm (Ω)', 'Watt'],
          correctIndex: 2,
          explanation: 'Electrical resistance is measured in Ohms.',
        ),
        MCQuestion(
          id: 3,
          question: 'Which instrument is connected in series to measure electric current in a circuit?',
          options: ['Voltmeter', 'Ammeter', 'Galvanometer', 'Rheostat'],
          correctIndex: 1,
          explanation: 'Ammeters have low resistance and are connected in series.',
        ),
        MCQuestion(
          id: 4,
          question: 'What happens to the total resistance when two identical resistors R are connected in parallel?',
          options: ['2R', 'R/2', 'R²', 'Zero'],
          correctIndex: 1,
          explanation: 'In parallel: 1/Req = 1/R + 1/R => Req = R/2.',
        ),
      ];
    } else if (subj.contains('code') || subj.contains('program') || subj.contains('comp')) {
      topic = 'Algorithms & Problem Solving';
      explanation =
          'An algorithm is a step-by-step procedure to solve a problem. Sequential code executes top-to-bottom, conditionals make decisions, and loops automate repetitive operations.';
      questions = const [
        MCQuestion(
          id: 1,
          question: 'What is the main function of a loop in programming?',
          options: ['Store single value', 'Repeat code execution', 'Delete memory', 'Render UI style'],
          correctIndex: 1,
          explanation: 'Loops allow instructions to repeat without duplicating code.',
        ),
        MCQuestion(
          id: 2,
          question: 'Which statement enables decision making in code?',
          options: ['Variable', 'Function', 'If-Else Statement', 'Array'],
          correctIndex: 2,
          explanation: 'If-else statements test conditions to execute branching code.',
        ),
        MCQuestion(
          id: 3,
          question: 'What does a variable hold in memory?',
          options: ['Data values', 'Screen pixels', 'Network speed', 'User passwords'],
          correctIndex: 0,
          explanation: 'Variables store data values that can be referenced and updated.',
        ),
        MCQuestion(
          id: 4,
          question: 'What happens when a loop has no exit condition?',
          options: ['Stops immediately', 'Runs infinitely', 'Compiles fast', 'Becomes variable'],
          correctIndex: 1,
          explanation: 'Infinite loops run indefinitely without stopping.',
        ),
      ];
    } else {
      questions = [
        MCQuestion(
          id: 1,
          question: 'What is the best way to master ${req.subject}?',
          options: ['Rote memorization', 'Conceptual understanding & practice', 'Skipping basics', 'Random guessing'],
          correctIndex: 1,
          explanation: 'Active problem solving and concept mastery produce lasting understanding.',
        ),
        MCQuestion(
          id: 2,
          question: 'Why break topics into smaller components?',
          options: ['Simplifies understanding', 'Wastes study time', 'Makes memory hard', 'Disables logic'],
          correctIndex: 0,
          explanation: 'Deconstructing topics makes learning manageable and clear.',
        ),
        MCQuestion(
          id: 3,
          question: 'What solidifies learning in memory?',
          options: ['Passive reading', 'Active practice & answering questions', 'Ignoring errors', 'No sleep'],
          correctIndex: 1,
          explanation: 'Applying knowledge through quiz questions reinforces recall.',
        ),
        MCQuestion(
          id: 4,
          question: 'How should learning mistakes be viewed?',
          options: ['As failure', 'As valuable learning feedback', 'As irrelevant', 'As reason to quit'],
          correctIndex: 1,
          explanation: 'Mistakes pinpoint exact concepts to review and improve.',
        ),
      ];
    }

    return LearningContentResponse(
      buildingId: req.buildingId,
      buildingName: req.buildingName,
      subject: req.subject,
      topic: topic,
      explanation: explanation,
      questions: questions,
      explanationAudioUrl: null,
      audioAvailable: false,
      source: 'offline',
      cacheKey: 'offline_${req.buildingId}',
    );
  }
}
