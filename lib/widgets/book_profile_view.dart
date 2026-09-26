import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/asset_paths.dart';
import '../models/player_profile.dart';

/// Authentic RPG Animated Book Profile View matching the exact 3D physics:
/// 1. Book is sized to a single page and centered on the wooden desk mat.
/// 2. Starts closed and automatically animates open upon mounting.
/// 3. Front cover rotates 0° -> 180° around the left spine hinge with 3D perspective.
/// 4. As it flips past 90°, it transitions seamlessly to the inside left page.
/// 5. Smoothly shifts by half its page width so the open 2-page spread remains centered.
/// 6. Dynamic spine shadows sweep across both pages during opening and closing.
/// 7. Automatically reverses the animation smoothly on close before popping the screen.
class BookProfileView extends StatefulWidget {
  final PlayerProfile? profile;
  final VoidCallback? onClose;

  const BookProfileView({
    super.key,
    this.profile,
    this.onClose,
  });

  @override
  State<BookProfileView> createState() => _BookProfileViewState();
}

class _BookProfileViewState extends State<BookProfileView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const double pageWidth = 347.0;
  static const double pageHeight = 445.0;
  static const double containerWidth = 694.0;
  static const double containerHeight = 445.0;
  static const double bookTop = 0.0;
  static const double bookLeft = (containerWidth - pageWidth) / 2;

  String? _selectedEquipmentName;
  String? _selectedEquipmentDesc;

  void _ensureAnimationsInitialized() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 950),
      reverseDuration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _ensureAnimationsInitialized();
    // Automatically trigger the opening animation
    _controller.forward();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Safety for Flutter Hot Reload
    if (!_controller.isAnimating && !_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() {
    if (_controller.isAnimating) return;
    _controller.reverse().then((_) {
      if (mounted) {
        if (widget.onClose != null) {
          widget.onClose!();
        } else {
          Navigator.of(context).maybePop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile ??
        PlayerProfile.notifier.value ??
        PlayerProfile.current ??
        const PlayerProfile();

    final playerName =
        profile.name.isNotEmpty ? profile.name.toUpperCase() : 'DDADDA';
    final gradeText =
        profile.grade.isNotEmpty ? profile.grade.toUpperCase() : 'CLASS 10';
    final level = profile.level > 0 ? profile.level : 1;
    final coins = profile.coins > 0 ? profile.coins : 500;
    final focusMins = profile.focusXp > 0 ? profile.focusXp : 150;
    final avatarIndex = profile.avatarIndex;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Dynamic Drop Shadow beneath the book (expands dynamically as book unfolds)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  final curVal = _animation.value;
                  final double shadowW = pageWidth + curVal * pageWidth;
                  final double shadowX = bookLeft - curVal * (pageWidth / 2);

                  return Positioned(
                    left: shadowX + 12,
                    top: bookTop + 14,
                    width: shadowW - 24,
                    height: pageHeight - 18,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.55),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 2. Centered Animated Book (Single-page container translated to center 2-page spread)
              Positioned(
                left: bookLeft,
                top: bookTop,
                width: pageWidth,
                height: pageHeight,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    // Smoothly shift book by half its page width so the
                    // open 2-page spread remains centered on screen
                    return Transform.translate(
                      offset: Offset(_animation.value * (pageWidth / 2), 0),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: pageWidth,
                    height: pageHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // A. Base right page (inside reading page + world map)
                        _buildRightPage(
                          profile: profile,
                          level: level,
                        ),

                        // B. Dynamic spine shadow cast onto the right page while opening
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final shadowOpacity =
                                (math.sin(_animation.value * math.pi) * 0.35);
                            return Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 32,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black
                                          .withValues(alpha: shadowOpacity),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // C. Front Cover (hinged on the left spine, swinging toward the user)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            // Angle sweeps 0 to 180 degrees (math.pi)
                            final angle = _animation.value * math.pi;
                            final isBackFacing = _animation.value >= 0.5;

                            return Transform(
                              alignment: Alignment.centerLeft,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0012) // 3D perspective
                                ..rotateY(angle),
                              child: isBackFacing
                                  ? Transform(
                                      // Flip horizontally so inside text reads left-to-right
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(math.pi),
                                      child: _buildInsideLeftPage(
                                        playerName: playerName,
                                        gradeText: gradeText,
                                        level: level,
                                        coins: coins,
                                        focusMins: focusMins,
                                        avatarIndex: avatarIndex,
                                      ),
                                    )
                                  : _buildFrontCover(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Interactive Tooltip Pop-up for Equipment Slots
              if (_selectedEquipmentName != null)
                Positioned(
                  bottom: 8,
                  left: (containerWidth - 380) / 2,
                  width: 380,
                  child: _buildEquipmentTooltip(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Front Cover (Closed Leather Tome) ────────────────────────────────────
  Widget _buildFrontCover() {
    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/paper_ui/book_cover_closed.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _buildCornerCloseButton(),
          ),
        ],
      ),
    );
  }

  // ─── Inside Left Page: Profile, Avatar, Equipment, Clock ──────────────────
  Widget _buildInsideLeftPage({
    required String playerName,
    required String gradeText,
    required int level,
    required int coins,
    required int focusMins,
    required int avatarIndex,
  }) {
    final avatarPath = AssetPaths.getAvatarPortrait(avatarIndex);

    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Left Page Parchment Background with Leather Trim
          Image.asset(
            'assets/paper_ui/book_page_left.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),

          // Dynamic spine shadow along the inner right fold
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final shadowOpacity =
                  (math.sin(_animation.value * math.pi) * 0.30);
              return Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 25,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.black.withValues(alpha: shadowOpacity),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Page Content
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 26, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Page Title: "Profile" in Authentic Green Gothic Calligraphy
                Text(
                  'Profile',
                  style: GoogleFonts.medievalSharp(
                    color: const Color(0xFF2E7D5B),
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Player Name in Pixel Art font with green decorative wave
                Text(
                  playerName,
                  style: GoogleFonts.pressStart2p(
                    color: const Color(0xFF2E7D5B),
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '~  ~  ~',
                  style: GoogleFonts.pressStart2p(
                    color: const Color(0xFF388E6B),
                    fontSize: 7.0,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Avatar Frame encircled by colorful heart gems (matching reference)
                SizedBox(
                  width: 112,
                  height: 112,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Concentric green decorative rings
                      Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF388E6B)
                                .withValues(alpha: 0.45),
                            width: 1.0,
                          ),
                        ),
                      ),
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                const Color(0xFF2E7D5B).withValues(alpha: 0.7),
                            width: 1.2,
                          ),
                        ),
                      ),

                      // 12 Colorful Pixel Hearts around the perimeter
                      ...List.generate(12, (i) {
                        final double heartAngle = (i * 30.0) * math.pi / 180.0;
                        const double heartRadius = 48.0;
                        final double hx = heartRadius * math.cos(heartAngle);
                        final double hy = heartRadius * math.sin(heartAngle);

                        final List<Color> heartColors = [
                          const Color(0xFFE65100),
                          const Color(0xFFD32F2F),
                          const Color(0xFFFBC02D),
                          const Color(0xFF388E3C),
                          const Color(0xFF0097A7),
                          const Color(0xFFE91E63),
                        ];
                        final Color heartColor =
                            heartColors[i % heartColors.length];

                        return Transform.translate(
                          offset: Offset(hx, hy),
                          child: Icon(
                            Icons.favorite,
                            size: 10.0,
                            color: heartColor,
                          ),
                        );
                      }),

                      // Character Avatar Portrait in circular center
                      ClipOval(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            avatarPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Level Stud at the bottom center of the frame
                      Positioned(
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3C74C),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: const Color(0xFF2E7D5B), width: 1.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            'LV $level',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2A1C0E),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Subtitle: Year and Class
                Text(
                  'YEAR : $level  •  $gradeText',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFF5A4126),
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),

                const SizedBox(height: 8),

                // ─── EQUIPMENT SECTION ──────────────────────────────────────
                _buildSectionHeader('EQUIPMENT'),
                const SizedBox(height: 6),

                // 6 Circular Equipment Slots flanked by « and »
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '«',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10.5,
                        color: const Color(0xFF2E7D5B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    _buildCircularEquipmentSlot(
                      iconPath: 'assets/paper_ui/equipment/1.png',
                      name: 'Scholar Crown',
                      desc: '+15 Arcane Focus & Quiz Shield',
                      isSelected: _selectedEquipmentName == 'Scholar Crown',
                    ),
                    _buildCircularEquipmentSlot(
                      iconPath: 'assets/paper_ui/equipment/2.png',
                      name: 'Mystic Tunic',
                      desc: '+20% Fatigue Resistance',
                      isSelected: _selectedEquipmentName == 'Mystic Tunic',
                    ),
                    _buildCircularEquipmentSlot(
                      iconPath: 'assets/paper_ui/equipment/3.png',
                      name: 'Gauntlets of Grit',
                      desc: '+35 Attack in PVP Arena Duels',
                      isSelected: _selectedEquipmentName == 'Gauntlets of Grit',
                    ),
                    _buildCircularEquipmentSlot(
                      iconPath: 'assets/paper_ui/equipment/5.png',
                      name: 'Guardian Buckler',
                      desc: 'Protects streak from quiz error',
                      isSelected: _selectedEquipmentName == 'Guardian Buckler',
                    ),
                    _buildCircularEquipmentSlot(
                      iconPath: 'assets/paper_ui/equipment/7.png',
                      name: 'Swift Greaves',
                      desc: '+25% Overworld exploration speed',
                      isSelected: _selectedEquipmentName == 'Swift Greaves',
                    ),
                    _buildCircularEquipmentSlot(
                      iconPath: 'assets/paper_ui/equipment/8.png',
                      name: 'Sigil Ring',
                      desc: 'Doubles coin drops from Math Island',
                      isSelected: _selectedEquipmentName == 'Sigil Ring',
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '»',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10.5,
                        color: const Color(0xFF2E7D5B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ─── CLOCK / DAY & NIGHT WIDGET ─────────────────────────────
                _buildSectionHeader('CLOCK'),
                const SizedBox(height: 6),

                // 3-Column Clock Widget matching reference image
                SizedBox(
                  width: 284,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column: Time, Sunday, Money
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFF2E7D5B), width: 1.0),
                              ),
                            ),
                            child: Text(
                              '02:14:55',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8.2,
                                color: const Color(0xFF2E7D5B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            'SUNDAY',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7.5,
                              color: const Color(0xFF2E7D5B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on,
                                  size: 15, color: Color(0xFFD69417)),
                              const SizedBox(width: 2),
                              Text(
                                '$coins G',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 8.2,
                                  color: const Color(0xFF2E7D5B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Center Column: Circular Day & Night Dial
                      SizedBox(
                        width: 68,
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 4,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(26),
                                ),
                                child: Image.asset(
                                  'assets/paper_ui/day_night/half/day/1.png',
                                  width: 55,
                                  height: 34,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/paper_ui/day_night/1.png',
                              width: 68,
                              height: 48,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                            ),
                          ],
                        ),
                      ),

                      // Right Column: Year, Weather, Star EXP
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Color(0xFF2E7D5B), width: 1.0),
                              ),
                            ),
                            child: Text(
                              'YEAR : $level',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 8.2,
                                color: const Color(0xFF2E7D5B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Text(
                            'SUNNY DAY',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7.5,
                              color: const Color(0xFF2E7D5B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3.5),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 15, color: Color(0xFF1976D2)),
                              const SizedBox(width: 2),
                              Text(
                                'EXP $focusMins',
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 8.2,
                                  color: const Color(0xFF2E7D5B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Base Right Page: Real Player Profile Data (Academy Record) ───────────
  Widget _buildRightPage({
    required PlayerProfile profile,
    required int level,
  }) {
    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Right Page Parchment Background with Leather Trim
          Image.asset(
            'assets/paper_ui/book_page_right.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),

          // Content of Right Page
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 26, 15),
            child: _buildRightTabContent(profile: profile, level: level),
          ),

          // Cross / Close button in the top-right corner of the book
          Positioned(
            top: 8,
            right: 8,
            child: _buildCornerCloseButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightTabContent({
    required PlayerProfile profile,
    required int level,
  }) {
    final streak = profile.streakDays > 0 ? profile.streakDays : 1;
    final focus = profile.focusXp > 0 ? profile.focusXp : 150;
    final solved = profile.weeklyQuestions > 0 ? profile.weeklyQuestions : 12;
    final gems = profile.gems > 0 ? profile.gems : 25;
    final energy = profile.energy > 0 ? profile.energy : 100;
    final curriculum =
        profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE';
    final grade =
        profile.grade.isNotEmpty ? profile.grade.toUpperCase() : 'CLASS 10';
    final difficulty = profile.difficulty.isNotEmpty
        ? profile.difficulty.toUpperCase()
        : 'ADVENTURER';
    final totalXp = profile.xp > 0 ? profile.xp : 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Page Title: "Academy Record" in Authentic Green Gothic Calligraphy
        Text(
          'Academy Record',
          style: GoogleFonts.medievalSharp(
            color: const Color(0xFF2E7D5B),
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 1),

        // Subtitle: "~ LEARNER DOSSIER ~"
        Text(
          '~ LEARNER DOSSIER ~',
          style: GoogleFonts.pressStart2p(
            color: const Color(0xFF388E6B),
            fontSize: 7.8,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 5),

        // 2. Top 3 Vitality Stat Cards (Streak, Focus, Solved)
        Row(
          children: [
            Expanded(
              child: _buildVitalityMiniCard(
                icon: Icons.local_fire_department_rounded,
                iconColor: const Color(0xFFE65100),
                label: 'STREAK',
                value: '$streak D',
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildVitalityMiniCard(
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFF57F17),
                label: 'FOCUS',
                value: '$focus XP',
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _buildVitalityMiniCard(
                icon: Icons.task_alt_rounded,
                iconColor: const Color(0xFF2E7D32),
                label: 'SOLVED',
                value: '$solved Q',
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // 3. Section Header: "~ SUBJECT MASTERY ~"
        _buildSectionHeader('SUBJECT MASTERY'),
        const SizedBox(height: 4),

        // 4. Four Academy Subject Cards with Live Progression & Required XP
        _buildSubjectMasteryCard(
          title: 'Math House',
          subject: 'Mathematics',
          level: 4,
          progress: 0.70,
          color: const Color(0xFF2E7D32),
          icon: Icons.calculate_rounded,
        ),
        const SizedBox(height: 3.5),
        _buildSubjectMasteryCard(
          title: 'Science Lab',
          subject: 'Physics',
          level: 3,
          progress: 0.45,
          color: const Color(0xFF00838F),
          icon: Icons.science_rounded,
        ),
        const SizedBox(height: 3.5),
        _buildSubjectMasteryCard(
          title: 'Royal Archives',
          subject: 'History',
          level: 5,
          progress: 1.0,
          color: const Color(0xFFC48A00),
          icon: Icons.castle_rounded,
        ),
        const SizedBox(height: 3.5),
        _buildSubjectMasteryCard(
          title: 'Library Tower',
          subject: 'Literature',
          level: 2,
          progress: 0.30,
          color: const Color(0xFFB71C1C),
          icon: Icons.menu_book_rounded,
        ),

        const SizedBox(height: 5),

        // 5. Bottom Academic Dossier Card (Curriculum, Grade, Difficulty, XP)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE2D6BE).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF2E7D5B), width: 1.2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$curriculum • $grade',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7.2,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E5E41),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0E6DB),
                      borderRadius: BorderRadius.circular(3),
                      border:
                          Border.all(color: const Color(0xFF2E7D5B), width: 0.8),
                    ),
                    child: Text(
                      difficulty,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.2,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E5E41),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF57F17)),
                      const SizedBox(width: 2),
                      Text(
                        'TOTAL: $totalXp XP',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2A1A0A),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond_rounded,
                          size: 12, color: Color(0xFF00ACC1)),
                      const SizedBox(width: 2),
                      Text(
                        '$gems',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2A1A0A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.bolt_rounded,
                          size: 12, color: Color(0xFF43A047)),
                      const SizedBox(width: 1),
                      Text(
                        '$energy%',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2A1A0A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalityMiniCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2D6BE).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2E7D5B), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    fontSize: 8.8,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5A4126),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.pressStart2p(
              fontSize: 7.2,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E5E41),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectMasteryCard({
    required String title,
    required String subject,
    required int level,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    final currentXp = (progress * 1000).toInt();
    const requiredXp = 1000;
    final neededXp = (requiredXp - currentXp).clamp(0, requiredXp);
    final isMax = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFE2D6BE).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2E7D5B), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon, Title, Subject, Level Badge
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2A1A0A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '($subject)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cinzel(
                          fontSize: 8.5,
                          color: const Color(0xFF5A4126),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: color, width: 0.8),
                ),
                child: Text(
                  'LV $level',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6.8,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.5),

          // Row 2: Progress & Requirement to complete level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentXp / $requiredXp XP',
                style: GoogleFonts.pressStart2p(
                  fontSize: 6.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF38230F),
                ),
              ),
              Text(
                isMax ? '★ MASTERED' : '$neededXp XP TO LV ${level + 1}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 6.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.5),

          // Row 3: Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.5,
              backgroundColor: const Color(0xFFC7B394),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Circular Equipment Slot ──────────────────────────────────────────────
  Widget _buildCircularEquipmentSlot({
    required String iconPath,
    required String name,
    required String desc,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedEquipmentName == name) {
            _selectedEquipmentName = null;
            _selectedEquipmentDesc = null;
          } else {
            _selectedEquipmentName = name;
            _selectedEquipmentDesc = desc;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFFFFE898)
              : const Color(0xFFD2ECE1).withValues(alpha: 0.75),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD32F2F)
                : const Color(0xFF2E7D5B),
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SelectionBracketPainter(),
                ),
              ),
            Image.asset(
              iconPath,
              width: 21,
              height: 21,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ],
        ),
      ),
    );
  }



  // ─── Section Header Line ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '~',
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: const Color(0xFF2E7D5B),
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            title,
            style: GoogleFonts.pressStart2p(
              color: const Color(0xFF2E7D5B),
              fontSize: 7.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Text(
          '~',
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: const Color(0xFF2E7D5B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─── Equipment Tooltip Popup ──────────────────────────────────────────────
  Widget _buildEquipmentTooltip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF55B868), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Color(0xFF55B868), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedEquipmentName ?? '',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF55B868),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _selectedEquipmentDesc ?? '',
                  style: GoogleFonts.cinzel(
                    fontSize: 9.5,
                    color: const Color(0xFFE5D5BA),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _selectedEquipmentName = null;
              _selectedEquipmentDesc = null;
            }),
            child: const Icon(Icons.close, color: Colors.white70, size: 16),
          ),
        ],
      ),
    );
  }

  // ─── Corner Close Button [X] ───────────────────────────────────────────────
  Widget _buildCornerCloseButton() {
    return Semantics(
      button: true,
      label: 'Close Book',
      child: Tooltip(
        message: 'Close',
        child: GestureDetector(
          key: const Key('book_corner_close_button'),
          onTap: _handleClose,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE0C8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E7D5B), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFF2E7D5B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ─── Custom Painter for Active Equipment Red Corner Brackets ────────────────
class _SelectionBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const d = 5.0;
    canvas.drawLine(const Offset(2, 2 + d), const Offset(2, 2), paint);
    canvas.drawLine(const Offset(2, 2), const Offset(2 + d, 2), paint);

    canvas.drawLine(
        Offset(size.width - 2 - d, 2), Offset(size.width - 2, 2), paint);
    canvas.drawLine(
        Offset(size.width - 2, 2), Offset(size.width - 2, 2 + d), paint);

    canvas.drawLine(
        Offset(2, size.height - 2 - d), Offset(2, size.height - 2), paint);
    canvas.drawLine(
        Offset(2, size.height - 2), Offset(2 + d, size.height - 2), paint);

    canvas.drawLine(Offset(size.width - 2 - d, size.height - 2),
        Offset(size.width - 2, size.height - 2), paint);
    canvas.drawLine(Offset(size.width - 2, size.height - 2 - d),
        Offset(size.width - 2, size.height - 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
