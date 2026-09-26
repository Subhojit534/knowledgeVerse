import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../config/asset_paths.dart';
import '../../../config/game_assets.dart';
import '../../../models/learning_models.dart';
import '../../../models/player_profile.dart';
import '../../../services/learning_service.dart';
import '../../../services/mobile_tts_service.dart';
import '../../buildings/building_data.dart';
import '../../managers/building_manager.dart';

/// Authentic Book-Themed Battle Trial Arena for quizzes:
/// Features an illuminated ancient trial codex on a warm mahogany study desk,
/// heraldic character medallions on the sides (Player on left, Guardian on right),
/// parchment-style question scrolls, wax-seal bullet options, and combat GIF animations.
class BattleQuizArena extends StatefulWidget {
  final BuildingData building;
  final VoidCallback onClose;

  const BattleQuizArena({
    super.key,
    required this.building,
    required this.onClose,
  });

  @override
  State<BattleQuizArena> createState() => _BattleQuizArenaState();
}

class _BattleQuizArenaState extends State<BattleQuizArena>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _idleAnimController;
  late AnimationController _attackAnimController;
  late AnimationController _bossDamageAnimController;

  // Quiz & Battle State
  bool _isLoading = true;
  LearningContentResponse? _content;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasSubmittedAnswer = false;
  int _score = 0;
  bool _battleCompleted = false;

  // Health / Focus Points
  int _playerHp = 100;
  int _bossHp = 100;
  int _maxBossHp = 100;
  String? _combatEffectText;

  // Damage / Victory GIF FX States
  bool _isShowingFailAnimation = false;
  bool _isShowingVictoryAnimation = false;
  Timer? _failTimer;
  Timer? _victoryTimer;
  bool _hasClaimedRewards = false;
  int _consecutiveWrongAttempts = 0;

  // Audio Playback
  bool _isPlayingAudio = false;

  // Fixed Codex Dimensions (Matching LessonBookView proportions)
  static const double codexWidth = 780.0;
  static const double codexHeight = 520.0;

  @override
  void initState() {
    super.initState();

    _idleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _idleAnimController.repeat(reverse: true);
    }

    _attackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bossDamageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    MobileTtsService.instance.addListener(_onTtsStateChanged);
    _fetchQuestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AssetPaths.quizVictoryAnimation), context);
    precacheImage(const AssetImage(AssetPaths.quizFailAnimation), context);
  }

  void _onTtsStateChanged(bool isSpeaking) {
    if (mounted) {
      setState(() => _isPlayingAudio = isSpeaking);
    }
  }

  @override
  void dispose() {
    _idleAnimController.dispose();
    _attackAnimController.dispose();
    _bossDamageAnimController.dispose();
    _failTimer?.cancel();
    _victoryTimer?.cancel();
    MobileTtsService.instance.removeListener(_onTtsStateChanged);
    MobileTtsService.instance.stop();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = PlayerProfile.notifier.value ?? PlayerProfile.current ?? const PlayerProfile();
      final topicId = BuildingManager().activeQuizTopicId ??
          widget.building.activeTopicId ??
          profile.activeTopicId;
      final subtopicId = BuildingManager().activeQuizSubtopicId ??
          widget.building.activeSubtopicId ??
          profile.activeSubtopicId;

      final req = LearningRequest(
        buildingId: widget.building.id,
        buildingName: widget.building.name,
        subject: widget.building.subject,
        studentLevel: widget.building.level,
        grade: profile.grade.isNotEmpty ? profile.grade : 'Class 10',
        curriculum: profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE',
        topic: widget.building.name,
        topicId: topicId,
        subtopicId: subtopicId,
      );

      final response = await LearningService.fetchLearningContent(req);

      if (mounted) {
        setState(() {
          _content = response;
          _isLoading = false;
          final totalQ = response.questions.length;
          _maxBossHp = totalQ > 0 ? totalQ * 25 : 100;
          _bossHp = _maxBossHp;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to open the Trial Codex. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  List<MCQuestion> _getQuestions() {
    if (_content != null && _content!.questions.isNotEmpty) {
      return _content!.questions;
    }
    final topic = widget.building.name;
    final subject = widget.building.subject;
    return [
      MCQuestion(
        id: 1,
        question: 'What foundational law governs $topic in $subject?',
        options: const [
          'Preservation of balance across structural equations',
          'Arbitrary variance of variable constants',
          'Unconstrained divergent polynomials',
          'Irreversible omission of coordinate boundaries',
        ],
        correctIndex: 0,
        explanation: 'Codex theorems require balance and equality across all dimensional systems.',
      ),
      MCQuestion(
        id: 2,
        question: 'How do kingdom scholars apply $topic across Hexafalls?',
        options: const [
          'To construct radiant towers and chart alignments',
          'By dismantling ancient architectural blueprints',
          'By discarding foundational mathematical laws',
          'By ignoring environmental equilibrium parameters',
        ],
        correctIndex: 0,
        explanation: 'Scholars apply this wisdom to advance building tiers and harmonize islands.',
      ),
    ];
  }

  void _selectOption(int optionIndex) {
    if (_hasSubmittedAnswer || _isShowingFailAnimation || _isShowingVictoryAnimation || _battleCompleted) return;

    final questions = _getQuestions();
    final currentQ = questions[_currentQuestionIndex];
    final bool isCorrect = optionIndex == currentQ.correctIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _hasSubmittedAnswer = true;
    });

    if (isCorrect) {
      _consecutiveWrongAttempts = 0;
      _score++;
      _attackAnimController.forward(from: 0.0);
      _bossDamageAnimController.forward(from: 0.0);
      final damage = (_maxBossHp / questions.length).round();
      final isFinalQuestion = _currentQuestionIndex + 1 >= questions.length;

      setState(() {
        _bossHp = (_bossHp - damage).clamp(0, _maxBossHp);
        _combatEffectText = isFinalQuestion && (_score == questions.length)
            ? '⚔️ FINAL STRIKE! GUARDIAN VANQUISHED!'
            : '✨ CRITICAL STRIKE! -$damage HP';
      });

      final transitionDelay = isFinalQuestion ? 800 : 1200;
      Future.delayed(Duration(milliseconds: transitionDelay), () {
        if (!mounted) return;
        _advanceOrComplete(questions);
      });
    } else {
      _consecutiveWrongAttempts++;
      final playerDamage = (100 / questions.length).round();
      final bool triggerFailAnimation = _consecutiveWrongAttempts >= 3;

      setState(() {
        _playerHp = (_playerHp - playerDamage).clamp(10, 100);
        if (triggerFailAnimation) {
          _combatEffectText = '💥 3 CONSECUTIVE MISSES!';
          _isShowingFailAnimation = true;
          _consecutiveWrongAttempts = 0;
        } else {
          _combatEffectText = '💥 GUARDIAN STRIKE! -$playerDamage HP';
          _isShowingFailAnimation = false;
        }
      });

      if (triggerFailAnimation) {
        _failTimer = Timer(const Duration(milliseconds: 2700), () {
          if (!mounted) return;
          setState(() {
            _isShowingFailAnimation = false;
          });
          _advanceOrComplete(questions);
        });
      } else {
        // If 3 consecutive incorrect attempts have not occurred, do NOT show fail animation!
        // Briefly display the strike and advance cleanly.
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          _advanceOrComplete(questions);
        });
      }
    }
  }

  void _advanceOrComplete(List<MCQuestion> questions) {
    if (_currentQuestionIndex + 1 < questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasSubmittedAnswer = false;
        _combatEffectText = null;
      });
    } else {
      final bool perfectScore = _score == questions.length;
      if (perfectScore) {
        setState(() {
          _isShowingVictoryAnimation = true;
          _combatEffectText = '⚔️ GUARDIAN VANQUISHED!';
        });

        _victoryTimer = Timer(const Duration(milliseconds: 4900), () {
          if (!mounted) return;
          setState(() {
            _isShowingVictoryAnimation = false;
            _battleCompleted = true;
          });
        });
      } else {
        setState(() {
          _battleCompleted = true;
        });
      }
    }
  }

  Future<void> _claimRewards() async {
    if (_hasClaimedRewards) return;
    setState(() => _hasClaimedRewards = true);

    final profile = PlayerProfile.notifier.value ?? PlayerProfile.current;
    if (profile != null) {
      final updatedXp = profile.xp + 100;
      final updated = PlayerProfile(
        id: profile.id,
        name: profile.name,
        password: profile.password,
        grade: profile.grade,
        curriculum: profile.curriculum,
        subjects: profile.subjects,
        difficulty: profile.difficulty,
        worldTheme: profile.worldTheme,
        learningGoal: profile.learningGoal,
        avatarIndex: profile.avatarIndex,
        xp: updatedXp,
        focusXp: profile.focusXp + 100,
        coins: profile.coins + 50,
        gems: profile.gems + 5,
        energy: profile.energy,
        streakDays: profile.streakDays,
        lastLoginDate: profile.lastLoginDate,
        weeklyQuestions: profile.weeklyQuestions + _score,
        weeklyMinutes: profile.weeklyMinutes + 5,
        lastEnergyUpdate: profile.lastEnergyUpdate,
        ownedItems: profile.ownedItems,
        level: PlayerProfile.computeLevel(updatedXp),
      );
      PlayerProfile.notifier.update(updated);
      unawaited(updated.save());
    }

    BuildingManager().addXp(widget.building.id, 100);

    // Synchronize quiz completion with backend learning service
    final totalQ = _content?.questions.length ?? 4;
    unawaited(LearningService.submitQuizResult(
      buildingId: widget.building.id,
      subject: widget.building.subject,
      correctAnswers: _score,
      totalQuestions: totalQ,
      updateLocalProfile: false,
    ));

    if (mounted) {
      widget.onClose();
    }
  }

  void _restartBattle() {
    _failTimer?.cancel();
    _victoryTimer?.cancel();
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasSubmittedAnswer = false;
      _consecutiveWrongAttempts = 0;
      _score = 0;
      _playerHp = 100;
      _bossHp = _maxBossHp;
      _combatEffectText = null;
      _isShowingFailAnimation = false;
      _isShowingVictoryAnimation = false;
      _battleCompleted = false;
      _hasClaimedRewards = false;
    });
  }

  String _getBossName() {
    final s = widget.building.subject.toLowerCase();
    if (s.contains('math')) return 'Arch-Geometer Pythagoras';
    if (s.contains('sci') || s.contains('phys')) return 'Chronos Dynamo Sentinel';
    if (s.contains('chem')) return 'Alchemical Homunculus';
    if (s.contains('bio')) return 'Verdant Primordial Colossus';
    if (s.contains('code') || s.contains('cs')) return 'Binary Archon Core';
    if (s.contains('hist')) return 'Immortal Centurion Phantom';
    return '${widget.building.name} Guardian';
  }

  String _getBossSprite() {
    final s = widget.building.subject.toLowerCase();
    if (s.contains('math') || s.contains('hist')) return NpcAssets.professorNpc;
    if (s.contains('code') || s.contains('sci')) return NpcAssets.guardNpc;
    return NpcAssets.librarianNpc;
  }

  @override
  Widget build(BuildContext context) {
    final profile = PlayerProfile.notifier.value ?? PlayerProfile.current ?? const PlayerProfile();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: codexWidth,
              height: codexHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 0. Offstage Pre-warmer: Keeps GIF textures decoded in GPU memory for lag-free playback
                  Offstage(
                    offstage: true,
                    child: Row(
                      children: [
                        Image.asset(AssetPaths.quizVictoryAnimation, gaplessPlayback: true),
                        Image.asset(AssetPaths.quizFailAnimation, gaplessPlayback: true),
                      ],
                    ),
                  ),

                  // 1. Ambient Drop Shadow beneath the Codex
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.65),
                            blurRadius: 36,
                            spreadRadius: 6,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Grand Leather & Gold Trim Frame
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A1827), // Imperial Leather Crimson
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFD4AF37), // Antique Gold Trim
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Aged Imperial Parchment Core Surface
                  Positioned(
                    left: 8,
                    top: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE), // Warm Parchment
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFC5A059).withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      child: _isLoading
                          ? _buildLoadingState()
                          : _errorMessage != null
                              ? _buildErrorState()
                              : _battleCompleted
                                  ? _buildBattleResultsView(profile)
                                  : _buildCombatArena(profile),
                    ),
                  ),

                  // 4. Circular Antique Gold Close Seal Button (Top Right Corner)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C221E),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.close_rounded, size: 18, color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── LOADING & ERROR STATES ──────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(color: Color(0xFF7A1C2E), strokeWidth: 3),
          ),
          const SizedBox(height: 14),
          Text(
            'OPENING ${widget.building.name.toUpperCase()} TRIAL CODEX...',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Color(0xFF7A1C2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F1E3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD20F39), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFFD20F39), size: 40),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'serif', color: Color(0xFF4A3E3D), fontSize: 15.5),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _fetchQuestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A1C2E),
                foregroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('RETRY CODEX SUMMON'),
            ),
          ],
        ),
      ),
    );
  }

  // ── COMBAT ARENA ────────────────────────────────────────────────────────────
  Widget _buildCombatArena(PlayerProfile profile) {
    final questions = _getQuestions();
    final currentQ = questions[_currentQuestionIndex];

    return Column(
      children: [
        // 1. Top Imperial Header Ribbon
        _buildParchmentHeader(questions.length),

        // 2. Heraldic Battle Stage: Left Scholar Hero + Center VS + Right Guardian Boss
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF2EADC).withValues(alpha: 0.6),
            border: Border(
              bottom: BorderSide(color: const Color(0xFFC5A059).withValues(alpha: 0.4), width: 1.0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Player Avatar Medallion
              Expanded(
                flex: 4,
                child: _buildPlayerHeraldicSide(profile),
              ),

              // Center: VS Emblem & Combat Floating Text
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A1C2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '❖ VS ❖',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_combatEffectText != null)
                      Text(
                        _combatEffectText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: _combatEffectText!.contains('CRITICAL')
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ).animate().scale(duration: 250.ms),
                  ],
                ),
              ),

              // Right: Realm Guardian Medallion
              Expanded(
                flex: 4,
                child: _buildGuardianHeraldicSide(),
              ),
            ],
          ),
        ),

        // 3. Question & Options Stage
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: _isShowingFailAnimation
                ? _buildFailAnimationStage()
                : _isShowingVictoryAnimation
                    ? _buildVictoryAnimationStage()
                    : _buildQuestionCardAndOptions(currentQ),
          ),
        ),
      ],
    );
  }

  // ── 1. TOP PARCHMENT HEADER ────────────────────────────────────────────────
  Widget _buildParchmentHeader(int totalQuestions) {
    final profile = PlayerProfile.notifier.value ?? PlayerProfile.current;
    final subtopicName = widget.building.activeSubtopicName ?? profile?.activeSubtopicName;
    final subtopicId = BuildingManager().activeQuizSubtopicId ??
        widget.building.activeSubtopicId ??
        profile?.activeSubtopicId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF7A1C2E), // Imperial Scholar Crimson
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.auto_stories, size: 18, color: Color(0xFFD4AF37)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtopicName != null && subtopicName.isNotEmpty
                            ? '${widget.building.name.toUpperCase()} • $subtopicName'
                            : widget.building.name.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Color(0xFFF7E7B4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtopicId != null && subtopicId.isNotEmpty)
                        Text(
                          'UUID: $subtopicId',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFA6E3A1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Round Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2C221E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
            ),
            child: Text(
              'ROUND ${_currentQuestionIndex + 1} / $totalQuestions',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2A. LEFT: PLAYER HERALDIC MEDALLION ─────────────────────────────────────
  Widget _buildPlayerHeraldicSide(PlayerProfile profile) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleAnimController, _attackAnimController]),
      builder: (context, child) {
        final bounce = math.sin(_idleAnimController.value * math.pi) * 3;
        final attackShift = _attackAnimController.value * 12;

        return Transform.translate(
          offset: Offset(attackShift, -bounce),
          child: Row(
            children: [
              // Circular Portrait Frame with Golden Rim
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC5A059), width: 2.0),
                  color: const Color(0xFFFFFDF8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  AssetPaths.getAvatarPortrait(profile.avatarIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 32,
                    color: Color(0xFF7A1C2E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name : 'Hero Arcanist',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2422),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A1C2E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LVL ${profile.level}',
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _buildParchmentHpBar(current: _playerHp, max: 100, isPlayer: true),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── 2B. RIGHT: GUARDIAN HERALDIC MEDALLION ──────────────────────────────────
  Widget _buildGuardianHeraldicSide() {
    return AnimatedBuilder(
      animation: Listenable.merge([_idleAnimController, _bossDamageAnimController]),
      builder: (context, child) {
        final float = math.sin((_idleAnimController.value + 0.5) * math.pi) * 3;
        final shake = math.sin(_bossDamageAnimController.value * math.pi * 4) * 5;

        return Transform.translate(
          offset: Offset(shake, -float),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A1C2E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BOSS',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _getBossName(),
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C2422),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _buildParchmentHpBar(current: _bossHp, max: _maxBossHp, isPlayer: false),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Circular Boss Frame with Ruby Rim
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7A1C2E), width: 2.0),
                  color: const Color(0xFFFFFDF8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _getBossSprite(),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shield,
                    size: 32,
                    color: Color(0xFF7A1C2E),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParchmentHpBar({
    required int current,
    required int max,
    required bool isPlayer,
  }) {
    final double ratio = max > 0 ? (current / max).clamp(0.0, 1.0) : 1.0;
    final color = isPlayer ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: isPlayer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPlayer ? 'FOCUS' : 'GUARD',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5B58),
                ),
              ),
              Text(
                '$current/$max',
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            width: 160,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFECE4D0),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFFC5A059), width: 0.8),
            ),
            child: FractionallySizedBox(
              alignment: isPlayer ? Alignment.centerLeft : Alignment.centerRight,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. PARCHMENT QUESTION SCROLL & BALANCED 2x2 OPTIONS ──────────────────────
  Widget _buildQuestionCardAndOptions(MCQuestion currentQ) {
    return Column(
      children: [
        // Question Scroll Plaque
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline_rounded, size: 22, color: Color(0xFF7A1C2E)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  currentQ.question,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 19.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2422),
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // TTS Audio Button
              GestureDetector(
                onTap: () {
                  if (_isPlayingAudio) {
                    MobileTtsService.instance.stop();
                  } else {
                    MobileTtsService.instance.speak(currentQ.question);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EADC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
                  ),
                  child: Icon(
                    _isPlayingAudio ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: const Color(0xFF7A1C2E),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 4 Options Grid (2x2 Balanced Parchment Tiles)
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
              childAspectRatio: 3.2,
            ),
            itemCount: currentQ.options.length,
            itemBuilder: (context, index) {
              return _buildParchmentOptionTile(
                optionIndex: index,
                optionText: currentQ.options[index],
                correctIndex: currentQ.correctIndex,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParchmentOptionTile({
    required int optionIndex,
    required String optionText,
    required int correctIndex,
  }) {
    final bool isSelected = _selectedOptionIndex == optionIndex;
    final bool isCorrect = optionIndex == correctIndex;
    final bool showResult = _hasSubmittedAnswer;

    Color borderColor = const Color(0xFFC5A059).withValues(alpha: 0.6);
    Color bgColor = const Color(0xFFFFFDF8);
    Color bulletColor = const Color(0xFF7A1C2E);

    if (showResult) {
      if (isCorrect) {
        borderColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        bulletColor = const Color(0xFF2E7D32);
      } else if (isSelected) {
        borderColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        bulletColor = const Color(0xFFC62828);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF7A1C2E);
      bgColor = const Color(0xFFF2EADC);
    }

    final glyphLetters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      key: Key('battle_opt_$optionIndex'),
      onTap: () => _selectOption(optionIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: (isSelected || (showResult && (isCorrect || isSelected))) ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Wax Seal Bullet Marker
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bulletColor,
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
              ),
              child: Center(
                child: showResult && (isCorrect || isSelected)
                    ? Icon(
                        isCorrect ? Icons.check : Icons.close,
                        size: 15,
                        color: Colors.white,
                      )
                    : Text(
                        glyphLetters[optionIndex % 4],
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                optionText,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2422),
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FAIL KNOCKDOWN ANIMATION STAGE ──────────────────────────────────────────
  Widget _buildFailAnimationStage() {
    return GestureDetector(
      onTap: () {
        _failTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _isShowingFailAnimation = false;
        });
        final questions = _getQuestions();
        _advanceOrComplete(questions);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC62828), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC62828).withValues(alpha: 0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💥 3 CONSECUTIVE MISSES! GUARDIAN KNOCKDOWN!',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFFC62828),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AssetPaths.quizFailAnimation,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, size: 44, color: Color(0xFFC62828)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Recovering focus for next battle round... ',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF6B5B58),
                    ),
                  ),
                  TextSpan(
                    text: '• Tap to continue',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.0,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF8C7B75),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── SWORD BLAST VICTORY ANIMATION STAGE (GIF from Prompt 1!) ────────────────
  Widget _buildVictoryAnimationStage() {
    return GestureDetector(
      onTap: () {
        _victoryTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _isShowingVictoryAnimation = false;
          _battleCompleted = true;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '⚔️ VICTORY STRIKE! REALM LIBERATED! ⚔️',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
                color: Color(0xFF7A1C2E),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AssetPaths.quizVictoryAnimation,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.workspace_premium, size: 50, color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Sword blast shattered the guardian ward! ',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  TextSpan(
                    text: '• Tap to continue',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 13.0,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF8C7B75),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── FINAL BATTLE RESULTS & REWARDS VIEW ─────────────────────────────────────
  Widget _buildBattleResultsView(PlayerProfile profile) {
    final bool isVictory = _score >= (_getQuestions().length / 2);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 36),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVictory ? const Color(0xFFD4AF37) : const Color(0xFFC5A059),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVictory ? Icons.workspace_premium_rounded : Icons.replay_rounded,
              size: 48,
              color: isVictory ? const Color(0xFFD4AF37) : const Color(0xFF7A1C2E),
            ),
            const SizedBox(height: 8),
            Text(
              isVictory ? 'TRIAL CONQUERED!' : 'TRIAL INCOMPLETE',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 21.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isVictory ? const Color(0xFF7A1C2E) : const Color(0xFF4A3E3D),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isVictory
                  ? 'You vanquished ${_getBossName()} with $_score/${_getQuestions().length} correct strikes!'
                  : 'You scored $_score/${_getQuestions().length}. Train your focus and try again!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'serif', fontSize: 16.5, color: Color(0xFF5A4B48)),
            ),
            const SizedBox(height: 12),

            // Rewards Breakdown Box
            if (isVictory) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F1E3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _RewardBadge(icon: '⚡', label: '+100 XP', color: Color(0xFF2E7D32)),
                    _RewardBadge(icon: '🪙', label: '+50 COINS', color: Color(0xFF7A1C2E)),
                    _RewardBadge(icon: '💎', label: '+5 GEMS', color: Color(0xFFC5A059)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _restartBattle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5A4B48),
                      side: const BorderSide(color: Color(0xFFC5A059)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('RETRY', style: TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 15.0)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('claim_battle_rewards_btn'),
                    onPressed: isVictory ? _claimRewards : widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A1C2E),
                      foregroundColor: const Color(0xFFD4AF37),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      isVictory ? 'CLAIM & RETURN' : 'RETURN TO MAP',
                      style: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, letterSpacing: 0.8, fontSize: 15.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _RewardBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 17)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
