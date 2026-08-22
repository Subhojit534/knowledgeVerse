import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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

  const BuildingLearningPanel({
    super.key,
    required this.building,
    required this.onClose,
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

  // Tutorial / How To Play text
  static const String _tutorialText =
      "Welcome to the Learning Chamber! Select the Topic tab to hear and read your AI-generated subject lesson. Then switch to the Quiz tab to answer 4 multiple-choice questions. Earning high quiz scores rewards your building with Focus XP and unlocks visual magic upgrades!";

  // Pixel Art Palette
  static const Color _bgDark     = Color(0xFF0C0C1F);
  static const Color _bgMid      = Color(0xFF111125);
  static const Color _bgPanel    = Color(0xFF1A1A2E);
  static const Color _borderDim  = Color(0xFF4D4635);
  static const Color _gold       = Color(0xFFF2CA50);
  static const Color _goldShadow = Color(0xFF3C2F00);
  static const Color _textMuted  = Color(0xFFD0C5AF);
  static const Color _green      = Color(0xFF9DDCBB);
  static const Color _red        = Color(0xFFF28B82);
  static const Color _blue       = Color(0xFF89B4FA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    if (_hasSubmittedAnswer) return;
    setState(() {
      _selectedOptionIndex = optionIndex;
    });
  }

  void _submitAnswer() async {
    if (_selectedOptionIndex == null || _content == null) return;
    final currentQ = _content!.questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionIndex == currentQ.correctIndex;

    setState(() {
      _hasSubmittedAnswer = true;
      _userAnswers[_currentQuestionIndex] = _selectedOptionIndex!;
      if (isCorrect) {
        _score += 1;
      }
    });

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

  void _nextQuestion() async {
    if (_content == null) return;
    if (_currentQuestionIndex < _content!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex += 1;
        _selectedOptionIndex = null;
        _hasSubmittedAnswer = false;
      });
    } else {
      final int xpAward = _score * 50 + 50;
      BuildingManager().addXp(widget.building.id, xpAward);

      // If user got all questions right (4/4), award diamonds!
      if (_score == _content!.questions.length) {
        final currentProfile = PlayerProfile.current ?? await PlayerProfile.load();
        if (currentProfile != null) {
          final updated = currentProfile.withPerfectQuizReward();
          await updated.save();
        }
      }

      setState(() {
        _quizCompleted = true;
      });

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
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasSubmittedAnswer = false;
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        decoration: BoxDecoration(
          color: _bgDark,
          border: Border.all(color: _gold, width: 3),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.25),
              blurRadius: 0,
              spreadRadius: 4,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: _goldShadow.withValues(alpha: 0.6),
              blurRadius: 0,
              spreadRadius: 2,
              offset: const Offset(6, 6),
            ),
            const BoxShadow(
              color: Colors.black87,
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Pixel Art Panel Header ──
            _buildPanelHeader(themeColor),

            // ── Pixel Tab Bar ──
            _buildPixelTabBar(themeColor),

            // ── Pixel Divider ──
            Container(height: 2, color: _borderDim),

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

  // ── PIXEL ART PANEL HEADER ──────────────────────────────────────────────────
  Widget _buildPanelHeader(Color themeColor) {
    return ValueListenableBuilder<PlayerProfile?>(
      valueListenable: PlayerProfile.notifier,
      builder: (context, profileValue, _) {
        final profile = profileValue ?? PlayerProfile.current ?? const PlayerProfile();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _bgMid,
            border: Border(bottom: BorderSide(color: _gold, width: 2)),
          ),
          child: Row(
            children: [
              // Building Icon Box (pixel-bordered)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _bgPanel,
                  border: Border.all(color: themeColor, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                child: Center(
                  child: Icon(widget.building.icon, color: themeColor, size: 20),
                ),
              ),
              const SizedBox(width: 10),

              // Building name & subject
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.building.name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 9,
                        color: _gold,
                        shadows: const [
                          Shadow(color: _goldShadow, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.building.subject} • LVL ${profile.level}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.5,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Live Player Stats Pill inside Learning Panel
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _bgDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4D4635)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🪙 ${profile.coins}', style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFF9E2AF))),
                    const SizedBox(width: 6),
                    Text('💎 ${profile.gems}', style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFCBA6F7))),
                    const SizedBox(width: 6),
                    Text('⚡ ${profile.energy}', style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFF89B4FA))),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Pixel Close Button
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _bgPanel,
                    border: Border.all(color: _red, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.close, color: _red, size: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── PIXEL ART TAB BAR ───────────────────────────────────────────────────────
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
                width: 3,
              ),
              right: index < 2
                  ? const BorderSide(color: _borderDim, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isActive ? themeColor : _textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: isActive ? themeColor : _textMuted,
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
          // Pixel spinner simulation with blinking dots
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'CONSULTING AI...',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: _gold,
              shadows: const [Shadow(color: _goldShadow, offset: Offset(2, 2))],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Generating lesson & 4 MCQs\nfor level ${widget.building.level}',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(fontSize: 7, color: _textMuted),
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
                color: _bgPanel,
                border: Border.all(color: _red, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 36, color: _red),
            ),
            const SizedBox(height: 16),
            Text(
              'ERROR!',
              style: GoogleFonts.pressStart2p(fontSize: 12, color: _red),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 7, color: _textMuted, height: 1.6),
            ),
            const SizedBox(height: 24),
            _pixelButton(
              label: 'RETRY',
              color: themeColor,
              onTap: _fetchContent,
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
          // Topic Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              border: Border.all(color: themeColor, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
            ),
            child: Text(
              _content!.topic.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: themeColor,
              ),
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

          const SizedBox(height: 16),

          // Concept Explanation Card
          _pixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 14, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      'CONCEPT OVERVIEW',
                      style: GoogleFonts.pressStart2p(fontSize: 7, color: themeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: _borderDim),
                const SizedBox(height: 12),
                Text(
                  _content!.explanation,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11.5,
                    color: _textMuted,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

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

  // ── PIXEL AUDIO BAR ─────────────────────────────────────────────────────────
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
        border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pixel Play button
              GestureDetector(
                onTap: onPlayToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: themeColor,
                    border: Border.all(color: _goldShadow, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                  ),
                  child: Center(
                    child: _isLoadingAudio
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Icon(
                            _isPlayingAudio ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 20,
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
                      style: GoogleFonts.pressStart2p(fontSize: 8, color: _gold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPlayingAudio ? 'PLAYING...' : subtitle,
                      style: GoogleFonts.pressStart2p(fontSize: 7, color: _textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.graphic_eq, color: _isPlayingAudio ? themeColor : _textMuted, size: 20),
            ],
          ),
          if (maxSec > 0) ...[
            const SizedBox(height: 8),
            // Pixel stepped progress track
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: _bgMid,
                border: Border.all(color: _borderDim, width: 1.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: maxSec > 0 ? currentSec / maxSec : 0.0,
                child: Container(color: themeColor),
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

    final currentQ = _content!.questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question counter row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q ${_currentQuestionIndex + 1} / ${_content!.questions.length}',
                style: GoogleFonts.pressStart2p(fontSize: 9, color: themeColor),
              ),
              GestureDetector(
                onTap: () => _playQuestionAudio(currentQ.question),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _bgPanel,
                    border: Border.all(color: _blue, width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                  ),
                  child: const Icon(Icons.volume_up, color: _blue, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Pixel stepped progress bar
          _buildPixelStepProgressBar(
            current: _currentQuestionIndex + 1,
            total: _content!.questions.length,
            color: themeColor,
          ),
          const SizedBox(height: 16),

          // Question card
          _pixelCard(
            child: Text(
              currentQ.question,
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: Colors.white,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4 Option tiles
          ...List.generate(4, (index) {
            final optionText = currentQ.options[index];
            final isSelected = _selectedOptionIndex == index;
            final isCorrect = index == currentQ.correctIndex;

            Color tileBg = _bgPanel;
            Color tileBorder = _borderDim;
            Color textColor = _textMuted;
            Color labelColor = _textMuted;
            Widget? trailingIcon;

            if (_hasSubmittedAnswer) {
              if (isCorrect) {
                tileBg = _green.withValues(alpha: 0.12);
                tileBorder = _green;
                textColor = _green;
                labelColor = _green;
                trailingIcon = const Icon(Icons.check, color: _green, size: 16);
              } else if (isSelected) {
                tileBg = _red.withValues(alpha: 0.12);
                tileBorder = _red;
                textColor = _red;
                labelColor = _red;
                trailingIcon = const Icon(Icons.close, color: _red, size: 16);
              }
            } else if (isSelected) {
              tileBg = themeColor.withValues(alpha: 0.15);
              tileBorder = themeColor;
              textColor = themeColor;
              labelColor = themeColor;
            }

            return GestureDetector(
              onTap: () => _selectAnswer(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: tileBg,
                  border: Border.all(color: tileBorder, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                ),
                child: Row(
                  children: [
                    // Pixel letter badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: tileBorder.withValues(alpha: 0.25),
                        border: Border.all(color: tileBorder, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      trailingIcon,
                    ],
                  ],
                ),
              ),
            );
          }),

          // Answer explanation box
          if (_hasSubmittedAnswer) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bgMid,
                border: Border.all(color: _blue, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: _blue, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentQ.explanation,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: _textMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ],

          const SizedBox(height: 16),

          // Submit / Next Button
          _pixelButton(
            label: _hasSubmittedAnswer
                ? (_currentQuestionIndex < _content!.questions.length - 1
                    ? 'NEXT  ▶'
                    : 'FINISH QUIZ ★')
                : 'SUBMIT ANSWER',
            color: themeColor,
            onTap: _selectedOptionIndex == null
                ? null
                : (_hasSubmittedAnswer ? _nextQuestion : _submitAnswer),
          ),
        ],
      ),
    );
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
            // Trophy pixel box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bgPanel,
                border: Border.all(color: _gold, width: 3),
                boxShadow: const [
                  BoxShadow(color: _goldShadow, offset: Offset(4, 4)),
                  BoxShadow(color: Colors.black, offset: Offset(6, 6)),
                ],
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 48, color: _gold),
            ),
            const SizedBox(height: 20),
            Text(
              'QUIZ COMPLETE!',
              style: GoogleFonts.pressStart2p(
                fontSize: 13,
                color: _gold,
                shadows: const [Shadow(color: _goldShadow, offset: Offset(2, 2))],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_score / 4 CORRECT',
              style: GoogleFonts.pressStart2p(fontSize: 9, color: _textMuted),
            ),
            const SizedBox(height: 20),

            // XP reward box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.12),
                border: Border.all(color: themeColor, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: themeColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpAwarded FOCUS XP',
                    style: GoogleFonts.pressStart2p(fontSize: 9, color: themeColor),
                  ),
                ],
              ),
            ),

            if (_score == (_content?.questions.length ?? 4)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF28283D),
                  border: Border.all(color: const Color(0xFFDEB7FF), width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_rounded, color: Color(0xFFDEB7FF), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '+5 DIAMONDS! PERFECT SCORE ★',
                      style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFDEB7FF)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Retake button
                GestureDetector(
                  onTap: _restartQuiz,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _bgPanel,
                      border: Border.all(color: _textMuted, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    child: Text(
                      'RETAKE',
                      style: GoogleFonts.pressStart2p(fontSize: 8, color: _textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Close button
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: themeColor,
                      border: Border.all(color: _goldShadow, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                    ),
                    child: Text(
                      'CLOSE',
                      style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black),
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
          const SizedBox(height: 16),
          _pixelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline, size: 14, color: themeColor),
                    const SizedBox(width: 8),
                    Text(
                      'HOW TO PLAY',
                      style: GoogleFonts.pressStart2p(fontSize: 7, color: themeColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: _borderDim),
                const SizedBox(height: 12),
                Text(
                  _tutorialText,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: _textMuted,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED PIXEL HELPERS ────────────────────────────────────────────────────

  /// Pixel-bordered card container.
  Widget _pixelCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgPanel,
        border: Border.all(color: _borderDim, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
      ),
      child: child,
    );
  }

  /// Pixel-art stepped progress bar (segmented blocks).
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
            height: 10,
            margin: EdgeInsets.only(right: i < total - 1 ? 3 : 0),
            decoration: BoxDecoration(
              color: filled ? color : _bgPanel,
              border: Border.all(color: filled ? color : _borderDim, width: 1.5),
            ),
          ),
        );
      }),
    );
  }

  /// Reusable pixel art button.
  Widget _pixelButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? color : _bgPanel,
          border: Border.all(
            color: enabled ? _goldShadow : _borderDim,
            width: 2,
          ),
          boxShadow: enabled
              ? const [BoxShadow(color: Colors.black, offset: Offset(3, 3))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: enabled ? Colors.black : _textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
