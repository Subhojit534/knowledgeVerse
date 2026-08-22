import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_profile.dart';
import '../services/api_service.dart';
import 'settings_screen.dart';

class SubjectDistrict {
  final String name;
  final String subject;
  final double progress;
  final int level;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color imageBgColor;

  const SubjectDistrict({
    required this.name,
    required this.subject,
    required this.progress,
    required this.level,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.imageBgColor,
  });
}

/// "Knowledgeverse Profile Page - Expanded Layout" with Authentic 16-Bit Pixel Art Theme.
/// Connected with real-time level progression, daily streak, live focus XP, diamonds/gems,
/// energy capacity, and weekly activity tracker.
class ProfileScreen extends StatefulWidget {
  final PlayerProfile? profile;
  const ProfileScreen({super.key, this.profile});

  static const List<SubjectDistrict> subjects = [
    SubjectDistrict(
      name: 'Royal Archives',
      subject: 'History',
      progress: 1.0,
      level: 5,
      icon: Icons.castle_rounded,
      color: Color(0xFFFFD167),
      textColor: Color(0xFF765900),
      imageBgColor: Color(0xFFffedb3),
    ),
    SubjectDistrict(
      name: 'Math House',
      subject: 'Mathematics',
      progress: 0.7,
      level: 4,
      icon: Icons.calculate_rounded,
      color: Color(0xFF7acb74),
      textColor: Color(0xFF005611),
      imageBgColor: Color(0xFFd4f0d4),
    ),
    SubjectDistrict(
      name: 'Science Lab',
      subject: 'Physics',
      progress: 0.45,
      level: 3,
      icon: Icons.science_rounded,
      color: Color(0xFF44c9da),
      textColor: Color(0xFF00515a),
      imageBgColor: Color(0xFFcbf5fb),
    ),
    SubjectDistrict(
      name: 'Library Tower',
      subject: 'Literature',
      progress: 0.3,
      level: 2,
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF28B82),
      textColor: Color(0xFF93000a),
      imageBgColor: Color(0xFFfde8e8),
    ),
  ];

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PlayerProfile _profile = const PlayerProfile();
  String _playerName = 'EXPLORER';
  String _playerTitle = 'Civilization Architect';
  int _xp = 150;
  int _level = 1;
  int _focusXp = 150;
  int _coins = 500;
  int _gems = 25;
  int _energy = 100;
  int _streakDays = 1;
  int _weeklyQuestions = 12;

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
    PlayerProfile.notifier.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    PlayerProfile.notifier.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final active = PlayerProfile.notifier.value;
    if (active != null && mounted) {
      setState(() {
        _profile = active;
        if (active.name.isNotEmpty) {
          _playerName = active.name.toUpperCase();
        }
        if (active.learningGoal.isNotEmpty) {
          _playerTitle = active.learningGoal;
        }
        _xp = active.xp;
        _level = active.level;
        _focusXp = active.focusXp;
        _coins = active.coins;
        _gems = active.gems;
        _energy = active.energy;
        _streakDays = active.streakDays;
        _weeklyQuestions = active.weeklyQuestions;
      });
    }
  }

  Future<void> _loadSavedProfile() async {
    final active = widget.profile ?? PlayerProfile.current ?? await PlayerProfile.load();
    String? localName = active?.name.trim();

    if (localName == null || localName.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      localName = prefs.getString('player_name')?.trim();
    }

    if (active != null && mounted) {
      setState(() {
        _profile = active;
        _playerName = active.name.isNotEmpty ? active.name.toUpperCase() : (localName?.toUpperCase() ?? 'EXPLORER');
        if (active.learningGoal.isNotEmpty) {
          _playerTitle = active.learningGoal;
        }
        _xp = active.xp;
        _level = active.level;
        _focusXp = active.focusXp;
        _coins = active.coins;
        _gems = active.gems;
        _energy = active.energy;
        _streakDays = active.streakDays;
        _weeklyQuestions = active.weeklyQuestions;
      });
    }

    try {
      final targetUserId = (active != null && active.id.isNotEmpty)
          ? active.id
          : (localName != null && localName.isNotEmpty)
              ? localName
              : '';
      final endpoint = targetUserId.isNotEmpty
          ? '/api/profile/me?userId=$targetUserId'
          : '/api/profile/me';

      final res = await ApiService.get(endpoint);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final p = data['profile'] as Map<String, dynamic>?;
        if (p != null && mounted) {
          final serverName = (p['name'] as String?)?.trim();
          final serverXp = p['xp'] as int? ?? _xp;
          final serverCoins = p['coins'] as int? ?? _coins;
          final serverLevel = p['level'] as int? ?? PlayerProfile.computeLevel(serverXp);

          setState(() {
            if (serverName != null && serverName.isNotEmpty) {
              _playerName = serverName.toUpperCase();
            }
            if ((p['learning_goal'] as String?)?.isNotEmpty == true) {
              _playerTitle = p['learning_goal'] as String;
            }
            _xp = serverXp;
            _level = serverLevel;
            _coins = serverCoins;
            _profile = _profile.copyWith(
              xp: _xp,
              level: _level,
              coins: _coins,
            );
          });

          await _profile.save();
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111125),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dark Gothic Castle Background Overlay
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/loading_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [Color(0xFF1E1E32), Color(0xFF0C0C1F)],
                  ),
                ),
              ),
            ),
          ),

          // 2. Pixelated Scanlines Shader Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x1F000000),
                    ],
                    stops: [0.5, 0.5],
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
          ),

          // 3. Main Responsive Scroll Content Layer
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar (Back button + Pixel Currency Stat Badges + Settings)
                _buildHeader(context),

                // Scrollable Dashboard Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 768 &&
                                size.height >= 400;

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Profile & Bottom-Left Stats Panel (flex 44)
                                  Expanded(
                                    flex: 44,
                                    child: _buildLeftProfileSection()
                                        .animate()
                                        .fadeIn(duration: 400.ms)
                                        .slideX(begin: -0.05),
                                  ),
                                  const SizedBox(width: 16),

                                  // Right Weekly Vitality Section (flex 56)
                                  Expanded(
                                    flex: 56,
                                    child: _buildRightVitalitySection()
                                        .animate()
                                        .fadeIn(
                                            duration: 400.ms, delay: 150.ms),
                                  ),
                                ],
                              );
                            } else {
                              // Stack vertically for compact mobile screens
                              return Column(
                                children: [
                                  _buildLeftProfileSection()
                                      .animate()
                                      .fadeIn(duration: 300.ms),
                                  const SizedBox(height: 16),
                                  _buildRightVitalitySection()
                                      .animate()
                                      .fadeIn(duration: 300.ms, delay: 100.ms),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER BAR BUILDER ─────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Arrow Button
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: _OrnatePixelBox(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFF2CA50),
                size: 18,
              ),
            ),
          ),

          // Currency & Stat Badges Row
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatBadge(
                    icon: Icons.monetization_on_rounded,
                    iconColor: const Color(0xFFF2CA50),
                    label: '$_coins',
                    textColor: const Color(0xFFF2CA50),
                  ),
                  const SizedBox(width: 6),
                  _StatBadge(
                    icon: Icons.diamond_rounded,
                    iconColor: const Color(0xFFDEB7FF),
                    label: '$_gems',
                    textColor: const Color(0xFFDEB7FF),
                  ),
                  const SizedBox(width: 6),
                  _StatBadge(
                    icon: Icons.bolt_rounded,
                    iconColor: const Color(0xFF9DDCBB),
                    label: '$_energy/100',
                    textColor: const Color(0xFF9DDCBB),
                  ),
                  const SizedBox(width: 6),
                  _StatBadge(
                    icon: Icons.layers_rounded,
                    iconColor: const Color(0xFF60A5FA),
                    label: '$_focusXp XP',
                    textColor: const Color(0xFF60A5FA),
                  ),
                  const SizedBox(width: 6),
                  // Settings Button opens SettingsScreen!
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    child: _OrnatePixelBox(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: Color(0xFFD0C5AF),
                        size: 18,
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

  // ── UNIFIED LEFT PROFILE & STATS PANEL ─────────────────────────────────────
  Widget _buildLeftProfileSection() {
    final double levelProgress = _profile.levelProgressRatio;
    final int currentLvlXp = _profile.currentLevelXp;
    final int progressPercent = (levelProgress * 100).toInt();

    return _OrnateFrameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar & Level Header Row
          Row(
            children: [
              // 16-Bit Pixel Avatar Frame
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF28283D),
                  border: Border.all(
                    color: const Color(0xFFF2CA50),
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF3C2F00),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.face_retouching_natural_rounded,
                    color: Color(0xFFF2CA50),
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Level Badge & Stepped XP Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0C1F),
                        border: Border.all(
                          color: const Color(0xFFF2CA50),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'LVL $_level',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12,
                          color: const Color(0xFFF2CA50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Stepped 16-bit XP Bar
                    _buildPixelProgressBar(ratio: levelProgress),

                    const SizedBox(height: 6),
                    Text(
                      '$currentLvlXp / ${_profile.nextLevelXpRequired} XP (Total: $_xp)',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: const Color(0xFFD0C5AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color(0xFF4D4635), height: 1),
          const SizedBox(height: 12),

          // Player Name & Title
          Text(
            _playerName,
            style: GoogleFonts.pressStart2p(
              fontSize: 13,
              color: const Color(0xFFF2CA50),
              shadows: const [
                Shadow(
                  color: Color(0xFF3C2F00),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _playerTitle.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: const Color(0xFFD0C5AF),
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // XP Progress Label & Stepped Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP PROGRESS',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: const Color(0xFFF2CA50),
                ),
              ),
              Text(
                '$progressPercent%',
                style: GoogleFonts.pressStart2p(
                  fontSize: 8,
                  color: const Color(0xFF82C0A0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPixelProgressBar(ratio: levelProgress),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF4D4635), height: 1),
          const SizedBox(height: 14),

          // ── MERGED STATS ROW (Streak, Focus XP, Diamond) ─────────────────
          Row(
            children: [
              // 1. Day Streak Card
              Expanded(
                child: _buildEmbeddedStatBlock(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFF2CA50),
                  value: '$_streakDays D',
                  valueColor: const Color(0xFFF2CA50),
                  label: 'STREAK',
                ),
              ),
              const SizedBox(width: 8),

              // 2. Focus XP Card
              Expanded(
                child: _buildEmbeddedStatBlock(
                  icon: Icons.layers_rounded,
                  iconColor: const Color(0xFF60A5FA),
                  value: '$_focusXp',
                  valueColor: const Color(0xFF60A5FA),
                  label: 'FOCUS XP',
                ),
              ),
              const SizedBox(width: 8),

              // 3. Diamond / Gems Card
              Expanded(
                child: _buildEmbeddedStatBlock(
                  icon: Icons.diamond_rounded,
                  iconColor: const Color(0xFFDEB7FF),
                  value: '$_gems',
                  valueColor: const Color(0xFFDEB7FF),
                  label: 'DIAMOND',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedStatBlock({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C1F),
        border: Border.all(color: const Color(0xFF333348), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.pressStart2p(
                fontSize: 12,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: const Color(0xFFD0C5AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RIGHT VITALITY SECTION ─────────────────────────────────────────────────
  Widget _buildRightVitalitySection() {
    final now = DateTime.now();
    final int currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final double baseRatio = (_weeklyQuestions / 20.0).clamp(0.2, 1.0);

    return _OrnateFrameCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Blooming Badge Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'WEEKLY VITALITY',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 11,
                    color: const Color(0xFFF2CA50),
                    shadows: const [
                      Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Blooming Badge
              _OrnatePixelBox(
                backgroundColor: const Color(0xFF28283D),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_weeklyQuestions QUESTS',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: const Color(0xFF9DDCBB),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.filter_vintage_rounded,
                      color: Color(0xFF9DDCBB),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bar Chart Area with Stepped 16-Bit Pixel Vitality Columns
          SizedBox(
            height: 260,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _VitalityBarColumn(day: 'M', fillRatio: currentWeekday >= 1 ? (baseRatio * 0.8).clamp(0.1, 1.0) : 0.15, icon: Icons.local_florist_rounded, isActive: currentWeekday == 1, isFuture: currentWeekday < 1),
                _VitalityBarColumn(day: 'T', fillRatio: currentWeekday >= 2 ? (baseRatio * 0.9).clamp(0.1, 1.0) : 0.15, icon: Icons.local_florist_rounded, isActive: currentWeekday == 2, isFuture: currentWeekday < 2),
                _VitalityBarColumn(day: 'W', fillRatio: currentWeekday >= 3 ? (baseRatio * 0.7).clamp(0.1, 1.0) : 0.15, icon: Icons.local_florist_rounded, isActive: currentWeekday == 3, isFuture: currentWeekday < 3),
                _VitalityBarColumn(day: 'T', fillRatio: currentWeekday >= 4 ? baseRatio : 0.15, icon: Icons.filter_vintage_rounded, isActive: currentWeekday == 4, isFuture: currentWeekday < 4),
                _VitalityBarColumn(day: 'F', fillRatio: currentWeekday >= 5 ? (baseRatio * 0.85).clamp(0.1, 1.0) : 0.15, icon: Icons.local_florist_rounded, isActive: currentWeekday == 5, isFuture: currentWeekday < 5),
                _VitalityBarColumn(day: 'S', fillRatio: currentWeekday >= 6 ? (baseRatio * 0.6).clamp(0.1, 1.0) : 0.15, icon: Icons.local_florist_rounded, isActive: currentWeekday == 6, isFuture: currentWeekday < 6),
                _VitalityBarColumn(day: 'S', fillRatio: currentWeekday >= 7 ? (baseRatio * 0.75).clamp(0.1, 1.0) : 0.15, icon: Icons.local_florist_rounded, isActive: currentWeekday == 7, isFuture: currentWeekday < 7),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to construct 16-bit stepped pixel progress bar
  Widget _buildPixelProgressBar({required double ratio}) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: Border.all(color: const Color(0xFF333348), width: 2),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF82C0A0),
                    Color(0xFF0B4F36),
                  ],
                ),
              ),
            ),
          ),

          // Pixel segment lines overlay
          Row(
            children: List.generate(
              10,
              (index) => Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.black.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── VITALITY BAR COLUMN WIDGET ───────────────────────────────────────────────
class _VitalityBarColumn extends StatelessWidget {
  final String day;
  final double fillRatio;
  final IconData icon;
  final bool isActive;
  final bool isFuture;

  const _VitalityBarColumn({
    required this.day,
    required this.fillRatio,
    required this.icon,
    this.isActive = false,
    this.isFuture = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isFuture ? 0.35 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: isActive ? 1.1 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              icon,
              size: isActive ? 20 : 16,
              color: isActive ? const Color(0xFFF2CA50) : const Color(0xFF82C0A0),
            ),
            const SizedBox(height: 6),
            Container(
              width: 24,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFF2CA50)
                      : const Color(0xFF333348),
                  width: isActive ? 2.5 : 1.5,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: fillRatio.clamp(0.05, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFF2CA50)
                          : const Color(0xFF82C0A0),
                      boxShadow: isActive
                          ? const [
                              BoxShadow(
                                color: Color(0xFFF2CA50),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: isActive
                    ? const Color(0xFFF2CA50)
                    : const Color(0xFFE2E0FC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ORNATE PIXEL FRAME CARD ──────────────────────────────────────────────────
class _OrnateFrameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _OrnateFrameCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E32).withValues(alpha: 0.9),
            border: Border.all(color: const Color(0xFFF2CA50), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF735C00),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
        // 4 Corner Ornate Pixel Squares
        Positioned(
          top: -4,
          left: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF2CA50),
              border: Border.all(color: const Color(0xFF3C2F00), width: 1.5),
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF2CA50),
              border: Border.all(color: const Color(0xFF3C2F00), width: 1.5),
            ),
          ),
        ),
        Positioned(
          bottom: -4,
          left: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF2CA50),
              border: Border.all(color: const Color(0xFF3C2F00), width: 1.5),
            ),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF2CA50),
              border: Border.all(color: const Color(0xFF3C2F00), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── ORNATE PIXEL BOX ─────────────────────────────────────────────────────────
class _OrnatePixelBox extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const _OrnatePixelBox({
    required this.child,
    this.backgroundColor = const Color(0xFF1E1E32),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: const Color(0xFFF2CA50), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── STAT BADGE ───────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color textColor;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return _OrnatePixelBox(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 8,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
