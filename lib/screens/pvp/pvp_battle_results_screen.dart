import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/player_profile.dart';
import '../../models/pvp_models.dart';
import '../../services/pvp_service.dart';
import 'pvp_battle_screen.dart';
import 'pvp_matchmaking_dialog.dart';


/// Comprehensive Victory / Defeat fanfare results screen — Fully Responsive & Live Rewards
class PvPBattleResultsScreen extends StatefulWidget {
  final PvPSession session;
  final Map<String, dynamic>? finishData;

  const PvPBattleResultsScreen({
    super.key,
    required this.session,
    this.finishData,
  });

  @override
  State<PvPBattleResultsScreen> createState() => _PvPBattleResultsScreenState();
}

class _PvPBattleResultsScreenState extends State<PvPBattleResultsScreen> {
  // Pixel art palette
  static const Color _bgDark = Color(0xFF0C0C1F);
  static const Color _bgPanel = Color(0xFF16162E);
  static const Color _bgCard = Color(0xFF1E1E38);
  static const Color _gold = Color(0xFFF2CA50);
  static const Color _borderDim = Color(0xFF4D4635);
  static const Color _green = Color(0xFF9DDCBB);
  static const Color _crimson = Color(0xFFFF6B6B);
  static const Color _cyan = Color(0xFF70D6FF);

  bool _hasAppliedRewards = false;

  PvPSession get _effectiveSession {
    if (widget.finishData != null && widget.finishData!['session'] != null) {
      try {
        final sessData = widget.finishData!['session'];
        if (sessData is PvPSession) return sessData;
        if (sessData is Map<String, dynamic>) return PvPSession.fromJson(sessData);
      } catch (_) {}
    }
    return widget.session;
  }

  @override
  void initState() {
    super.initState();
    _applyMatchRewards();
  }

