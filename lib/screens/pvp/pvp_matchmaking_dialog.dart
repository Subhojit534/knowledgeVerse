import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/player_profile.dart';
import '../../models/pvp_models.dart';
import '../../services/pvp_service.dart';

/// Animated Matchmaking Dialog with magic radar circle and opponent reveal
class PvPMatchmakingDialog extends StatefulWidget {
  final String subject;
  final int stakeCoins;
  final bool isRanked;

  const PvPMatchmakingDialog({
    super.key,
    required this.subject,
    this.stakeCoins = 50,
    this.isRanked = true,
  });

  @override
  State<PvPMatchmakingDialog> createState() => _PvPMatchmakingDialogState();
}

class _PvPMatchmakingDialogState extends State<PvPMatchmakingDialog>
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  late AnimationController _pulseController;
  late AnimationController _revealController;

  bool _isSearching = true;
  PvPSession? _session;
  PvPCombatant? _player;
  PvPCombatant? _opponent;
  int _countdown = 3;
  Timer? _countdownTimer;

  // Pixel art palette
  static const Color _bgDark = Color(0xFF0C0C1F);
  static const Color _bgPanel = Color(0xFF16162E);
  static const Color _gold = Color(0xFFF2CA50);
  static const Color _borderDim = Color(0xFF4D4635);
  static const Color _cyan = Color(0xFF70D6FF);
  static const Color _crimson = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startMatchmaking();
  }

  Future<void> _startMatchmaking() async {
    final myClientId = await PvPService.getClientId();
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final myName = profile.name.trim().toLowerCase();

    while (_isSearching && mounted) {
      final session = await PvPService.matchmake(
        subject: widget.subject,
        stakeCoins: widget.stakeCoins,
        isRanked: widget.isRanked,
      );

      if (!mounted || !_isSearching) return;

      if (session != null) {
        final combatantList = session.combatants.values.toList();
        PvPCombatant? user;
        PvPCombatant? opp;

        for (final c in combatantList) {
          final isMe = c.id == myClientId ||
              (profile.id.isNotEmpty && c.id == profile.id) ||
              (myName.isNotEmpty && c.name.trim().toLowerCase() == myName);
          if (isMe) {
            user = c;
          } else {
            opp = c;
          }
        }

        user ??= combatantList.isNotEmpty ? combatantList[0] : null;
        opp ??= combatantList.length > 1
            ? combatantList.firstWhere((c) => c.id != user?.id, orElse: () => combatantList[1])
            : null;

        setState(() {
          _session = session;
          _player = user;
          _opponent = opp;
          _isSearching = false;
        });

        _revealController.forward();
        _startBattleCountdown();
        return;
      }

      // If in real duel mode and waiting for another player, wait 600ms then poll again
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }



  void _startBattleCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop(_session);
        }
      }
    });
  }

  void _cancelSearch() {
    _isSearching = false;
    PvPService.cancelMatchmaking();
    if (mounted) {
      Navigator.of(context).pop(null);
    }
  }

  @override
  void dispose() {
    _isSearching = false;
    _radarController.dispose();
    _pulseController.dispose();
    _revealController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _bgDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _bgPanel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _borderDim),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sports_esports_rounded, color: _gold, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${widget.subject.toUpperCase()} DUEL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 9,
                          color: _gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_isSearching) ...[
                // Searching Animation
                SizedBox(
                  height: 150,
                  width: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulsing ring
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Container(
                            width: 110 + (_pulseController.value * 35),
                            height: 110 + (_pulseController.value * 35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _cyan.withOpacity(0.4 - (_pulseController.value * 0.3)),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                      // Rotating radar
                      RotationTransition(
                        turns: _radarController,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _gold.withOpacity(0.6), width: 2),
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                _gold.withOpacity(0.0),
                                _gold.withOpacity(0.35),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Center Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bgPanel,
                        ),
                        child: const Center(
                          child: Icon(Icons.search_rounded, color: _gold, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.isRanked ? 'SEARCHING FOR REAL DUELIST...' : 'CONNECTING TO AI SCHOLAR...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(fontSize: 8.5, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isRanked
                      ? 'Waiting for another human player to enter...'
                      : 'Setting up practice arena',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(fontSize: 10.5, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _cancelSearch,
                  child: Text(
                    'CANCEL SEARCH',
                    style: GoogleFonts.pressStart2p(fontSize: 8.5, color: _crimson),
                  ),
                ),

              ] else ...[
                // Opponent Found Banner
                Text(
                  'OPPONENT FOUND!',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: _gold,
                    shadows: [
                      const Shadow(color: _gold, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // VS Combatants Card
                ScaleTransition(
                  scale: CurvedAnimation(parent: _revealController, curve: Curves.elasticOut),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Player Card
                      Flexible(child: _buildCombatantBadge(_player, isLeft: true)),

                      // VS Clash
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _crimson.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _crimson, width: 1.5),
                              ),
                              child: Text(
                                'VS',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 10,
                                  color: _crimson,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.stakeCoins} 🪙',
                              style: GoogleFonts.pressStart2p(fontSize: 7.5, color: _gold),
                            ),
                          ],
                        ),
                      ),

                      // Opponent Card
                      Flexible(child: _buildCombatantBadge(_opponent, isLeft: false)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Countdown display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _bgPanel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _gold),
                  ),
                  child: Text(
                    'BATTLE IN $_countdown...',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: _cyan,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombatantBadge(PvPCombatant? c, {required bool isLeft}) {
    final name = c?.name ?? (isLeft ? 'You' : 'Opponent');
    final title = c?.title ?? 'Academy Scholar';
    final initial = c?.avatarInitial ?? (name.isNotEmpty ? name[0].toUpperCase() : '?');
    final color = c?.avatarColor ?? (isLeft ? _gold : _cyan);
    final rating = c?.rating ?? 1200;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.pressStart2p(
                fontSize: 18,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: Colors.white54),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: _bgPanel,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _borderDim),
          ),
          child: Text(
            '$rating MMR',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              color: _gold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
