import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/player_profile.dart';
import '../../models/pvp_models.dart';
import '../../services/pvp_service.dart';
import 'pvp_battle_screen.dart';
import 'pvp_matchmaking_dialog.dart';
import 'pvp_manual_duel_dialog.dart';


/// Compact & Polished 16-Bit RPG PvP Duel Arena Hub
class PvPArenaHubScreen extends StatefulWidget {
  const PvPArenaHubScreen({super.key});

  @override
  State<PvPArenaHubScreen> createState() => _PvPArenaHubScreenState();
}

class _PvPArenaHubScreenState extends State<PvPArenaHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  PvPStats? _myStats;
  bool _isLoadingStats = true;

  // Selected arena & stake
  int _currentArenaIndex = 0;
  String _selectedSubject = 'Mathematics';
  int _selectedStake = 50;


  // Challenges list
  int _inboxFilterIndex = 0; // 0: Incoming, 1: Outgoing
  List<PvPChallengeItem> _receivedChallenges = [];
  List<PvPChallengeItem> _sentChallenges = [];
  bool _isLoadingChallenges = false;


  // Leaderboard
  List<PvPStats> _leaderboard = [];
  bool _isLoadingLeaderboard = false;

  // 16-Bit Pixel Subject Arenas with Island Image Assets
  final List<Map<String, dynamic>> _subjectArenas = [
    {
      'name': 'Mathematics',
      'tag': 'MATH',
      'icon': Icons.calculate_outlined,
      'imagePath': 'assets/images/island_math.png',
      'color': const Color(0xFFF2CA50),
      'subtitle': 'Algebra, Calculus & Geometry',
      'perk': '+25% LOGIC XP',
      'difficulty': 'MEDIUM',
    },
    {
      'name': 'Computer Science',
      'tag': 'CS',
      'icon': Icons.code_rounded,
      'imagePath': 'assets/images/island_cs.png',
      'color': const Color(0xFF60A5FA),
      'subtitle': 'Algorithms, Data Structs & Logic',
      'perk': '+30% FOCUS XP',
      'difficulty': 'HARD',
    },
    {
      'name': 'Physics & Space',
      'tag': 'PHYSICS',
      'icon': Icons.rocket_launch_outlined,
      'imagePath': 'assets/images/island_physics.png',
      'color': const Color(0xFFB388FF),
      'subtitle': 'Cosmic Laws, Optics & Motion',
      'perk': '+20% POWER XP',
      'difficulty': 'HARD',
    },
    {
      'name': 'Chemistry',
      'tag': 'CHEM',
      'icon': Icons.science_outlined,
      'imagePath': 'assets/images/island_chemistry.png',
      'color': const Color(0xFF82C0A0),
      'subtitle': 'Formulas, Reactions & Elements',
      'perk': '+20% ALCHEMY XP',
      'difficulty': 'MEDIUM',
    },
    {
      'name': 'Biology & Life',
      'tag': 'BIO',
      'icon': Icons.eco_outlined,
      'imagePath': 'assets/images/island_biology.png',
      'color': const Color(0xFF9DDCBB),
      'subtitle': 'Genetics, Ecology & Cells',
      'perk': '+20% LIFE XP',
      'difficulty': 'EASY',
    },
    {
      'name': 'History & Civics',
      'tag': 'HISTORY',
      'icon': Icons.account_balance_outlined,
      'imagePath': 'assets/images/island_history.png',
      'color': const Color(0xFFFAB387),
      'subtitle': 'Ancient Empires & World Lore',
      'perk': '+20% LORE XP',
      'difficulty': 'EASY',
    },
    {
      'name': 'Omni-Duel',
      'tag': 'ALL DOMAINS',
      'icon': Icons.auto_awesome,
      'imagePath': 'assets/images/island_pvp.png',
      'color': const Color(0xFFFF6B6B),
      'subtitle': 'Grand Mixed Domain Clash!',
      'perk': '+50% BONUS GLORY',
      'difficulty': 'EXTREME',
    },
  ];

  // 16-Bit Pixel RPG Palette
  static const Color _bgDark = Color(0xFF0C0C1F);
  static const Color _bgPanel = Color(0xFF1E1E32);
  static const Color _bgCard = Color(0xFF141424);
  static const Color _gold = Color(0xFFF2CA50);
  static const Color _borderDim = Color(0xFF4D4635);
  static const Color _green = Color(0xFF82C0A0);
  static const Color _crimson = Color(0xFFFF6B6B);
  static const Color _cyan = Color(0xFF70D6FF);

  Timer? _hubDuelPollTimer;
  bool _isAutoJoiningDuel = false;
  final Set<String> _consumedChallengeIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadInitialData();
    _startHubDuelPolling();
  }

  void _startHubDuelPolling() {
    _hubDuelPollTimer?.cancel();
    _hubDuelPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isAutoJoiningDuel) {
        _checkActiveDuelStatus();
      }
    });
  }

  Future<void> _checkActiveDuelStatus() async {
    try {
      final data = await PvPService.getChallenges();
      if (!mounted) return;

      final sent = (data['sent'] as List<PvPChallengeItem>? ?? []).where((c) => !_consumedChallengeIds.contains(c.id)).toList();
      final received = (data['received'] as List<PvPChallengeItem>? ?? []).where((c) => !_consumedChallengeIds.contains(c.id)).toList();

      setState(() {
        _sentChallenges = sent;
        _receivedChallenges = received;
      });

      // If any outgoing duel challenge was ACCEPTED by the friend -> AUTOMATICALLY START MATCH!
      if (!_isAutoJoiningDuel) {
        final accepted = sent.firstWhere(
          (c) => c.status == 'active' &&
                 c.sessionId != null &&
                 c.sessionId!.isNotEmpty &&
                 !_consumedChallengeIds.contains(c.id),
          orElse: () => PvPChallengeItem(
            id: '',
            challengerId: '',
            challengerName: '',
            challengedId: '',
            challengedName: '',
            subject: '',
            stakeCoins: 0,
            status: '',
            createdAt: '',
          ),
        );

        if (accepted.id.isNotEmpty && accepted.sessionId != null) {
          _isAutoJoiningDuel = true;
          _consumedChallengeIds.add(accepted.id);

          final session = await PvPService.getSession(accepted.sessionId!);
          if (session != null && mounted) {
            PvPService.consumeChallenge(challengeId: accepted.id, sessionId: session.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚔️ DUEL ACCEPTED BY ${accepted.challengedName?.toUpperCase() ?? "FRIEND"}! STARTING MATCH...',
                    style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.black)),
                backgroundColor: const Color(0xFFF2CA50),
                duration: const Duration(seconds: 2),
              ),
            );

            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PvPBattleScreen(session: session)),
            );

            if (mounted) {
              _isAutoJoiningDuel = false;
              _loadData();
            }
          } else {
            _isAutoJoiningDuel = false;
          }
        }
      }
    } catch (_) {}
  }


  void _handleTabChange() {
    if (_tabController.index == 1) {
      _loadChallenges();
    } else if (_tabController.index == 2) {
      _loadLeaderboard();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadInitialData(),
      _loadChallenges(),
      _loadLeaderboard(),
    ]);
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingStats = true);
    final stats = await PvPService.getUserStats();
    if (mounted) {
      setState(() {
        _myStats = stats;
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoadingChallenges = true);
    final data = await PvPService.getChallenges();
    if (mounted) {
      setState(() {
        _receivedChallenges = data['received'] ?? [];
        _sentChallenges = data['sent'] ?? [];
        _isLoadingChallenges = false;
      });
    }
  }


  Future<void> _loadLeaderboard() async {
    setState(() => _isLoadingLeaderboard = true);
    final list = await PvPService.getLeaderboard();
    if (mounted) {
      setState(() {
        _leaderboard = list;
        _isLoadingLeaderboard = false;
      });
    }
  }


  Future<void> _startMatchmaking({bool isRanked = true}) async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final cost = isRanked ? _selectedStake : 0;

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

    final session = await showDialog<PvPSession>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PvPMatchmakingDialog(
        subject: _selectedSubject,
        stakeCoins: cost,
        isRanked: isRanked,
      ),
    );

    if (session != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PvPBattleScreen(session: session),
        ),
      );
      if (mounted) _loadData();
    }
  }

  Future<void> _openManualDuelDialog() async {
    final session = await showDialog<PvPSession>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PvPManualDuelDialog(
        initialSubject: _selectedSubject,
        initialStake: _selectedStake,
      ),
    );

    if (session != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PvPBattleScreen(session: session),
        ),
      );
      if (mounted) _loadData();
    }
  }

  Future<void> _joinExistingSession(String sessionId) async {
    final session = await PvPService.getSession(sessionId);
    if (session != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PvPBattleScreen(session: session),
        ),
      );
      if (mounted) _loadData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SESSION HAS EXPIRED OR COMPLETED', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
            backgroundColor: _crimson,
          ),
        );
      }
    }
  }

  Future<void> _acceptChallenge(PvPChallengeItem challenge) async {
    _consumedChallengeIds.add(challenge.id);
    final session = await PvPService.respondToChallenge(
      challengeId: challenge.id,
      accept: true,
      subject: challenge.subject,
    );

    if (session != null && mounted) {
      PvPService.consumeChallenge(challengeId: challenge.id, sessionId: session.id);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PvPBattleScreen(session: session),
        ),
      );
      if (mounted) _loadData();
    }
  }

  Future<void> _declineChallenge(PvPChallengeItem challenge) async {
    _consumedChallengeIds.add(challenge.id);
    await PvPService.respondToChallenge(
      challengeId: challenge.id,
      accept: false,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DUEL DECLINED', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
          backgroundColor: _bgPanel,
        ),
      );
      _loadChallenges();
    }
  }


  @override
  void dispose() {
    _hubDuelPollTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }


  Map<String, dynamic> get _activeArena {
    return _subjectArenas.firstWhere(
      (a) => a['name'] == _selectedSubject,
      orElse: () => _subjectArenas[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _myStats;
    final rating = stats?.rating ?? 1200;
    final tier = stats?.tier ?? PvPTier.fromRating(rating);
    final profile = PlayerProfile.current ?? const PlayerProfile();

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── 1. ULTRA-COMPACT TOP APP BAR WITH EMBEDDED DUELIST STATS ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                color: _bgPanel,
                border: Border(bottom: BorderSide(color: _borderDim, width: 1.5)),
              ),
              child: Row(
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _bgCard,
                        border: Border.all(color: _borderDim),
                      ),
                      child: const Icon(Icons.arrow_back, color: _gold, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Duelist Tier & Rating Pill (Compact)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _bgCard,
                        border: Border.all(color: tier.color, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tier.icon, color: tier.color, size: 14),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              tier.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 7.5,
                                color: tier.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$rating',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              color: _gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Player Coins & Streak Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _bgCard,
                      border: Border.all(color: _borderDim),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${profile.coins} 🪙',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: _gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if ((stats?.currentStreak ?? 0) > 0) ...[
                          const SizedBox(width: 5),
                          Text(
                            '🔥${stats?.currentStreak}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: _crimson,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── 2. COMPACT TAB SELECTOR ──────────────────────────────────
            Container(
              color: _bgPanel,
              child: TabBar(
                controller: _tabController,
                indicatorColor: _gold,
                indicatorWeight: 2.5,
                labelColor: _gold,
                unselectedLabelColor: Colors.white54,
                labelStyle: GoogleFonts.pressStart2p(fontSize: 8),
                tabs: [
                  const Tab(text: '⚔️ ARENAS'),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✉️ INBOX'),
                        if (_receivedChallenges.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: _crimson,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_receivedChallenges.length}',
                              style: GoogleFonts.pressStart2p(fontSize: 6, color: Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: '🏆 RANKS'),
                ],
              ),
            ),

            // ─── 3. TAB VIEWS ─────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCompactArenasTab(),
                  _buildCompactChallengesTab(),
                  _buildCompactLeaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zero-Scroll Arcade Hub: Symmetric Side-by-Side Duel Setup + Subject Castle Showcase
  Widget _buildCompactArenasTab() {
    final currentArena = _subjectArenas[_currentArenaIndex.clamp(0, _subjectArenas.length - 1)];
    final arenaColor = currentArena['color'] as Color;
    final stats = _myStats;


    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── LEFT: DUEL & ARENA DETAILS BOX (RICH & FILLED ~60%) ───
          Expanded(
            flex: 13,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _bgPanel,
                border: Border.all(color: arenaColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: arenaColor.withOpacity(0.18),
                    blurRadius: 6,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top section: Subject Details Header & Stake Chips
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Subject Title & Difficulty Tag

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${currentArena['name']}'.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 9.5,
                                color: _gold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: arenaColor.withOpacity(0.2),
                              border: Border.all(color: arenaColor, width: 1.5),
                            ),
                            child: Text(
                              currentArena['difficulty'] as String,
                              style: GoogleFonts.pressStart2p(
                                fontSize: 6.5,
                                color: arenaColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Curriculum / Subtitle Topics
                      Text(
                        currentArena['subtitle'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Stake Section
                      Text(
                        'SELECT COIN STAKE:',
                        style: GoogleFonts.pressStart2p(fontSize: 7, color: Colors.white70),
                      ),
                      const SizedBox(height: 6),

                      // Horizontal 3-Stake Chips (Spacious & Filled)
                      Row(
                        children: [
                          _buildMiniStakeChip(50, 'BRAWLER', const Color(0xFF82C0A0)),
                          const SizedBox(width: 4),
                          _buildMiniStakeChip(100, 'WARRIOR', const Color(0xFFF2CA50)),
                          const SizedBox(width: 4),
                          _buildMiniStakeChip(250, 'CHAMP', const Color(0xFFFF6B6B)),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Duel Rule / Reward Tip Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                        decoration: BoxDecoration(
                          color: _bgCard,
                          border: Border.all(color: _borderDim),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events, color: _gold, size: 15),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Winner takes 2x coins & climbs MMR rating!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9.5,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bottom Action Buttons (Ranked Duel, Practice, Manual Duel)
                  Column(
                    children: [
                      Row(
                        children: [
                          // Start Ranked Duel Button
                          Expanded(
                            flex: 7,
                            child: InkWell(
                              onTap: () => _startMatchmaking(isRanked: true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9.5),
                                decoration: BoxDecoration(
                                  color: _gold,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.flash_on, color: Colors.black, size: 13),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'DUEL ($_selectedStake 🪙)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          // Free Practice Button
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              onTap: () => _startMatchmaking(isRanked: false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: _bgCard,
                                  border: Border.all(color: _cyan, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    '🤖 PRACTICE',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.pressStart2p(fontSize: 7, color: _cyan),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Manual Duel / Private Room Code Button
                      InkWell(
                        onTap: _openManualDuelDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 7.5),
                          decoration: BoxDecoration(
                            color: _bgCard,
                            border: Border.all(color: _gold.withOpacity(0.8), width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.vpn_key_outlined, color: _gold, size: 12),
                              const SizedBox(width: 5),
                              Text(
                                '🎯 MANUAL DUEL / ROOM CODE',
                                style: GoogleFonts.pressStart2p(fontSize: 7, color: _gold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ),



          const SizedBox(width: 8),


          // ─── RIGHT: PURE SUBJECT CASTLE SHOWCASE BOX (~40%) ───
          Expanded(
            flex: 9,
            child: Container(
              decoration: BoxDecoration(
                color: _bgPanel,
                border: Border.all(color: arenaColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: arenaColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Navigation Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    decoration: const BoxDecoration(
                      color: _bgCard,
                      border: Border(bottom: BorderSide(color: _borderDim)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Prev Arrow (<)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_currentArenaIndex > 0) {
                                _currentArenaIndex--;
                              } else {
                                _currentArenaIndex = _subjectArenas.length - 1;
                              }
                              _selectedSubject = _subjectArenas[_currentArenaIndex]['name'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: _bgPanel,
                              border: Border.all(color: _gold),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: _gold, size: 11),
                          ),
                        ),

                        // District Badge & Counter
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                              color: arenaColor,
                              child: Text(
                                currentArena['tag'] as String,
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 7,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentArenaIndex + 1}/7',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 7.5,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),

                        // Next Arrow (>)
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_currentArenaIndex < _subjectArenas.length - 1) {
                                _currentArenaIndex++;
                              } else {
                                _currentArenaIndex = 0;
                              }
                              _selectedSubject = _subjectArenas[_currentArenaIndex]['name'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: _bgPanel,
                              border: Border.all(color: _gold),
                            ),
                            child: const Icon(Icons.arrow_forward_ios, color: _gold, size: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Full-Height Castle Artwork Showcase
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _bgCard,
                          border: Border.all(color: _borderDim, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset(
                            currentArena['imagePath'] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              currentArena['icon'] as IconData,
                              size: 42,
                              color: arenaColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),



        ],
      ),
    );
  }

  Widget _buildMiniStakeChip(int stake, String tierName, Color accent) {
    final isSel = _selectedStake == stake;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedStake = stake),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: isSel ? accent.withOpacity(0.25) : _bgCard,
            border: Border.all(
              color: isSel ? accent : _borderDim,
              width: isSel ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$stake 🪙',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: isSel ? accent : Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                tierName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8.5,
                  color: isSel ? accent : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }





  /// Compact 16-Bit Challenges Tab with Horizontal Incoming/Outgoing Switcher
  Widget _buildCompactChallengesTab() {

    if (_isLoadingChallenges) {
      return const Center(child: CircularProgressIndicator(color: _gold));
    }

    final isIncoming = _inboxFilterIndex == 0;
    final currentList = isIncoming ? _receivedChallenges : _sentChallenges;

    return RefreshIndicator(
      onRefresh: _loadChallenges,
      color: _gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Switcher Buttons
            Row(
              children: [
                // Incoming Tab
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _inboxFilterIndex = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isIncoming ? _gold.withOpacity(0.2) : _bgPanel,
                        border: Border.all(
                          color: isIncoming ? _gold : _borderDim,
                          width: isIncoming ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, color: _gold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'INCOMING (${_receivedChallenges.length})',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7.5,
                              color: isIncoming ? _gold : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Outgoing Tab
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _inboxFilterIndex = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isIncoming ? _cyan.withOpacity(0.2) : _bgPanel,
                        border: Border.all(
                          color: !isIncoming ? _cyan : _borderDim,
                          width: !isIncoming ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.outbox, color: _cyan, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'OUTGOING (${_sentChallenges.length})',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7.5,
                              color: !isIncoming ? _cyan : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content List
            if (currentList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _bgPanel,
                  border: Border.all(color: _borderDim),
                ),
                child: Center(
                  child: Text(
                    isIncoming
                        ? 'No pending challenges received.\nInvite friends from the Social screen!'
                        : 'No pending challenges sent.\nChallenge your rivals!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white54),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final c = currentList[index];

                  if (isIncoming) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _bgPanel,
                        border: Border.all(color: _gold),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sports_esports, color: _gold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.challengerName.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.subject} • ${c.stakeCoins} 🪙',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _gold),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _acceptChallenge(c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  color: _green,
                                  child: Text(
                                    'ACCEPT ⚔️',
                                    style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _declineChallenge(c),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  color: _crimson,
                                  child: Text(
                                    'DECLINE',
                                    style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    );
                  } else {
                    final bool isAccepted = c.status == 'active' && c.sessionId != null && c.sessionId!.isNotEmpty;

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _bgPanel,
                        border: Border.all(color: isAccepted ? _green : _borderDim, width: isAccepted ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(isAccepted ? Icons.play_circle_fill : Icons.hourglass_top, color: isAccepted ? _green : _cyan, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TO: ${c.challengedName?.toUpperCase() ?? "FRIEND"}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.subject} • ${c.stakeCoins} 🪙',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: isAccepted ? _green : Colors.white54),
                                ),
                              ],
                            ),
                          ),
                          if (isAccepted)
                            InkWell(
                              onTap: () => _joinExistingSession(c.sessionId!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                color: _green,
                                child: Text(
                                  'JOIN BATTLE ⚔️',
                                  style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.black),
                                ),
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => _loadChallenges(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                color: _bgCard,
                                child: Text(
                                  'WAITING ⏳',
                                  style: GoogleFonts.pressStart2p(fontSize: 6.5, color: _gold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                },
              ),
          ],
        ),
      ),
    );
  }


  /// Side-by-Side 16-Bit PvP Leaderboard Tab (Left: Top 3 Graph Podium, Right: Ladder #4+ & Player Rank)
  Widget _buildCompactLeaderboardTab() {
    if (_isLoadingLeaderboard) {
      return const Center(child: CircularProgressIndicator(color: _gold));
    }

    if (_leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 48, color: _gold),
            const SizedBox(height: 10),
            Text(
              'NO DUELISTS YET!',
              style: GoogleFonts.pressStart2p(fontSize: 10, color: _gold),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the arena to claim the #1 spot on the ladder!',
              style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // Determine current user's rank
    final myStats = _myStats;
    int myRank = -1;
    if (myStats != null) {
      myRank = _leaderboard.indexWhere((e) => e.userId == myStats.userId);
      if (myRank != -1) myRank += 1;
    }

    final top3 = _leaderboard.take(3).toList();
    final remaining = _leaderboard.length > 3 ? _leaderboard.sublist(3) : <PvPStats>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── LEFT: TOP 3 CHAMPIONS GRAPH PODIUM BOX ───────────────
          Expanded(
            flex: 11,
            child: _buildLeftPodiumGraph(top3),
          ),

          const SizedBox(width: 8),

          // ─── RIGHT: CHALLENGER LADDER (#4+) & YOUR RANK BOX ───────
          Expanded(
            flex: 12,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _bgPanel,
                border: Border.all(color: _cyan, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _cyan.withOpacity(0.18),
                    blurRadius: 6,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Right Box Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.military_tech, color: _cyan, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'LADDER RANK',
                            style: GoogleFonts.pressStart2p(fontSize: 9, color: _cyan),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: _bgCard,
                        child: Text(
                          '${_leaderboard.length} TOTAL',
                          style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // Pinned "YOU" Player Rank Card (Increased font size)
                  _buildMyRankCard(myStats, myRank),

                  const SizedBox(height: 7),

                  // Scrollable Ladder List for #4+ (Increased font size)
                  Expanded(
                    child: remaining.isEmpty
                        ? Center(
                            child: Text(
                              'NO MORE CHALLENGERS',
                              style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white38),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: remaining.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 5),
                            itemBuilder: (context, index) {
                              final rank = index + 4;
                              final duelist = remaining[index];
                              return _buildLeaderboardTile(duelist, rank);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Left Box: Stepped Graph Podium (2nd Silver, 1st Gold Center, 3rd Bronze)
  Widget _buildLeftPodiumGraph(List<PvPStats> top3) {
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _bgPanel,
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: _gold, size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'TOP 3 DUELISTS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pressStart2p(fontSize: 9, color: _gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Stepped Bar Graph Layout (Overflow-Proof Responsive Heights)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalH = constraints.maxHeight;
                const topInfoH = 48.0;
                final availableBarSpace = totalH > topInfoH ? totalH - topInfoH : 30.0;
                final h1 = availableBarSpace * 0.96;
                final h2 = availableBarSpace * 0.70;
                final h3 = availableBarSpace * 0.52;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // #2 Silver Pillar (Left)
                    if (second != null)
                      Expanded(
                        child: _buildPodiumGraphBar(
                          entry: second,
                          rank: 2,
                          crown: '🥈',
                          accentColor: const Color(0xFFC0C0C0),
                          pillarHeight: h2,
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 4),

                    // #1 Gold Champion Pillar (Center, Tallest)
                    if (first != null)
                      Expanded(
                        child: _buildPodiumGraphBar(
                          entry: first,
                          rank: 1,
                          crown: '👑 🥇',
                          accentColor: const Color(0xFFF2CA50),
                          pillarHeight: h1,
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 4),

                    // #3 Bronze Pillar (Right)
                    if (third != null)
                      Expanded(
                        child: _buildPodiumGraphBar(
                          entry: third,
                          rank: 3,
                          crown: '🥉',
                          accentColor: const Color(0xFFCD7F32),
                          pillarHeight: h3,
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Podium Graph Bar with FittedBox protection to eliminate inner overflows
  Widget _buildPodiumGraphBar({
    required PvPStats entry,
    required int rank,
    required String crown,
    required Color accentColor,
    required double pillarHeight,
  }) {
    final isFirst = rank == 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown Icon
        Text(crown, style: TextStyle(fontSize: isFirst ? 15 : 12)),
        const SizedBox(height: 1),

        // Player Name (Larger font)
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: isFirst ? 8.5 : 7.5,
            color: isFirst ? _gold : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),

        // MMR Score (Larger font)
        Text(
          '${entry.rating} MMR',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(
            fontSize: isFirst ? 9.5 : 8.5,
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),

        // Stepped Pillar Bar with FittedBox
        Container(
          height: pillarHeight,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(isFirst ? 0.3 : 0.18),
            border: Border.all(color: accentColor, width: isFirst ? 2 : 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isFirst ? 0.32 : 0.18),
                blurRadius: isFirst ? 6 : 3,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: accentColor,
                  child: Text(
                    '#$rank',
                    style: GoogleFonts.pressStart2p(
                      fontSize: isFirst ? 9.5 : 8.5,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Icon(entry.tier.icon, size: isFirst ? 17 : 13, color: accentColor),
                const SizedBox(height: 2),
                Text(
                  entry.tier.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pressStart2p(
                    fontSize: isFirst ? 6.5 : 5.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Pinned Player Rank Card with Larger Fonts
  Widget _buildMyRankCard(PvPStats? myStats, int myRank) {
    final rating = myStats?.rating ?? 1200;
    final tier = myStats?.tier ?? PvPTier.fromRating(rating);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border.all(color: _cyan, width: 1.5),
        boxShadow: [
          BoxShadow(color: _cyan.withOpacity(0.18), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
            color: _cyan,
            child: Text(
              myRank > 0 ? '#$myRank' : '#--',
              style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'YOU (DUELIST)',
                  style: GoogleFonts.pressStart2p(fontSize: 7.5, color: _cyan),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tier.label} • ${myStats?.wins ?? 0}W/${myStats?.losses ?? 0}L • 🔥${myStats?.currentStreak ?? 0}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(fontSize: 8.5, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
            decoration: BoxDecoration(
              color: _bgPanel,
              border: Border.all(color: _gold),
            ),
            child: Text(
              '$rating',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                color: _gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Challenger Ladder Row (#4+) with Larger Fonts
  Widget _buildLeaderboardTile(PvPStats entry, int rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5.5),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border.all(color: _borderDim, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              '#$rank',
              style: GoogleFonts.pressStart2p(
                fontSize: 7.5,
                color: Colors.white60,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: _bgPanel,
              border: Border.all(color: entry.tier.color, width: 1),
            ),
            child: Icon(entry.tier.icon, color: entry.tier.color, size: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.tier.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8.5,
                          color: entry.tier.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '• ${entry.wins}W/${entry.losses}L',
                      style: GoogleFonts.jetBrainsMono(fontSize: 8.5, color: Colors.white54),
                    ),
                    if (entry.currentStreak > 1) ...[
                      const SizedBox(width: 3),
                      Text(
                        '🔥${entry.currentStreak}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 8.5, color: _crimson, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
            decoration: BoxDecoration(
              color: _bgPanel,
              border: Border.all(color: _borderDim),
            ),
            child: Text(
              '${entry.rating}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: _gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