  void _applyMatchRewards() {
    if (_hasAppliedRewards) return;
    _hasAppliedRewards = true;

    final session = _effectiveSession;
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final myClientId = PvPService.cachedClientId;
    final myName = profile.name.trim().toLowerCase();

    final combatants = session.combatants.values.toList();
    PvPCombatant? player;
    PvPCombatant? opponent;

    for (final c in combatants) {
      final isMe = (myClientId.isNotEmpty && c.id == myClientId) ||
          (profile.id.isNotEmpty && c.id == profile.id) ||
          (myName.isNotEmpty && c.name.trim().toLowerCase() == myName);
      if (isMe) {
        player = c;
      } else {
        opponent = c;
      }
    }
    player ??= combatants.isNotEmpty ? combatants[0] : null;
    opponent ??= combatants.length > 1
        ? combatants.firstWhere((c) => c.id != player?.id, orElse: () => combatants[1])
        : null;

    final winnerId = widget.finishData?['winnerId'] ?? session.winnerId;
    final isDraw = widget.finishData?['isDraw'] ?? session.isDraw;

    final bool isWinner = !isDraw && (winnerId == player?.id || (winnerId == null && (player?.hp ?? 0) > (opponent?.hp ?? 0)));

    final myRewards = widget.finishData?['rewards']?[player?.id] ?? {};
    final int coinsDelta = myRewards['coinsDelta'] ?? (isWinner ? session.stakeCoins : -session.stakeCoins);
    final int xpEarned = myRewards['xpEarned'] ?? (isWinner ? 120 : (isDraw ? 75 : 45));
    final int ratingDelta = myRewards['ratingDelta'] ?? (isWinner ? 25 : (isDraw ? 5 : -15));

    // Save live match rewards to PlayerProfile and PvPStats
    PvPService.recordMatchResult(
      isWinner: isWinner,
      isDraw: isDraw,
      stakeCoins: session.stakeCoins,
      ratingDelta: ratingDelta,
      coinsDelta: coinsDelta,
      xpEarned: xpEarned,
      subject: session.subject,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _effectiveSession;
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final myClientId = PvPService.cachedClientId;
    final myName = profile.name.trim().toLowerCase();

    final combatants = session.combatants.values.toList();
    PvPCombatant? player;
    PvPCombatant? opponent;

    for (final c in combatants) {
      final isMe = (myClientId.isNotEmpty && c.id == myClientId) ||
          (profile.id.isNotEmpty && c.id == profile.id) ||
          (myName.isNotEmpty && c.name.trim().toLowerCase() == myName);
      if (isMe) {
        player = c;
      } else {
        opponent = c;
      }
    }
    player ??= combatants.isNotEmpty ? combatants[0] : null;
    opponent ??= combatants.length > 1
        ? combatants.firstWhere((c) => c.id != player?.id, orElse: () => combatants[1])
        : null;

    final winnerId = widget.finishData?['winnerId'] ?? session.winnerId;
    final isDraw = widget.finishData?['isDraw'] ?? session.isDraw;

    final bool isWinner = !isDraw && (winnerId == player?.id || (winnerId == null && (player?.hp ?? 0) > (opponent?.hp ?? 0)));
    final bool isLoser = !isDraw && !isWinner;

    final myRewards = widget.finishData?['rewards']?[player?.id] ?? {};
    final int coinsDelta = myRewards['coinsDelta'] ?? (isWinner ? session.stakeCoins : isLoser ? -session.stakeCoins : 0);
    final int xpEarned = myRewards['xpEarned'] ?? (isWinner ? 120 : isLoser ? 45 : 75);
    final int ratingDelta = myRewards['ratingDelta'] ?? (isWinner ? 25 : isLoser ? -15 : 5);
    final int newRating = myRewards['newRating'] ?? ((player?.rating ?? 1165) + ratingDelta);

    final currentTier = PvPTier.fromRating(newRating);


    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // 1. Result Title Banner
              if (isWinner) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withOpacity(0.3),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech, color: _gold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'VICTORY!',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 16,
                          color: _gold,
                          shadows: [const Shadow(color: _gold, blurRadius: 10)],
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 6),
                Text(
                  'Knowledge Champion of ${widget.session.subject}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: _green),
                ),
              ] else if (isDraw) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cyan, width: 2),
                  ),
                  child: Text(
                    'HONORABLE DRAW',
                    style: GoogleFonts.pressStart2p(fontSize: 14, color: _cyan),
                  ),
                ).animate().scale(duration: 400.ms),
                const SizedBox(height: 6),
                Text(
                  'Both duelists displayed supreme mastery!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white70),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _crimson.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _crimson, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sentiment_dissatisfied, color: _crimson, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'DEFEAT',
                        style: GoogleFonts.pressStart2p(fontSize: 15, color: _crimson),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms),
                const SizedBox(height: 6),
                Text(
                  'Study the concepts and challenge again!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white54),
                ),
              ],

              const SizedBox(height: 18),

              // 2. VS Duelists Summary Card (Responsive)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _bgPanel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isWinner ? _gold : (isDraw ? _cyan : _borderDim), width: isWinner ? 1.8 : 1.0),
                ),
                child: Row(
                  children: [
                    // Player
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isWinner ? _gold.withOpacity(0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isWinner ? Border.all(color: _gold.withOpacity(0.3)) : null,
                        ),
                        child: Column(
                          children: [
                            // Winner / Loser Tag
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isWinner ? _gold : (isDraw ? _cyan.withOpacity(0.2) : _crimson.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: isWinner ? _gold : (isDraw ? _cyan : _crimson)),
                              ),
                              child: Text(
                                isWinner ? '👑 WINNER' : (isDraw ? '⚖️ TIED' : '💀 DEFEATED'),
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 6.5,
                                  color: isWinner ? Colors.black : (isDraw ? _cyan : _crimson),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isWinner ? _gold.withOpacity(0.25) : _bgCard,
                                border: Border.all(
                                  color: isWinner ? _gold : (isDraw ? _cyan : _borderDim),
                                  width: isWinner ? 2.5 : 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  player?.avatarInitial ?? 'W',
                                  style: GoogleFonts.pressStart2p(fontSize: 16, color: isWinner ? _gold : (isDraw ? _cyan : Colors.white70)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              player?.name ?? 'You',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.pressStart2p(fontSize: 8.5, color: isWinner ? _gold : Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'HP: ${player?.hp ?? 0}/1000',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: (player?.hp ?? 0) > 0 ? _green : _crimson,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Score: ${player?.score ?? 0}',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _gold, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // VS Center
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _bgCard,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _borderDim),
                            ),
                            child: Text(
                              'VS',
                              style: GoogleFonts.pressStart2p(fontSize: 10, color: _crimson),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ((player?.hp ?? 1000) <= 0 || (opponent?.hp ?? 1000) <= 0) ? 'K.O.' : 'PTS',
                            style: GoogleFonts.pressStart2p(fontSize: 6, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),

                    // Opponent
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLoser ? _gold.withOpacity(0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isLoser ? Border.all(color: _gold.withOpacity(0.3)) : null,
                        ),
                        child: Column(
                          children: [
                            // Opponent Winner / Loser Tag
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLoser ? _gold : (isDraw ? _cyan.withOpacity(0.2) : _crimson.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: isLoser ? _gold : (isDraw ? _cyan : _crimson)),
                              ),
                              child: Text(
                                isLoser ? '👑 WINNER' : (isDraw ? '⚖️ TIED' : '💀 DEFEATED'),
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 6.5,
                                  color: isLoser ? Colors.black : (isDraw ? _cyan : _crimson),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLoser ? _gold.withOpacity(0.25) : _bgCard,
                                border: Border.all(
                                  color: isLoser ? _gold : (isDraw ? _cyan : _borderDim),
                                  width: isLoser ? 2.5 : 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  opponent?.avatarInitial ?? 'O',
                                  style: GoogleFonts.pressStart2p(fontSize: 16, color: isLoser ? _gold : _cyan),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              opponent?.name ?? 'Opponent',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.pressStart2p(fontSize: 8.5, color: isLoser ? _gold : Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'HP: ${opponent?.hp ?? 0}/1000',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: (opponent?.hp ?? 0) > 0 ? _green : _crimson,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Score: ${opponent?.score ?? 0}',
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _cyan, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              // 2.5 Detailed Combat Performance Comparison Card
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderDim),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, color: _gold, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'MATCH STATS',
                              style: GoogleFonts.pressStart2p(fontSize: 8.5, color: _gold),
                            ),
                          ],
                        ),
                        Text(
                          isWinner ? '🏆 VICTORY' : (isDraw ? '⚖️ DRAW' : '💥 DEFEAT'),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7.5,
                            color: isWinner ? _green : (isDraw ? _cyan : _crimson),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStatComparisonRow(
                      'TOTAL SCORE',
                      '${player?.score ?? 0} pts',
                      '${opponent?.score ?? 0} pts',
                      (player?.score ?? 0) >= (opponent?.score ?? 0),
                    ),
                    const SizedBox(height: 6),
                    _buildStatComparisonRow(
                      'FINAL HP',
                      '${player?.hp ?? 0}/1000',
                      '${opponent?.hp ?? 0}/1000',
                      (player?.hp ?? 0) >= (opponent?.hp ?? 0),
                    ),
                    const SizedBox(height: 6),
                    _buildStatComparisonRow(
                      'CORRECT',
                      '${player?.correctCount ?? 0}/${session.questions.length}',
                      '${opponent?.correctCount ?? 0}/${session.questions.length}',
                      (player?.correctCount ?? 0) >= (opponent?.correctCount ?? 0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Rewards & Rating Progression
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _bgPanel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: _gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'BATTLE REWARDS',
                          style: GoogleFonts.pressStart2p(fontSize: 9, color: _gold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Rewards Row (Flexible items)
                    Row(
                      children: [
                        Expanded(
                          child: _buildRewardStat(
                            icon: Icons.monetization_on,
                            iconColor: _gold,
                            label: 'COINS',
                            value: '${coinsDelta >= 0 ? '+' : ''}$coinsDelta',
                            valueColor: coinsDelta >= 0 ? _gold : _crimson,
                          ),
                        ),
                        Expanded(
                          child: _buildRewardStat(
                            icon: Icons.bolt,
                            iconColor: _cyan,
                            label: 'XP',
                            value: '+$xpEarned',
                            valueColor: _cyan,
                          ),
                        ),
                        Expanded(
                          child: _buildRewardStat(
                            icon: Icons.trending_up,
                            iconColor: ratingDelta >= 0 ? _green : _crimson,
                            label: 'MMR',
                            value: '${ratingDelta >= 0 ? '+' : ''}$ratingDelta',
                            valueColor: ratingDelta >= 0 ? _green : _crimson,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: _borderDim),
                    const SizedBox(height: 6),

                    // League Tier Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(currentTier.icon, color: currentTier.color, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              currentTier.label,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 9,
                                color: currentTier.color,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$newRating MMR',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: _gold, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Return to Arena Hub
                      },
                      child: Text(
                        'ARENA HUB',
                        style: GoogleFonts.pressStart2p(fontSize: 8.5, color: _gold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final profile = PlayerProfile.current ?? const PlayerProfile();
                        final cost = widget.session.isRanked ? widget.session.stakeCoins : 0;
                        if (cost > 0 && (profile.coins) < cost) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'INSUFFICIENT COINS! Need $cost 🪙 (You have ${profile.coins} 🪙)',
                                style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF8B0000),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final newSession = await showDialog<PvPSession>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => PvPMatchmakingDialog(
                            subject: widget.session.subject,
                            stakeCoins: widget.session.stakeCoins,
                            isRanked: widget.session.isRanked,
                          ),
                        );

                        if (newSession != null && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PvPBattleScreen(session: newSession),
                            ),
                          );
                        }
                      },


                      child: Text(
                        'REMATCH ⚔️',
                        style: GoogleFonts.pressStart2p(fontSize: 8.5, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.pressStart2p(
            fontSize: 9.5,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildStatComparisonRow(String label, String myVal, String oppVal, bool isAdvantage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderDim.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              myVal,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: isAdvantage ? _gold : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white54),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              oppVal,
              textAlign: TextAlign.end,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: !isAdvantage ? _cyan : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

