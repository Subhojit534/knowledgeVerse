import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import '../services/api_service.dart';
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

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedCategory = 'GLOBAL';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<LeaderboardEntry> _entries = [];
  String _myPlayerName = 'EXPLORER';

  @override
  void initState() {
    super.initState();
    _fetchLiveLeaderboard();
  }

  Future<void> _fetchLiveLeaderboard([String category = 'GLOBAL']) async {
    final profile = await PlayerProfile.load();
    if (profile != null && profile.name.trim().isNotEmpty && mounted) {
      setState(() {
        _myPlayerName = profile.name.trim().toUpperCase();
      });
    }

    try {
      final queryParam = category.toUpperCase() == 'GLOBAL' ? '' : '?category=$category';
      final res = await ApiService.get('/api/leaderboard$queryParam');
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final rawList = data['leaderboard'] as List<dynamic>? ?? [];
        final List<LeaderboardEntry> parsed = [];

        for (final item in rawList) {
          final map = item as Map<String, dynamic>;
          final rank = map['rank'] as int? ?? (parsed.length + 1);
          final name = map['name'] as String? ?? 'Wizard';
          final title = map['title'] as String? ?? 'Scholar';
          final level = map['level'] as int? ?? 1;
          final score = map['score'] as int? ?? (map['xp'] as int? ?? 0);
          final streakDays = map['streakDays'] as int? ?? 7;
          final initial = (name.isNotEmpty) ? name.substring(0, 1).toUpperCase() : 'W';

          Color crownColor = Colors.transparent;
          if (rank == 1) crownColor = const Color(0xFFF2CA50);
          if (rank == 2) crownColor = const Color(0xFFC0C0C0);
          if (rank == 3) crownColor = const Color(0xFFCD7F32);

          parsed.add(LeaderboardEntry(
            rank: rank,
            name: name,
            title: title,
            level: level,
            score: score,
            guildTag: map['guildTag'] as String? ?? 'ARC',
            streakDays: streakDays,
            crownColor: crownColor,
            avatarInitial: initial,
            avatarColor: rank == 1
                ? const Color(0xFFF2CA50)
                : rank == 2
                    ? const Color(0xFFDEB7FF)
                    : const Color(0xFF60A5FA),
            domainMastery: map['domainMastery'] as String? ?? 'General (85%)',
          ));
        }

        if (mounted) {
          setState(() {
            _entries = parsed;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('❌ [LeaderboardScreen Error]: $e');
    }

    if (mounted) {
      setState(() {
        _entries = [];
      });
    }
  }

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
    final list = _entries;
    final filteredEntries = list.where((e) {
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
                        _buildGrandPodium(list),
                        const SizedBox(height: 18),

                        // Category Filter Pills
                        _buildCategoryPills(),
                        const SizedBox(height: 14),

                        // Rankings Roster Cards (#4 onwards)
                        if (filteredEntries.where((e) => e.rank > 3).isEmpty && filteredEntries.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'END OF CURRENT RANKINGS',
                              style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white24),
                            ),
                          )
                        else
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
              child: _buildStickyPersonalBar(filteredEntries),
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
  Widget _buildGrandPodium(List<LeaderboardEntry> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E32),
          border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.emoji_events_outlined, color: Color(0xFFF2CA50), size: 36),
            const SizedBox(height: 10),
            Text(
              'AWAITING CHAMPIONS',
              style: GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFF2CA50)),
            ),
            const SizedBox(height: 8),
            Text(
              'No players ranked yet. Complete quiz domains to claim your crown!',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFD0C5AF), height: 1.6),
            ),
          ],
        ),
      );
    }

    final top1 = list.isNotEmpty ? list[0] : null;
    final top2 = list.length > 1 ? list[1] : null;
    final top3 = list.length > 2 ? list[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Rank 2 (Left)
        Expanded(child: _buildPodiumStep(top2, rankNumber: 2, height: 100, color: const Color(0xFFC0C0C0))),
        const SizedBox(width: 10),

        // Rank 1 (Center - Highest)
        Expanded(child: _buildPodiumStep(top1, rankNumber: 1, height: 125, isGold: true, color: const Color(0xFFF2CA50))),
        const SizedBox(width: 10),

        // Rank 3 (Right)
        Expanded(child: _buildPodiumStep(top3, rankNumber: 3, height: 85, color: const Color(0xFFCD7F32))),
      ],
    );
  }

  Widget _buildPodiumStep(
    LeaderboardEntry? entry, {
    required int rankNumber,
    required double height,
    required Color color,
    bool isGold = false,
  }) {
    if (entry == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rankNumber == 1 ? '👑' : rankNumber == 2 ? '🥈' : '🥉',
              style: TextStyle(fontSize: isGold ? 24 : 18)),
          const SizedBox(height: 4),
          Container(
            width: isGold ? 48 : 38,
            height: isGold ? 48 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFF141424),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: const Center(
              child: Text('?', style: TextStyle(color: Colors.white24, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'VACANT',
            style: GoogleFonts.pressStart2p(
              fontSize: 7.5,
              color: Colors.white38,
            ),
          ),
          Text(
            '-- XP',
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: Colors.white24,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF141424),
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
              ],
            ),
            child: Center(
              child: Text(
                '#$rankNumber',
                style: GoogleFonts.pressStart2p(
                  fontSize: isGold ? 20 : 14,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _inspectPlayer(entry),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.rank == 1 ? '👑' : entry.rank == 2 ? '🥈' : '🥉',
            style: TextStyle(fontSize: isGold ? 24 : 18),
          ),
          const SizedBox(height: 4),
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
    final categories = ['GLOBAL', 'MATH', 'PHYSICS', 'CHEMISTRY', 'BIOLOGY', 'HISTORY', 'CS', 'GUILDS'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() => _selectedCategory = cat);
                _fetchLiveLeaderboard(cat);
              },
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

  bool _isMe(LeaderboardEntry entry) {
    if (_myPlayerName.isEmpty || _myPlayerName == 'EXPLORER') return false;
    final entryClean = entry.name.trim().toLowerCase();
    final myClean = _myPlayerName.trim().toLowerCase();
    return entryClean == myClean || entryClean.contains(myClean) || myClean.contains(entryClean);
  }

  // ─── ROSTER RANK CARD (#4 onwards) ──────────────────────────────────────────
  Widget _buildRankCard(LeaderboardEntry entry) {
    final bool isUser = _isMe(entry);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF1E3A28) : const Color(0xFF1E1E32),
        border: Border.all(
          color: isUser ? const Color(0xFF4ADE80) : const Color(0xFF4D4635),
          width: isUser ? 2.5 : 1,
        ),
        boxShadow: isUser
            ? const [
                BoxShadow(
                    color: Color(0x664ADE80), offset: Offset(2, 2), blurRadius: 4),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF065F46) : const Color(0xFF141424),
              border: Border.all(
                  color: isUser ? const Color(0xFF4ADE80) : const Color(0xFF4D4635)),
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
              border: Border.all(
                  color: isUser ? const Color(0xFF4ADE80) : entry.avatarColor),
            ),
            child: Center(
              child: Text(
                entry.avatarInitial,
                style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: isUser ? const Color(0xFF4ADE80) : entry.avatarColor),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: isUser ? const Color(0xFF4ADE80) : Colors.white,
                        ),
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2CA50),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.pressStart2p(
                              fontSize: 6, color: Colors.black),
                        ),
                      ),
                    ],
                  ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
  Widget _buildStickyPersonalBar(List<LeaderboardEntry> list) {
    final myIndex = list.indexWhere((e) => _isMe(e));
    final int myRank = myIndex >= 0 ? myIndex + 1 : list.length + 1;
    final LeaderboardEntry myEntry = myIndex >= 0
        ? list[myIndex]
        : LeaderboardEntry(
            rank: myRank,
            name: _myPlayerName,
            title: 'Scholar',
            level: 1,
            score: 0,
            guildTag: 'ARC',
            streakDays: 1,
            crownColor: Colors.transparent,
            avatarInitial: _myPlayerName.isNotEmpty ? _myPlayerName.substring(0, 1) : 'E',
            avatarColor: const Color(0xFFF2CA50),
            domainMastery: 'General (0%)',
          );
    final String rankBadge = myRank <= 3 ? 'TOP 1% 🏆' : myRank <= 10 ? 'TOP 5% ⚔️' : 'SCHOLAR 📜';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3D2B),
        border: Border.all(color: const Color(0xFF4ADE80), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x884ADE80),
            offset: Offset(2, 2),
            blurRadius: 4,
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
                    'YOUR RANK: #$myRank ($rankBadge)',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7.5,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_myPlayerName • ${myEntry.score} XP • LVL ${myEntry.level}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 6.5,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              border: Border.all(color: const Color(0xFF4ADE80)),
            ),
            child: Text(
              '▲ TOP 3%',
              style: GoogleFonts.pressStart2p(
                fontSize: 6.5,
                color: const Color(0xFF4ADE80),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
