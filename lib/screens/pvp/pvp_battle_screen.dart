import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/learning_models.dart';
import '../../models/player_profile.dart';
import '../../models/pvp_models.dart';
import '../../services/pvp_service.dart';
import 'pvp_battle_results_screen.dart';

/// High-Intensity 5-Round PvP Duel Battle Arena Screen — Zero Overflow Guaranteed
class PvPBattleScreen extends StatefulWidget {
  final PvPSession session;

  const PvPBattleScreen({super.key, required this.session});

  @override
  State<PvPBattleScreen> createState() => _PvPBattleScreenState();
}

class _PvPBattleScreenState extends State<PvPBattleScreen>
    with TickerProviderStateMixin {
  late PvPSession _session;
  PvPCombatant? _player;
  PvPCombatant? _opponent;

  int _currentRoundIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerLocked = false;
  bool _showRoundFeedback = false;
  bool _isRoundWon = false;
  String _combatFeedbackText = '';

  // Timer state
  static const int _roundDurationSeconds = 12;
  late int _remainingSeconds;
  Timer? _roundTimer;
  final Stopwatch _roundStopwatch = Stopwatch();

  // Animations
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late AnimationController _projectileController;

  // Floating damage indicators
  String? _playerDamageText;
  String? _opponentDamageText;

  // Pixel art palette
  static const Color _bgDark = Color(0xFF0C0C1F);
  static const Color _bgPanel = Color(0xFF16162E);
  static const Color _bgCard = Color(0xFF1F1F3D);
  static const Color _gold = Color(0xFFF2CA50);
  static const Color _goldDark = Color(0xFF8A6D1C);
  static const Color _borderDim = Color(0xFF4D4635);
  static const Color _green = Color(0xFF9DDCBB);
  static const Color _crimson = Color(0xFFFF6B6B);
  static const Color _cyan = Color(0xFF70D6FF);
  static const Color _purple = Color(0xFFDEB7FF);

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _initCombatants();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _projectileController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _startRoundTimer();
  }

  void _initCombatants() {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final myClientId = PvPService.cachedClientId;
    final myName = profile.name.trim().toLowerCase();

    final combatants = _session.combatants.values.toList();
    for (final c in combatants) {
      final isMe = (myClientId.isNotEmpty && c.id == myClientId) ||
          (profile.id.isNotEmpty && c.id == profile.id) ||
          (myName.isNotEmpty && c.name.trim().toLowerCase() == myName);
      if (isMe) {
        _player = c;
      } else {
        _opponent = c;
      }
    }

    _player ??= combatants.isNotEmpty ? combatants[0] : null;
    _opponent ??= combatants.length > 1
        ? combatants.firstWhere((c) => c.id != _player?.id, orElse: () => combatants[1])
        : null;

    _player ??= PvPCombatant(
      id: myClientId.isNotEmpty ? myClientId : (profile.id.isNotEmpty ? profile.id : 'local-player'),
      name: profile.name.isNotEmpty ? profile.name : 'Scholar Duelist',
      title: profile.learningGoal.isNotEmpty ? profile.learningGoal : 'Academy Duelist',
      avatarInitial: profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'W',
      avatarColor: const Color(0xFFF2CA50),
      avatarIndex: profile.avatarIndex,
      level: profile.level > 0 ? profile.level : 1,
      rating: 1165,
      tier: PvPTier.silver,
      isBot: false,
      hp: 1000,
      score: 0,
    );


    _opponent ??= PvPCombatant(
      id: 'ai-bot-fallback',
      name: 'Sentinel Turing',
      title: 'Logic Scholar',
      avatarInitial: 'T',
      avatarColor: const Color(0xFF70D6FF),
      avatarIndex: 1,
      level: 1,
      rating: 1165,
      tier: PvPTier.silver,
      isBot: true,
      hp: 1000,
      score: 0,
    );
  }



  void _startRoundTimer() {
    _roundTimer?.cancel();
    _remainingSeconds = _roundDurationSeconds;
    _roundStopwatch.reset();
    _roundStopwatch.start();

    _selectedOptionIndex = null;
    _isAnswerLocked = false;
    _showRoundFeedback = false;
    _playerDamageText = null;
    _opponentDamageText = null;

    _roundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    if (_isAnswerLocked) return;
    _handleOptionSelected(-1); // Time up / no answer
  }

  Future<void> _handleOptionSelected(int optionIndex) async {
    if (_isAnswerLocked) return;
    _roundTimer?.cancel();
    _roundStopwatch.stop();

    setState(() {
      _isAnswerLocked = true;
      _selectedOptionIndex = optionIndex;
    });

    final timeTakenMs = _roundStopwatch.elapsedMilliseconds;
    final currentQ = _currentQuestion;
    final isCorrect = optionIndex == currentQ.correctIndex;
    final myClientId = PvPService.cachedClientId;
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final submissionUserId = (myClientId.isNotEmpty ? myClientId : (profile.id.isNotEmpty ? profile.id : 'local-player'));


    // Submit answer to backend
    final response = await PvPService.submitRound(
      sessionId: _session.id,
      userId: _player?.id ?? submissionUserId,
      roundIndex: _currentRoundIndex,
      selectedIndex: optionIndex,
      timeTakenMs: timeTakenMs,
    );

    if (!mounted) return;

    final result = response?.roundResult;
    final damageDealt = result?.damageDealt ?? (isCorrect ? 240 : 0);
    final oppDamage = result?.opponentDamageDealt ?? (!isCorrect ? 200 : 40);
    final playerScoreEarned = result?.scoreAwarded ?? (isCorrect ? (100 + (timeTakenMs < 6000 ? (200 - (timeTakenMs ~/ 60)) : 0)) : 0);
    final oppScoreEarned = result?.opponentScoreAwarded ?? (!isCorrect ? 180 : 0);

    if (response?.session != null) {
      _session = response!.session!;
      _initCombatants();
    } else {
      if (isCorrect) {
        final newOppHp = (_opponent?.hp ?? 1000) - damageDealt;
        _opponent?.hp = newOppHp > 0 ? newOppHp : 0;
        _player?.score = (_player?.score ?? 0) + playerScoreEarned;
      } else {
        final newPlayerHp = (_player?.hp ?? 1000) - oppDamage;
        _player?.hp = newPlayerHp > 0 ? newPlayerHp : 0;
        _opponent?.score = (_opponent?.score ?? 0) + oppScoreEarned;
      }
    }

    setState(() {
      _isRoundWon = isCorrect;
      _showRoundFeedback = true;

      if (isCorrect) {
        _combatFeedbackText = 'CRITICAL SPELL HIT!';
        _opponentDamageText = '-$damageDealt HP';
        _projectileController.forward(from: 0.0);
      } else {
        _combatFeedbackText = 'SPELL MISFIRED!';
        _playerDamageText = '-$oppDamage HP';
        _shakeController.forward(from: 0.0);
      }
    });

    // Pause 1.6 seconds to display combat feedback before proceeding
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    // Check Knockout or End of Match
    final bool isKnockout = (_player?.hp ?? 1000) <= 0 || (_opponent?.hp ?? 1000) <= 0;
    final bool isLastRound = _currentRoundIndex >= _session.questions.length - 1;

    if (isKnockout || isLastRound) {
      _finishMatch();
    } else {
      setState(() {
        _currentRoundIndex++;
      });
      _startRoundTimer();
    }
  }

  Future<void> _finishMatch() async {
    final finishData = await PvPService.finishSession(_session.id);

    if (!mounted) return;

    PvPSession finalSession = _session;
    if (finishData != null && finishData['session'] != null) {
      try {
        if (finishData['session'] is Map<String, dynamic>) {
          finalSession = PvPSession.fromJson(finishData['session'] as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PvPBattleResultsScreen(
          session: finalSession,
          finishData: finishData,
        ),
      ),
    );
  }


  MCQuestion get _currentQuestion {
    if (_session.questions.isEmpty) {
      return const MCQuestion(
        id: 1,
        question: 'What is the sum of angles in a triangle?',
        options: ['180°', '90°', '360°', '270°'],
        correctIndex: 0,
        explanation: 'Interior angles sum to 180°.',
      );
    }
    final idx = _currentRoundIndex.clamp(0, _session.questions.length - 1);
    return _session.questions[idx];
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    _roundStopwatch.stop();
    _shakeController.dispose();
    _pulseController.dispose();
    _projectileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _currentQuestion;
    final timerFraction = (_remainingSeconds / _roundDurationSeconds).clamp(0.0, 1.0);
    final timerColor = _remainingSeconds > 5 ? _green : _remainingSeconds > 2 ? _gold : _crimson;

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final offset = _shakeController.isAnimating
                ? (1.0 - _shakeController.value) * 8.0 * ((_shakeController.value * 12).toInt() % 2 == 0 ? 1 : -1)
                : 0.0;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: Column(
            children: [
              // 1. Top HUD Duel Header
              _buildTopDuelHud(),

              // 2. Round & Timer Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _bgPanel,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _goldDark),
                      ),
                      child: Text(
                        'ROUND ${_currentRoundIndex + 1} / ${_session.questions.length}',
                        style: GoogleFonts.pressStart2p(fontSize: 8, color: _gold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 12,
                              color: _bgPanel,
                            ),
                            FractionallySizedBox(
                              widthFactor: timerFraction,
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: timerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: timerColor.withOpacity(0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_remainingSeconds}s',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 9,
                        color: timerColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Combat Feedback Strip
              if (_showRoundFeedback)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isRoundWon ? _green.withOpacity(0.15) : _crimson.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isRoundWon ? _green : _crimson,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRoundWon ? Icons.bolt : Icons.warning_amber_rounded,
                        color: _isRoundWon ? _green : _crimson,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _combatFeedbackText,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 9,
                          color: _isRoundWon ? _green : _crimson,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 180.ms),

              // 4. Scrollable Question + Options Area (Guarantees zero overflow)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _bgPanel,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _gold.withOpacity(0.6), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withOpacity(0.08),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: _purple.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    _session.subject.toUpperCase(),
                                    style: GoogleFonts.pressStart2p(fontSize: 7.5, color: _purple),
                                  ),
                                ),
                                Text(
                                  '300 MAX PTS',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: _gold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              currentQ.question,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 5. Option Cards (A, B, C, D)
                      ...List.generate(currentQ.options.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildOptionTile(
                            index: index,
                            text: currentQ.options[index],
                            correctIndex: currentQ.correctIndex,
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Bottom Brand Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'KnowledgeVerse PvP Arena',
                  style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopDuelHud() {
    final playerHp = _player?.hp ?? 1000;
    final oppHp = _opponent?.hp ?? 1000;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _bgPanel,
        border: const Border(bottom: BorderSide(color: _borderDim)),
      ),
      child: Row(
        children: [
          // Player HUD (Left)
          Expanded(
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gold.withOpacity(0.2),
                        border: Border.all(color: _gold, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _player?.avatarInitial ?? 'W',
                          style: GoogleFonts.pressStart2p(fontSize: 12, color: _gold),
                        ),
                      ),
                    ),
                    if (_playerDamageText != null)
                      Positioned(
                        top: -8,
                        child: Text(
                          _playerDamageText!,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: _crimson,
                            shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ).animate().fadeIn().moveY(begin: 0, end: -10, duration: 500.ms),
                      ),
                  ],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _player?.name ?? 'You',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      _buildHpBar(playerHp, isLeft: true),
                      const SizedBox(height: 1),
                      Text(
                        'Score: ${_player?.score ?? 0}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8.5, color: _gold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // VS Center Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _crimson.withOpacity(0.2),
                border: Border.all(color: _crimson, width: 1.5),
              ),
              child: Text(
                'VS',
                style: GoogleFonts.pressStart2p(fontSize: 8, color: _crimson),
              ),
            ),
          ),

          // Opponent HUD (Right)
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _opponent?.name ?? 'Opponent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      _buildHpBar(oppHp, isLeft: false),
                      const SizedBox(height: 1),
                      Text(
                        'Score: ${_opponent?.score ?? 0}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8.5, color: _cyan),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cyan.withOpacity(0.2),
                        border: Border.all(color: _cyan, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _opponent?.avatarInitial ?? 'O',
                          style: GoogleFonts.pressStart2p(fontSize: 12, color: _cyan),
                        ),
                      ),
                    ),
                    if (_opponentDamageText != null)
                      Positioned(
                        top: -8,
                        child: Text(
                          _opponentDamageText!,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: _green,
                            shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
                          ),
                        ).animate().fadeIn().moveY(begin: 0, end: -10, duration: 500.ms),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHpBar(int hp, {required bool isLeft}) {
    final fraction = (hp / 1000).clamp(0.0, 1.0);
    final barColor = hp > 500 ? _green : hp > 250 ? _gold : _crimson;

    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth.clamp(50.0, 110.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(
                    height: 7,
                    width: barWidth,
                    color: Colors.black45,
                  ),
                  Container(
                    height: 7,
                    width: barWidth * fraction,
                    decoration: BoxDecoration(
                      color: barColor,
                      boxShadow: [
                        BoxShadow(color: barColor.withOpacity(0.5), blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        Text(
          '$hp / 1000 HP',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 7.5,
            color: barColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String text,
    required int correctIndex,
  }) {
    const optionLetters = ['A', 'B', 'C', 'D'];
    final letter = index < optionLetters.length ? optionLetters[index] : '${index + 1}';

    Color tileBg = _bgCard;
    Color borderCol = _borderDim;
    Color textColor = Colors.white;
    Widget? trailingIcon;

    if (_isAnswerLocked) {
      if (index == correctIndex) {
        tileBg = _green.withOpacity(0.2);
        borderCol = _green;
        textColor = _green;
        trailingIcon = const Icon(Icons.check_circle, color: _green, size: 16);
      } else if (index == _selectedOptionIndex) {
        tileBg = _crimson.withOpacity(0.2);
        borderCol = _crimson;
        textColor = _crimson;
        trailingIcon = const Icon(Icons.cancel, color: _crimson, size: 16);
      }
    } else if (index == _selectedOptionIndex) {
      tileBg = _gold.withOpacity(0.2);
      borderCol = _gold;
    }

    return InkWell(
      onTap: _isAnswerLocked ? null : () => _handleOptionSelected(index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderCol, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: borderCol.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: borderCol),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: textColor),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}
