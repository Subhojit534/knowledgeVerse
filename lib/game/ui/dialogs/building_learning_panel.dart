import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/asset_paths.dart';
import '../../../models/learning_models.dart';
import '../../../models/player_profile.dart';
import '../../../services/learning_service.dart';
import '../../../services/mobile_tts_service.dart';
import '../../buildings/building_data.dart';
import '../../managers/building_manager.dart';

/// AI-Powered Building Learning Panel UI widget — PIXEL ART THEMED.
/// Uses Mobile TTS with calibrated fantasy voice (pitch 0.9, rate 0.45)
/// for instant offline voice narration (explanation, tutorial, question reading).
class BuildingLearningPanel extends StatefulWidget {
  final BuildingData building;
  final VoidCallback onClose;
  final int initialTabIndex;

  const BuildingLearningPanel({
    super.key,
    required this.building,
    required this.onClose,
    this.initialTabIndex = 0,
  });

  @override
  State<BuildingLearningPanel> createState() => _BuildingLearningPanelState();
}

class _BuildingLearningPanelState extends State<BuildingLearningPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _isLoading = true;
  LearningContentResponse? _content;
  String? _errorMessage;

  // Audio Playback State
  bool _isPlayingAudio = false;
  final bool _isLoadingAudio = false;
  final Duration _audioDuration = Duration.zero;
  final Duration _audioPosition = Duration.zero;

  // Quiz State
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasSubmittedAnswer = false;
  int _score = 0;
  bool _quizCompleted = false;
  final Map<int, int> _userAnswers = {};

  // Fail Animation State (Knockdown / Damage GIF)
  bool _isShowingFailAnimation = false;
  Timer? _wrongAnswerDelayTimer;
  Timer? _failAnimationTimer;

  // Victory Animation State (Sword Blast / All Correct GIF)
  bool _isShowingVictoryAnimation = false;
  Timer? _victoryAnimationTimer;

  // Tutorial / How To Play text
  static const String _tutorialText =
      "Welcome to the Learning Chamber! Select the Topic tab to hear and read your AI-generated subject lesson. Then switch to the Quiz tab to answer 4 multiple-choice questions. Earning high quiz scores rewards your building with Focus XP and unlocks visual magic upgrades!";

  // Building Action Panel / Theme Palette (Matching Image 1)
  static const Color _bgDark      = Color(0xFF1E1E2E); // Main Dialog Surface
  static const Color _bgMid       = Color(0xFF181825); // Header & Sub-surface
  static const Color _bgPanel     = Color(0xFF181825); // Card surfaces
  static const Color _surface     = Color(0xFF313244); // Pill / element surface
  static const Color _borderDim   = Color(0xFF313244); // Subtle dividers & borders
  static const Color _gold        = Color(0xFFF9E2AF); // Soft gold / amber
  static const Color _goldShadow  = Color(0xFF3C2F00);
  static const Color _peach       = Color(0xFFFAB387); // Level badge color
  static const Color _textPrimary = Color(0xFFCDD6F4); // Primary text
  static const Color _textMuted   = Color(0xFFA6ADC8); // Muted text
  static const Color _green       = Color(0xFFA6E3A1); // Correct green
  static const Color _red         = Color(0xFFF38BA8); // Incorrect red
  static const Color _blue        = Color(0xFF89B4FA); // Energy & audio blue
  static const Color _purple      = Color(0xFFCBA6F7); // Lavender gems

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
    _tabController.addListener(_handleTabChange);
    MobileTtsService.instance.addListener(_onTtsStateChanged);
    _fetchContent();
  }

  void _onTtsStateChanged(bool isSpeaking) {
    if (mounted) {
      setState(() => _isPlayingAudio = isSpeaking);
    }
  }

  void _handleTabChange() {
    _wrongAnswerDelayTimer?.cancel();
    _failAnimationTimer?.cancel();
    _victoryAnimationTimer?.cancel();
    if (_isShowingFailAnimation || _isShowingVictoryAnimation) {
      _isShowingFailAnimation = false;
      _isShowingVictoryAnimation = false;
    }
    MobileTtsService.instance.stop();
  }

  Future<void> _fetchContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = PlayerProfile.notifier.value ?? PlayerProfile.current ?? const PlayerProfile();
      final req = LearningRequest(
        buildingId: widget.building.id,
        buildingName: widget.building.name,
        subject: widget.building.subject,
        studentLevel: widget.building.level,
        grade: profile.grade.isNotEmpty ? profile.grade : 'Class 10',
        curriculum: profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE',
        topic: widget.building.name,
      );

      final response = await LearningService.fetchLearningContent(req);

      if (mounted) {
        setState(() {
          _content = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load learning content. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _wrongAnswerDelayTimer?.cancel();
    _failAnimationTimer?.cancel();
    _victoryAnimationTimer?.cancel();
    MobileTtsService.instance.removeListener(_onTtsStateChanged);
    MobileTtsService.instance.stop();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayExplanationAudio() async {
    if (_content == null || _content!.explanation.isEmpty) return;
    if (_isPlayingAudio) {
      await MobileTtsService.instance.stop();
    } else {
      await MobileTtsService.instance.speak(_content!.explanation);
    }
  }

  Future<void> _playQuestionAudio(String text) async {
    if (_isPlayingAudio && MobileTtsService.instance.currentText == text) {
      await MobileTtsService.instance.stop();
    } else {
      await MobileTtsService.instance.speak(text);
    }
  }

  Future<void> _playTutorialAudio() async {
    if (_isPlayingAudio) {
      await MobileTtsService.instance.stop();
    } else {
      await MobileTtsService.instance.speak(_tutorialText);
    }
  }

  void _selectAnswer(int optionIndex) {
    if (_hasSubmittedAnswer || _isShowingFailAnimation || _isShowingVictoryAnimation) return;
    setState(() {
      _selectedOptionIndex = optionIndex;
    });
  }

  void _submitAnswer() async {
    if (_selectedOptionIndex == null || _content == null || _isShowingFailAnimation || _isShowingVictoryAnimation) return;
    final currentQ = _content!.questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionIndex == currentQ.correctIndex;

    setState(() {
      _hasSubmittedAnswer = true;
      _userAnswers[_currentQuestionIndex] = _selectedOptionIndex!;
      if (isCorrect) {
        _score += 1;
      }
    });

    if (!isCorrect) {
      MobileTtsService.instance.stop();
      // Step 1: Brief 300ms flash showing the wrong choice before full fail section
      _wrongAnswerDelayTimer?.cancel();
      _wrongAnswerDelayTimer = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _isShowingFailAnimation = true;
        });

        // Step 2: Play falling animation (2700ms), then advance to next question
        _failAnimationTimer?.cancel();
        _failAnimationTimer = Timer(const Duration(milliseconds: 2750), () {
          if (!mounted) return;
          _advanceFromFailAnimation();
        });
      });
    }

    final currentProfile = PlayerProfile.current ?? await PlayerProfile.load();
    if (currentProfile != null) {
      if (isCorrect) {
        final updated = currentProfile.withCorrectAnswer();
        await updated.save();
      } else {
        final updated = currentProfile.withWrongAnswer();
        await updated.save();
      }
    }
  }

  void _advanceFromFailAnimation() {
    _wrongAnswerDelayTimer?.cancel();
    _failAnimationTimer?.cancel();
    _wrongAnswerDelayTimer = null;
    _failAnimationTimer = null;
    if (!_isShowingFailAnimation) return;

    setState(() {
      _isShowingFailAnimation = false;
    });

    _nextQuestion();
  }

  void _finishQuizFromVictoryAnimation() {
    _victoryAnimationTimer?.cancel();
    _victoryAnimationTimer = null;
    if (!mounted) return;
    setState(() {
      _isShowingVictoryAnimation = false;
      _quizCompleted = true;
    });
  }

  void _nextQuestion() async {
    _wrongAnswerDelayTimer?.cancel();
    _failAnimationTimer?.cancel();
    _victoryAnimationTimer?.cancel();
    if (_content == null) return;
    if (_currentQuestionIndex < _content!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex += 1;
        _selectedOptionIndex = null;
        _hasSubmittedAnswer = false;
        _isShowingFailAnimation = false;
        _isShowingVictoryAnimation = false;
      });
    } else {
      final int xpAward = _score * 50 + 50;
      BuildingManager().addXp(widget.building.id, xpAward);

      final bool isPerfect = _score == _content!.questions.length;

      // If user gave all correct answers of all questions, play epic sword blast victory animation!
      if (isPerfect && !_isShowingVictoryAnimation) {
        setState(() {
          _isShowingVictoryAnimation = true;
          _isShowingFailAnimation = false;
        });

        _victoryAnimationTimer?.cancel();
        _victoryAnimationTimer = Timer(const Duration(milliseconds: 4700), () {
          if (!mounted) return;
          _finishQuizFromVictoryAnimation();
        });
      } else {
        setState(() {
          _quizCompleted = true;
          _isShowingFailAnimation = false;
          _isShowingVictoryAnimation = false;
        });
      }

      // If user got all questions right (e.g. 4/4), award diamonds in background!
      if (isPerfect) {
        final currentProfile = PlayerProfile.current ?? await PlayerProfile.load();
        if (currentProfile != null) {
          final updated = currentProfile.withPerfectQuizReward();
          await updated.save();
        }
      }

      // Submit results to backend learning service
      try {
        await LearningService.submitQuizResult(
          buildingId: widget.building.id,
          subject: widget.building.subject,
          correctAnswers: _score,
          totalQuestions: _content!.questions.length,
        );
      } catch (_) {}
    }
  }

  void _restartQuiz() {
    _wrongAnswerDelayTimer?.cancel();
    _failAnimationTimer?.cancel();
    _victoryAnimationTimer?.cancel();
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasSubmittedAnswer = false;
      _isShowingFailAnimation = false;
      _isShowingVictoryAnimation = false;
      _score = 0;
      _quizCompleted = false;
      _userAnswers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.building.themeColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        decoration: BoxDecoration(
          color: _bgDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Building Action Panel Themed Header ──
            _buildPanelHeader(themeColor),

            const Divider(color: _borderDim, height: 1),

            // ── Clean Tab Bar ──
            _buildPixelTabBar(themeColor),

            const Divider(color: _borderDim, height: 1),

            // ── Panel Body ──
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(themeColor)
                  : _errorMessage != null
                      ? _buildErrorState(themeColor)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildExplanationTab(themeColor),
                            _buildQuizTab(themeColor),
                            _buildTutorialTab(themeColor),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER (MATCHING IMAGE 1) ───────────────────────────────────────────────
  Widget _buildPanelHeader(Color themeColor) {
    return ValueListenableBuilder<PlayerProfile?>(
      valueListenable: PlayerProfile.notifier,
      builder: (context, profileValue, _) {
        final profile = profileValue ?? PlayerProfile.current ?? const PlayerProfile();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _bgMid,
          child: Row(
            children: [
              // Building Icon Box (Matching Image 1)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeColor, width: 1.5),
                ),
                child: Icon(widget.building.icon, color: themeColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Building Name & Level Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.building.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Level Badge (Matching Image 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _peach.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _peach, width: 1),
                          ),
                          child: Text(
                            'LEVEL ${profile.level}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _peach,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Player Stats Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🪙 ${profile.coins}', style: const TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('💎 ${profile.gems}', style: const TextStyle(color: _purple, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('⚡ ${profile.energy}', style: const TextStyle(color: _blue, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Circular Close Button (Matching Image 1)
              InkWell(
                onTap: widget.onClose,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Icon(Icons.close, color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── TAB BAR ─────────────────────────────────────────────────────────────────
  Widget _buildPixelTabBar(Color themeColor) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          color: _bgMid,
          child: Row(
            children: [
              _pixelTab(0, Icons.auto_awesome, 'LESSON', themeColor),
              _pixelTab(1, Icons.quiz, 'QUIZ', themeColor),
              _pixelTab(2, Icons.help_outline, 'GUIDE', themeColor),
            ],
          ),
        );
      },
    );
  }

  Widget _pixelTab(int index, IconData icon, String label, Color themeColor) {
    final isActive = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _bgDark : _bgMid,
            border: Border(
              bottom: BorderSide(
                color: isActive ? themeColor : Colors.transparent,
                width: 2.5,
              ),
              right: index < 2 ? const BorderSide(color: _borderDim, width: 1) : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isActive ? themeColor : _textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isActive ? themeColor : _textMuted,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── LOADING STATE ───────────────────────────────────────────────────────────
  Widget _buildLoadingState(Color themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'CONSULTING AI TUTOR...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _gold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Generating lesson & 4 MCQs for level ${widget.building.level}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _textMuted),
          ),
        ],
      ),
    );
  }

  // ── ERROR STATE ─────────────────────────────────────────────────────────────
  Widget _buildErrorState(Color themeColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surface,
                shape: BoxShape.circle,
                border: Border.all(color: _red, width: 2),
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 36, color: _red),
            ),
            const SizedBox(height: 16),
            const Text(
              'ERROR OCCURRED',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _red),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _textMuted, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: _pixelButton(
                label: 'RETRY',
                color: themeColor,
                onTap: _fetchContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EXPLANATION TAB ─────────────────────────────────────────────────────────
  Widget _buildExplanationTab(Color themeColor) {
    if (_content == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic Badge (Matching Image 1 subject pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category, size: 12, color: themeColor),
                const SizedBox(width: 5),
                Text(
                  _content!.topic.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Voice Narration Bar
          _buildPixelAudioBar(
            title: 'VOICE NARRATION',
            subtitle: 'ElevenLabs AI',
            onPlayToggle: _togglePlayExplanationAudio,
            themeColor: themeColor,
          ),

          const SizedBox(height: 14),

          // Concept Explanation Card
          _pixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      'CONCEPT OVERVIEW',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: _borderDim, height: 1),
                const SizedBox(height: 12),
                Text(
                  _content!.explanation,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _textPrimary,
                    height: 1.55,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 18),

          // Start Quiz Button
          _pixelButton(
            label: '▶  START QUIZ',
            color: themeColor,
            onTap: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }

  // ── AUDIO BAR ───────────────────────────────────────────────────────────────
  Widget _buildPixelAudioBar({
    required String title,
    required String subtitle,
    required VoidCallback onPlayToggle,
    required Color themeColor,
  }) {
    final double maxSec = _audioDuration.inMilliseconds.toDouble();
    final double currentSec = _audioPosition.inMilliseconds
        .toDouble()
        .clamp(0.0, maxSec > 0 ? maxSec : 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderDim, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Play button
              GestureDetector(
                onTap: onPlayToggle,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isLoadingAudio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Icon(
                            _isPlayingAudio ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 22,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _gold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPlayingAudio ? 'PLAYING...' : subtitle,
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.graphic_eq, color: _isPlayingAudio ? themeColor : _textMuted, size: 20),
            ],
          ),
          if (maxSec > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                color: _surface,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: maxSec > 0 ? currentSec / maxSec : 0.0,
                  child: Container(color: themeColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── QUIZ TAB ────────────────────────────────────────────────────────────────
  Widget _buildQuizTab(Color themeColor) {
    if (_content == null || _content!.questions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_quizCompleted) {
      return _buildQuizCompletedView(themeColor);
    }

    // IF ALL QUESTIONS ANSWERED CORRECTLY: Full section shows the epic sword blast victory animation!
    if (_isShowingVictoryAnimation) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            _buildPixelStepProgressBar(
              current: _content!.questions.length,
              total: _content!.questions.length,
              color: _gold,
            ),
            const SizedBox(height: 14),
            _buildVictoryAnimationCard(themeColor),
          ],
        ),
      );
    }

    final currentQ = _content!.questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question counter row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q ${_currentQuestionIndex + 1} / ${_content!.questions.length}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: themeColor),
              ),
              GestureDetector(
                onTap: () => _playQuestionAudio(currentQ.question),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _blue.withValues(alpha: 0.5), width: 1.2),
                  ),
                  child: const Icon(Icons.volume_up, color: _blue, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stepped progress bar
          _buildPixelStepProgressBar(
            current: _currentQuestionIndex + 1,
            total: _content!.questions.length,
            color: themeColor,
          ),
          const SizedBox(height: 12),

          // IF ATTEMPT WRONG: The whole section shows the falling GIF, not questions in the bottom!
          if (_isShowingFailAnimation)
            _buildFailAnimationCard(themeColor, currentQ)
          else ...[
            _pixelCard(
              child: Text(
                currentQ.question,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
            ).animate().fadeIn(duration: 200.ms),
            const SizedBox(height: 10),

            // 4 Option tiles
            ...List.generate(4, (index) {
              final optionText = currentQ.options[index];
              final isSelected = _selectedOptionIndex == index;
              final isCorrect = index == currentQ.correctIndex;

              Color tileBg = _bgPanel;
              Color tileBorder = _borderDim;
              Color textColor = _textPrimary;
              Color labelColor = _textMuted;
              Widget? trailingIcon;

              if (_hasSubmittedAnswer) {
                if (isCorrect) {
                  tileBg = _green.withValues(alpha: 0.15);
                  tileBorder = _green;
                  textColor = _green;
                  labelColor = _green;
                  trailingIcon = const Icon(Icons.check_circle_rounded, color: _green, size: 18);
                } else if (isSelected) {
                  tileBg = _red.withValues(alpha: 0.15);
                  tileBorder = _red;
                  textColor = _red;
                  labelColor = _red;
                  trailingIcon = const Icon(Icons.cancel_rounded, color: _red, size: 18);
                }
              } else if (isSelected) {
                tileBg = themeColor.withValues(alpha: 0.15);
                tileBorder = themeColor;
                textColor = Colors.white;
                labelColor = themeColor;
              }

              return GestureDetector(
                onTap: _isShowingFailAnimation ? null : () => _selectAnswer(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tileBorder, width: isSelected ? 1.8 : 1.2),
                  ),
                  child: Row(
                    children: [
                      // Letter badge (A, B, C, D)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: tileBorder.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: labelColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 6),
                        trailingIcon,
                      ],
                    ],
                  ),
                ),
              );
            }),

            // Answer explanation box (for correct answers or when submitted)
            if (_hasSubmittedAnswer) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _blue.withValues(alpha: 0.5), width: 1.2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: _blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentQ.explanation,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
            ],

            const SizedBox(height: 12),

            // Submit / Next Button
            _pixelButton(
              label: _hasSubmittedAnswer
                  ? (_currentQuestionIndex < _content!.questions.length - 1
                      ? 'NEXT  ▶'
                      : 'FINISH QUIZ ★')
                  : 'SUBMIT ANSWER',
              color: themeColor,
              onTap: (_selectedOptionIndex == null || _isShowingFailAnimation || _isShowingVictoryAnimation)
                  ? null
                  : (_hasSubmittedAnswer ? _nextQuestion : _submitAnswer),
            ),
          ],
        ],
      ),
    );
  }

  // ── FAIL ANIMATION SECTION ──────────────────────────────────────────────────
  Widget _buildFailAnimationCard(Color themeColor, MCQuestion currentQ) {
    return GestureDetector(
      onTap: _advanceFromFailAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _red, width: 2),
          boxShadow: [
            BoxShadow(
              color: _red.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top failure banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.heart_broken_rounded, color: _red, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'WRONG ANSWER! 💔',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _red,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _red.withValues(alpha: 0.6), width: 1),
                  ),
                  child: const Text(
                    'SKIP ▶',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Full-section arena container with seamless taupe backing for the falling GIF
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF917E6C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _red.withValues(alpha: 0.6), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Image.asset(
                  AssetPaths.quizFailAnimation,
                  fit: BoxFit.contain,
                  height: 280,
                  gaplessPlayback: true,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status message
            const Text(
              'HERO TOOK DAMAGE & COLLAPSED!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: _red,
              ),
            ),
            const SizedBox(height: 14),

            // Next question button
            _pixelButton(
              label: _currentQuestionIndex < _content!.questions.length - 1
                  ? 'NEXT QUESTION  ▶'
                  : 'FINISH QUIZ ★',
              color: _red,
              onTap: _advanceFromFailAnimation,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).shake(duration: 300.ms, hz: 4);
  }

  // ── VICTORY ANIMATION SECTION ───────────────────────────────────────────────
  Widget _buildVictoryAnimationCard(Color themeColor) {
    return GestureDetector(
      onTap: _finishQuizFromVictoryAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top victory banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: _gold, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'PERFECT VICTORY! ★',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _gold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _gold.withValues(alpha: 0.6), width: 1),
                  ),
                  child: const Text(
                    'SKIP ▶',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Full-section arena container with seamless taupe backing for the victory GIF
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF917E6C),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withValues(alpha: 0.6), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Center(
                child: Image.asset(
                  AssetPaths.quizVictoryAnimation,
                  fit: BoxFit.contain,
                  height: 280,
                  gaplessPlayback: true,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status message
            const Text(
              'ALL QUESTIONS CORRECT! SWORD BLAST!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: _green,
              ),
            ),
            const SizedBox(height: 14),

            // Claim rewards button
            _pixelButton(
              label: 'CLAIM REWARDS ★',
              color: _gold,
              onTap: _finishQuizFromVictoryAnimation,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms);
  }

  // ── QUIZ COMPLETED VIEW ─────────────────────────────────────────────────────
  Widget _buildQuizCompletedView(Color themeColor) {
    final int xpAwarded = _score * 50 + 50;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Victory GIF or Trophy for completed score
            if (_score == (_content?.questions.length ?? 4))
              Container(
                height: 180,
                width: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF917E6C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    AssetPaths.quizVictoryAnimation,
                    fit: BoxFit.contain,
                    height: 180,
                    gaplessPlayback: true,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold, width: 2),
                ),
                child: const Icon(Icons.emoji_events_rounded, size: 48, color: _gold),
              ),
            const SizedBox(height: 18),
            const Text(
              'QUIZ COMPLETE!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _gold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$_score / ${_content?.questions.length ?? 4} CORRECT',
              style: const TextStyle(fontSize: 13, color: _textMuted, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // XP reward pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: themeColor, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: themeColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpAwarded FOCUS XP',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeColor),
                  ),
                ],
              ),
            ),

            if (_score == (_content?.questions.length ?? 4)) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _purple, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_rounded, color: _purple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '+5 DIAMONDS! PERFECT SCORE ★',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _purple),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Retake button
                GestureDetector(
                  onTap: _restartQuiz,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _borderDim, width: 1.5),
                    ),
                    child: const Text(
                      'RETAKE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _textPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Close button
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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

  // ── TUTORIAL TAB ────────────────────────────────────────────────────────────
  Widget _buildTutorialTab(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPixelAudioBar(
            title: 'VOICE TUTORIAL',
            subtitle: 'ElevenLabs AI',
            onPlayToggle: _playTutorialAudio,
            themeColor: themeColor,
          ),
          const SizedBox(height: 14),
          _pixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline, size: 16, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      'HOW TO PLAY',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: themeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: _borderDim, height: 1),
                const SizedBox(height: 12),
                const Text(
                  _tutorialText,
                  style: TextStyle(
                    fontSize: 13,
                    color: _textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED HELPERS ──────────────────────────────────────────────────────────

  /// Card container matching Image 1 surface design.
  Widget _pixelCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderDim, width: 1.5),
      ),
      child: child,
    );
  }

  /// Stepped progress bar matching Image 1 XP bar.
  Widget _buildPixelStepProgressBar({
    required int current,
    required int total,
    required Color color,
  }) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i < current;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: filled ? color : _surface,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  /// Reusable button matching Image 1 LEARN button.
  Widget _pixelButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final bool enabled = onTap != null;
    final bool isDarkText = color == _gold || color == _green || color == widget.building.themeColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? color : _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.8) : _borderDim,
            width: 1.5,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: enabled ? (isDarkText ? Colors.black : Colors.white) : _textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
