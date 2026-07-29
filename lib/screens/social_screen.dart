import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendModel {
  final String id;
  final String name;
  final String title;
  final int level;
  final int xp;
  final String avatarInitial;
  final Color avatarColor;
  final String district;
  final bool isOnline;
  final String lastActive;
  final int streakDays;
  final String guildName;
  final Map<String, double> subjectProgress;

  const FriendModel({
    required this.id,
    required this.name,
    required this.title,
    required this.level,
    required this.xp,
    required this.avatarInitial,
    required this.avatarColor,
    required this.district,
    required this.isOnline,
    required this.lastActive,
    required this.streakDays,
    required this.guildName,
    required this.subjectProgress,
  });
}

class GuildMemberModel {
  final String name;
  final String role;
  final int level;
  final int weeklyXp;
  final bool isOnline;

  const GuildMemberModel({
    required this.name,
    required this.role,
    required this.level,
    required this.weeklyXp,
    required this.isOnline,
  });
}

class GuildChatMessage {
  final String sender;
  final String role;
  final String text;
  final String time;

  const GuildChatMessage({
    required this.sender,
    required this.role,
    required this.text,
    required this.time,
  });
}

/// Authentic 16-Bit RPG Social & Guild Hall Screen.
/// Features chiseled obsidian containers, double-gold pixel borders (#F2CA50),
/// 0-blur pixel shadows, Press Start 2P typography, and stepped progress bars.
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _activeRailIndex = 0; // 0: Friends, 1: Guild, 2: Add
  late FriendModel _selectedFriend;

  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  static const List<FriendModel> _friends = [
    FriendModel(
      id: 'f1',
      name: 'Elena Vance',
      title: 'Grand Sorceress',
      level: 18,
      xp: 14200,
      avatarInitial: 'E',
      avatarColor: Color(0xFFDEB7FF),
      district: 'Math Tower',
      isOnline: true,
      lastActive: 'Active Now',
      streakDays: 14,
      guildName: 'Order of Arcanists',
      subjectProgress: {'Math': 0.95, 'Physics': 0.70, 'History': 0.85},
    ),
    FriendModel(
      id: 'f2',
      name: 'Marcus Sol',
      title: 'Quantum Explorer',
      level: 16,
      xp: 11850,
      avatarInitial: 'M',
      avatarColor: Color(0xFF60A5FA),
      district: 'Physics Lab',
      isOnline: true,
      lastActive: 'Active Now',
      streakDays: 21,
      guildName: 'Order of Arcanists',
      subjectProgress: {'Math': 0.60, 'Physics': 0.98, 'CS': 0.80},
    ),
    FriendModel(
      id: 'f3',
      name: 'Lyra Moon',
      title: 'Royal Archivist',
      level: 15,
      xp: 9900,
      avatarInitial: 'L',
      avatarColor: Color(0xFFF2CA50),
      district: 'Royal Archives',
      isOnline: false,
      lastActive: '2h ago',
      streakDays: 7,
      guildName: 'Library Scholars',
      subjectProgress: {'History': 0.99, 'Literature': 0.90, 'Math': 0.40},
    ),
    FriendModel(
      id: 'f4',
      name: 'Kaelen Drake',
      title: 'Code Weaver',
      level: 13,
      xp: 7600,
      avatarInitial: 'K',
      avatarColor: Color(0xFF82C0A0),
      district: 'CS Citadel',
      isOnline: false,
      lastActive: '1d ago',
      streakDays: 5,
      guildName: 'Order of Arcanists',
      subjectProgress: {'CS': 0.92, 'Math': 0.75, 'Physics': 0.50},
    ),
  ];

  static const List<GuildMemberModel> _guildMembers = [
    GuildMemberModel(
        name: 'Alex Rover (You)',
        role: 'Guild Master',
        level: 14,
        weeklyXp: 2450,
        isOnline: true),
    GuildMemberModel(
        name: 'Elena Vance',
        role: 'Officer',
        level: 18,
        weeklyXp: 3100,
        isOnline: true),
    GuildMemberModel(
        name: 'Marcus Sol',
        role: 'Officer',
        level: 16,
        weeklyXp: 2800,
        isOnline: true),
    GuildMemberModel(
        name: 'Kaelen Drake',
        role: 'Member',
        level: 13,
        weeklyXp: 1950,
        isOnline: false),
  ];

  final List<GuildChatMessage> _chatMessages = [
    const GuildChatMessage(
        sender: 'Elena Vance',
        role: 'Officer',
        text: 'Ready for tonight\'s Weekly Guild Raid?',
        time: '18:42'),
    const GuildChatMessage(
        sender: 'Marcus Sol',
        role: 'Officer',
        text: 'Just finished Physics trial 4. Got extra energy potion!',
        time: '18:45'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFriend = _friends[0];
  }

  @override
  void dispose() {
    _chatController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _sendGift(FriendModel friend) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFF82C0A0)),
            const SizedBox(width: 8),
            Text(
              'SENT +5 ENERGY TO ${friend.name.toUpperCase()}!',
              style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _challengeFriend(FriendModel friend) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Color(0xFFF2CA50), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.sports_esports_rounded, color: Color(0xFFF2CA50)),
            const SizedBox(width: 10),
            Text(
              'QUIZ DUEL',
              style: GoogleFonts.pressStart2p(
                fontSize: 11,
                color: const Color(0xFFF2CA50),
              ),
            ),
          ],
        ),
        content: Text(
          'Challenge ${friend.name} to a speed quiz duel in ${friend.district}?\n\nENTRY STAKE: 50 COINS 🪙',
          style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFD0C5AF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2CA50),
              foregroundColor: Colors.black,
              shape: const RoundedRectangleBorder(),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'DUEL CHALLENGE SENT TO ${friend.name.toUpperCase()}!',
                    style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF1E1E32),
                ),
              );
            },
            child: Text(
              'SEND DUEL',
              style: GoogleFonts.pressStart2p(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            _buildTopHeaderBar(context),

            // Main Dual-Pane Viewport
            Expanded(
              child: Row(
                children: [
                  // 1. Left Side Navigation Rail
                  _buildNavRail(),

                  // Vertical Gold Pixel Separator
                  Container(width: 2, color: const Color(0xFFF2CA50)),

                  // 2. Center-Left Master Panel (280px width)
                  SizedBox(
                    width: 280,
                    child: _buildMasterPanel(),
                  ),

                  // Vertical Pixel Separator
                  Container(width: 2, color: const Color(0xFF4D4635)),

                  // 3. Right Detail Inspector Showcase (Remaining space)
                  Expanded(
                    child: _buildDetailInspectorPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                const Icon(Icons.groups_rounded,
                    color: Color(0xFFF2CA50), size: 18),
                const SizedBox(width: 8),
                Text(
                  'SOCIAL & GUILD HALL',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ],
            ),
          ),

          // 16-Bit Online Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: const Color(0xFF82C0A0), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF82C0A0),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '3 ONLINE',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 7,
                    color: const Color(0xFF82C0A0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. LEFT NAVIGATION RAIL ────────────────────────────────────────────────
  Widget _buildNavRail() {
    final navItems = [
      {'label': 'FRIENDS', 'icon': Icons.people_alt_rounded},
      {'label': 'GUILD', 'icon': Icons.shield_rounded},
      {'label': 'ADD', 'icon': Icons.person_add_alt_1_rounded},
    ];

    return Container(
      width: 115,
      color: const Color(0xFF141424),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(navItems.length, (idx) {
          final isSelected = _activeRailIndex == idx;
          final item = navItems[idx];
          return GestureDetector(
            onTap: () => setState(() => _activeRailIndex = idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF28283D) : const Color(0xFF1B1B2C),
                border: Border.all(
                  color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF3C382A),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected
                        ? const Color(0xFFF2CA50)
                        : const Color(0xFF8C867A),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7.5,
                      color: isSelected
                          ? const Color(0xFFF2CA50)
                          : const Color(0xFF8C867A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── 2. CENTER-LEFT MASTER PANEL ───────────────────────────────────────────
  Widget _buildMasterPanel() {
    return Container(
      color: const Color(0xFF18182B),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activeRailIndex == 0
                ? 'EXPLORERS LIST'
                : _activeRailIndex == 1
                    ? 'GUILD ROSTER'
                    : 'ADD FRIENDS',
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: const Color(0xFFF2CA50),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: _activeRailIndex == 2
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E32),
                          border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SEARCH EXPLORER',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 7,
                                color: const Color(0xFFF2CA50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _searchController,
                              style: GoogleFonts.pressStart2p(
                                  color: Colors.white, fontSize: 8),
                              decoration: InputDecoration(
                                hintText: 'TAG #KV-8924...',
                                hintStyle: GoogleFonts.pressStart2p(
                                    color: Colors.white38, fontSize: 7),
                                filled: true,
                                fillColor: const Color(0xFF141424),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(0),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4D4635)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _activeRailIndex == 0
                        ? _friends.length
                        : _guildMembers.length,
                    itemBuilder: (ctx, i) {
                      if (_activeRailIndex == 0) {
                        final friend = _friends[i];
                        final isSelected = friend.id == _selectedFriend.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFriend = friend),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF28283D)
                                  : const Color(0xFF1E1E32),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFF2CA50)
                                    : const Color(0xFF4D4635),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? const [
                                      BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(2, 2),
                                          blurRadius: 0),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF28283D),
                                    border: Border.all(color: friend.avatarColor),
                                  ),
                                  child: Center(
                                    child: Text(
                                      friend.avatarInitial,
                                      style: GoogleFonts.pressStart2p(
                                          fontSize: 10, color: friend.avatarColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 8,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        friend.district,
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 6.5,
                                          color: const Color(0xFFD0C5AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final m = _guildMembers[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E32),
                            border: Border.all(color: const Color(0xFF4D4635)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                m.name,
                                style: GoogleFonts.pressStart2p(
                                    fontSize: 7.5, color: Colors.white),
                              ),
                              Text(
                                m.role,
                                style: GoogleFonts.pressStart2p(
                                    fontSize: 6.5, color: const Color(0xFFF2CA50)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── 3. RIGHT DETAIL INSPECTOR SHOWCASE ──────────────────────────────────────
  Widget _buildDetailInspectorPanel() {
    if (_activeRailIndex == 0) {
      // FRIEND INSPECTOR HOLOGRAPHIC CARD
      return Container(
        color: const Color(0xFF0F0F1A),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Top Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32),
                  border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF28283D),
                        border: Border.all(color: _selectedFriend.avatarColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _selectedFriend.avatarInitial,
                          style: GoogleFonts.pressStart2p(
                              fontSize: 18, color: _selectedFriend.avatarColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFriend.name,
                            style: GoogleFonts.pressStart2p(
                              fontSize: 10,
                              color: const Color(0xFFF2CA50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedFriend.title} • LVL ${_selectedFriend.level}',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7.5,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'GUILD: ${_selectedFriend.guildName.toUpperCase()}',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: const Color(0xFFDEB7FF),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Column(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2CA50),
                            foregroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.sports_esports_rounded,
                              color: Colors.black, size: 14),
                          label: Text(
                            'DUEL',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 7, color: Colors.black),
                          ),
                          onPressed: () => _challengeFriend(_selectedFriend),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF82C0A0),
                            foregroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.bolt_rounded,
                              color: Colors.black, size: 14),
                          label: Text(
                            'GIFT',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 7, color: Colors.black),
                          ),
                          onPressed: () => _sendGift(_selectedFriend),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subject Mastery Cards with Stepped Bars
              Text(
                'SUBJECT MASTERY & PROGRESS',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: const Color(0xFFF2CA50),
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: _selectedFriend.subjectProgress.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E32),
                      border: Border.all(color: const Color(0xFF4D4635)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key.toUpperCase(),
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 8, color: Colors.white),
                            ),
                            Text(
                              '${(e.value * 100).toInt()}%',
                              style: GoogleFonts.pressStart2p(
                                  fontSize: 7.5,
                                  color: const Color(0xFF82C0A0)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // 16-Bit Stepped Progress Channel
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF141424),
                            border: Border.all(
                                color: const Color(0xFF4D4635), width: 1),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: e.value,
                            child: Container(
                              color: const Color(0xFF82C0A0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    } else if (_activeRailIndex == 1) {
      // GUILD CHAT & QUEST SHOWCASE
      return Container(
        color: const Color(0xFF0F0F1A),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GUILD HALL CHAT',
              style: GoogleFonts.pressStart2p(
                fontSize: 8.5,
                color: const Color(0xFFF2CA50),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32),
                  border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
                ),
                child: ListView.builder(
                  itemCount: _chatMessages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _chatMessages[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '[${msg.time}] ${msg.sender}: ${msg.text}',
                        style: GoogleFonts.pressStart2p(
                            fontSize: 7.5, color: const Color(0xFFD0C5AF)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: GoogleFonts.pressStart2p(
                        color: Colors.white, fontSize: 8),
                    decoration: InputDecoration(
                      hintText: 'POST TO GUILD CHAT...',
                      hintStyle: GoogleFonts.pressStart2p(
                          color: Colors.white38, fontSize: 7),
                      filled: true,
                      fillColor: const Color(0xFF141424),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: const BorderSide(color: Color(0xFF4D4635)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2CA50),
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onPressed: () {
                    if (_chatController.text.trim().isNotEmpty) {
                      setState(() {
                        _chatMessages.add(
                          GuildChatMessage(
                            sender: 'Alex Rover',
                            role: 'Guild Master',
                            text: _chatController.text.trim(),
                            time: 'Now',
                          ),
                        );
                        _chatController.clear();
                      });
                    }
                  },
                  child: Text(
                    'SEND',
                    style: GoogleFonts.pressStart2p(
                        fontSize: 8, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // ADD FRIENDS PENDING REQUESTS
      return Container(
        color: const Color(0xFF0F0F1A),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PENDING FRIEND REQUESTS (1)',
              style: GoogleFonts.pressStart2p(
                fontSize: 8.5,
                color: const Color(0xFFF2CA50),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32),
                border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    color: const Color(0xFFDEB7FF),
                    child: Center(
                      child: Text('V',
                          style: GoogleFonts.pressStart2p(
                              fontSize: 12, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VESPER NINE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 8.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wants to join your circle',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: const Color(0xFFD0C5AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF82C0A0),
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'ACCEPTED VESPER NINE AS FRIEND!',
                            style: GoogleFonts.pressStart2p(fontSize: 8),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'ACCEPT',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 7.5, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
