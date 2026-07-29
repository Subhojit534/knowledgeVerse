import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class LeaderboardEntry {
  final int rank;
  final String name;
  final String title;
  final int level;
  final int score;
  final String guildTag;
  final int streakDays;
  final Color crownColor;
  final String avatarInitial;
  final Color avatarColor;
  final String domainMastery;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.title,
    required this.level,
    required this.score,
    required this.guildTag,
    required this.streakDays,
    required this.crownColor,
    required this.avatarInitial,
    required this.avatarColor,
    required this.domainMastery,
  });
}

/// Authentic 16-Bit RPG Hall of Champions Leaderboard Screen.
/// Features 16-bit 3D Crown Stage, double-gold pixel borders (#F2CA50),
/// 0-blur pixel shadows, Press Start 2P typography, and a Centered Inspector Dialog.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedCategory = 'GLOBAL';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<LeaderboardEntry> _allEntries = [
    LeaderboardEntry(
      rank: 1,
      name: 'Victoria Prime',
      title: 'Grand Archon',
      level: 25,
      score: 48920,
      guildTag: 'OMN',
      streakDays: 45,
      crownColor: Color(0xFFF2CA50),
      avatarInitial: 'V',
      avatarColor: Color(0xFFF2CA50),
      domainMastery: 'Mathematics (100%)',
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Elena Vance',
      title: 'Grand Sorceress',
      level: 22,
      score: 42150,
      guildTag: 'ARC',
      streakDays: 38,
      crownColor: Color(0xFFC0C0C0),
      avatarInitial: 'E',
      avatarColor: Color(0xFFDEB7FF),
      domainMastery: 'Physics (98%)',
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Marcus Sol',
      title: 'Quantum Master',
      level: 20,
      score: 38400,
      guildTag: 'ARC',
      streakDays: 29,
      crownColor: Color(0xFFCD7F32),
      avatarInitial: 'M',
      avatarColor: Color(0xFF60A5FA),
      domainMastery: 'Quantum Computing (95%)',
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Darius Vance',
      title: 'Cipher Lord',
      level: 19,
      score: 31200,
      guildTag: 'HEX',
      streakDays: 24,
      crownColor: Colors.transparent,
      avatarInitial: 'D',
      avatarColor: Color(0xFF82C0A0),
      domainMastery: 'Computer Science (94%)',
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Lyra Moon',
      title: 'Royal Archivist',
      level: 18,
      score: 28950,
      guildTag: 'LIB',
      streakDays: 19,
      crownColor: Colors.transparent,
      avatarInitial: 'L',
      avatarColor: Color(0xFFF28B82),
      domainMastery: 'History (99%)',
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'Kaelen Drake',
      title: 'Algorithm King',
      level: 17,
      score: 26400,
      guildTag: 'ARC',
      streakDays: 16,
      crownColor: Colors.transparent,
      avatarInitial: 'K',
      avatarColor: Color(0xFF82C0A0),
      domainMastery: 'Computer Science (90%)',
    ),
    LeaderboardEntry(
      rank: 7,
      name: 'Aria Star',
      title: 'Alchemy Specialist',
      level: 16,
      score: 24100,
      guildTag: 'ARC',
      streakDays: 14,
      crownColor: Colors.transparent,
      avatarInitial: 'A',
      avatarColor: Color(0xFFDEB7FF),
      domainMastery: 'Chemistry (88%)',
    ),
    LeaderboardEntry(
      rank: 14,
      name: 'Alex Rover (You)',
      title: 'Civilization Architect',
      level: 14,
      score: 18450,
      guildTag: 'ARC',
      streakDays: 12,
      crownColor: Colors.transparent,
      avatarInitial: 'A',
      avatarColor: Color(0xFFF2CA50),
      domainMastery: 'Mathematics (85%)',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _inspectPlayer(LeaderboardEntry player) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E32),
            border: Border.all(color: const Color(0xFFF2CA50), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar: Player Info + Corner (X) Close Button
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF28283D),
                      border: Border.all(color: player.avatarColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        player.avatarInitial,
                        style: GoogleFonts.pressStart2p(
                            fontSize: 14, color: player.avatarColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: const Color(0xFFF2CA50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${player.title} • [${player.guildTag}]',
                          style: GoogleFonts.pressStart2p(
                              fontSize: 7, color: const Color(0xFFD0C5AF)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28283D),
                      border: Border.all(color: const Color(0xFFF2CA50)),
                    ),
                    child: Text(
                      'RANK #${player.rank}',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 8, color: const Color(0xFFF2CA50)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Corner (X) Close Icon Button
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        border: Border.all(color: const Color(0xFFF2CA50)),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFF2CA50),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF4D4635)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildModalStat('TOTAL XP', '${player.score}', Icons.workspace_premium),
                  _buildModalStat('LEVEL', 'LVL ${player.level}', Icons.star_rounded),
                  _buildModalStat('STREAK', '${player.streakDays}d 🔥', Icons.local_fire_department_rounded),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141424),
                  border: Border.all(color: const Color(0xFF82C0A0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded,
                        color: Color(0xFF82C0A0), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'MASTERY: ${player.domainMastery.toUpperCase()}',
                        style: GoogleFonts.pressStart2p(
                            fontSize: 7.5, color: const Color(0xFF82C0A0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visit Player Base Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2CA50),
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.castle_rounded,
                      color: Colors.black, size: 16),
                  label: Text(
                    'VISIT PLAYER BASE',
                    style: GoogleFonts.pressStart2p(
                        fontSize: 8, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF2CA50), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.pressStart2p(fontSize: 6.5, color: const Color(0xFFD0C5AF)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _allEntries.where((e) {
      if (_searchQuery.isEmpty) return true;
      return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.guildTag.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopHeaderBar(context),

                // Main Viewport
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    child: Column(
                      children: [
                        // 16-Bit Search Bar
                        _buildSearchBar(),
                        const SizedBox(height: 14),

                        // 16-Bit 3D Legendary Crown Stage
                        _buildGrandPodium(),
                        const SizedBox(height: 18),

                        // Category Filter Pills
                        _buildCategoryPills(),
                        const SizedBox(height: 14),

                        // Rankings Roster Cards (#4 onwards)
                        ...filteredEntries
                            .where((e) => e.rank > 3)
                            .map((entry) => _buildRankCard(entry)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Floating Bottom Personal Rank Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              child: _buildStickyPersonalBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF2CA50), width: 2),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF28283D),
                border: Border.all(color: const Color(0xFFF2CA50), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFF2CA50), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Color(0xFFF2CA50), size: 18),
                const SizedBox(width: 8),
                Text(
                  'HALL OF CHAMPIONS',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ],
            ),
          ),

          // Season Timer Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: const Color(0xFFDEB7FF), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded,
                    color: Color(0xFFDEB7FF), size: 12),
                const SizedBox(width: 4),
                Text(
                  'SEASON 4 • 3D 14H',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: const Color(0xFFDEB7FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'SEARCH CHAMPION OR GUILD...',
          hintStyle: GoogleFonts.pressStart2p(color: Colors.white38, fontSize: 7),
          border: InputBorder.none,
          icon: const Icon(Icons.search_rounded, color: Color(0xFFF2CA50), size: 16),
        ),
      ),
    );
  }

  // ─── 16-BIT 3D STAGE SHOWCASE ──────────────────────────────────────────────
  Widget _buildGrandPodium() {
    final top1 = _allEntries[0];
    final top2 = _allEntries[1];
    final top3 = _allEntries[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (Left)
        Expanded(child: _buildPodiumStep(top2, height: 100)),
        const SizedBox(width: 10),

        // Rank 1 (Center - Highest)
        Expanded(child: _buildPodiumStep(top1, height: 125, isGold: true)),
        const SizedBox(width: 10),

        // Rank 3 (Right)
        Expanded(child: _buildPodiumStep(top3, height: 85)),
      ],
    );
  }

  Widget _buildPodiumStep(LeaderboardEntry entry,
      {required double height, bool isGold = false}) {
    return GestureDetector(
      onTap: () => _inspectPlayer(entry),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown / Trophy
          Text(
            entry.rank == 1
                ? '👑'
                : entry.rank == 2
                    ? '🥈'
                    : '🥉',
            style: TextStyle(fontSize: isGold ? 24 : 18),
          ),
          const SizedBox(height: 4),

          // Avatar Frame
          Container(
            width: isGold ? 48 : 38,
            height: isGold ? 48 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: entry.crownColor, width: 2),
            ),
            child: Center(
              child: Text(
                entry.avatarInitial,
                style: GoogleFonts.pressStart2p(
                  fontSize: isGold ? 16 : 12,
                  color: entry.crownColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            entry.name.split(' ')[0],
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.pressStart2p(
              fontSize: 7.5,
              color: Colors.white,
            ),
          ),
          Text(
            '${entry.score} XP',
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: const Color(0xFFF2CA50),
            ),
          ),
          const SizedBox(height: 4),

          // Pedestal Base
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isGold ? const Color(0xFF38321E) : const Color(0xFF1E1E32),
              border: Border.all(color: entry.crownColor, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: GoogleFonts.pressStart2p(
                  fontSize: isGold ? 20 : 14,
                  color: entry.crownColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY FILTER PILLS ──────────────────────────────────────────────────
  Widget _buildCategoryPills() {
    final categories = ['GLOBAL', 'MATH', 'PHYSICS', 'HISTORY', 'CS', 'GUILDS'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF2CA50)
                      : const Color(0xFF1E1E32),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF2CA50)
                        : const Color(0xFF4D4635),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: isSelected ? Colors.black : const Color(0xFFD0C5AF),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── ROSTER RANK CARD (#4 onwards) ──────────────────────────────────────────
  Widget _buildRankCard(LeaderboardEntry entry) {
    final bool isUser = entry.name.contains('(You)');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF28283D) : const Color(0xFF1E1E32),
        border: Border.all(
          color: isUser ? const Color(0xFFF2CA50) : const Color(0xFF4D4635),
          width: isUser ? 2 : 1,
        ),
        boxShadow: isUser
            ? const [
                BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF141424),
              border: Border.all(color: const Color(0xFF4D4635)),
            ),
            child: Text(
              '#${entry.rank}',
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: isUser ? const Color(0xFFF2CA50) : Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar Frame
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: entry.avatarColor),
            ),
            child: Center(
              child: Text(
                entry.avatarInitial,
                style: GoogleFonts.pressStart2p(
                    fontSize: 10, color: entry.avatarColor),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.title} • [${entry.guildTag}]',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.5,
                    color: const Color(0xFFD0C5AF),
                  ),
                ),
              ],
            ),
          ),

          // XP Score & Inspect Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score} XP',
                style: GoogleFonts.pressStart2p(
                  fontSize: 7.5,
                  color: const Color(0xFFF2CA50),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _inspectPlayer(entry),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28283D),
                    border: Border.all(color: const Color(0xFFF2CA50)),
                  ),
                  child: Text(
                    'INSPECT',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 6.5,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STICKY PERSONAL RANK BAR ───────────────────────────────────────────────
  Widget _buildStickyPersonalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: Border.all(color: const Color(0xFFF2CA50), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded,
                  color: Color(0xFFF2CA50), size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR RANK: #14 (TOP 5%)',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7.5,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ALEX ROVER • 18,450 XP • 12D STREAK',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 6.5,
                      color: const Color(0xFFD0C5AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: const Color(0xFF82C0A0)),
            ),
            child: Text(
              '▲ +2 TODAY',
              style: GoogleFonts.pressStart2p(
                fontSize: 6.5,
                color: const Color(0xFF82C0A0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
