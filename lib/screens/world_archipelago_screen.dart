import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/player_profile.dart';
import '../services/theme_music_service.dart';
import 'subject_loading_screen.dart';

/// Data model representing an interactive academy island in the archipelago.
class SubjectIslandData {
  final String id;
  final String name;
  final String academyTitle;
  final String subject;
  final IconData icon;
  final Color themeColor;
  final Color textColor;
  final Offset relativeOffset; // Coordinates on map canvas (0.0 to 1.0)
  final String description;
  final List<String> highlights;
  final String localAssetPath;
  final String fallbackAssetUrl;

  const SubjectIslandData({
    required this.id,
    required this.name,
    required this.academyTitle,
    required this.subject,
    required this.icon,
    required this.themeColor,
    required this.textColor,
    required this.relativeOffset,
    required this.description,
    required this.highlights,
    required this.localAssetPath,
    required this.fallbackAssetUrl,
  });
}

/// Grayscale Color Filter matrix for desaturating locked islands (cross-platform reliable)
const ColorFilter _grayscaleMatrix = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0,      0,      0,      1, 0,
]);

/// "Knowledgeverse Archipelago - Map" screen from Stitch.
/// Guarantees background, islands, connection bridges, lock badges, and top/bottom app bars render 100% reliably.
class WorldArchipelagoScreen extends StatefulWidget {
  const WorldArchipelagoScreen({super.key, this.profile});

  final PlayerProfile? profile;

  static const List<SubjectIslandData> islands = [
    // 1. Mathematics (top centre)
    SubjectIslandData(
      id: 'math',
      name: 'Mathematics',
      academyTitle: 'Math House Sanctuary',
      subject: 'Mathematics',
      icon: Icons.calculate_rounded,
      themeColor: Color(0xFFF2CA50),
      textColor: Color(0xFF3C2F00),
      relativeOffset: Offset(0.50, 0.17),
      description:
          'Conquer algebra, calculus, geometry, and numerical logic puzzles.',
      highlights: ['Calculus & Vectors', 'Geometry', 'Number Theory'],
      localAssetPath: 'assets/images/island_math.png',
      fallbackAssetUrl: 'game-assets/buildings/grand_hall_2x.png',
    ),
    // 2. Physics & Space (upper right)
    SubjectIslandData(
      id: 'astronomy',
      name: 'Physics & Space',
      academyTitle: 'Astronomy Tower',
      subject: 'Physics',
      icon: Icons.star_rounded,
      themeColor: Color(0xFF89DCEB),
      textColor: Color(0xFF00515A),
      relativeOffset: Offset(0.80, 0.32),
      description:
          'Explore astrophysics, mechanics, gravity, space science, and kinetic simulations.',
      highlights: ['Orbital Mechanics', 'Quantum Theory', 'Optics'],
      localAssetPath: 'assets/images/island_physics.png',
      fallbackAssetUrl: 'game-assets/buildings/astronomy_tower_2x.png',
    ),
    // 3. History & Civics (lower right)
    SubjectIslandData(
      id: 'history',
      name: 'History & Civics',
      academyTitle: 'Royal Archives Hall',
      subject: 'History',
      icon: Icons.castle_rounded,
      themeColor: Color(0xFFFFD167),
      textColor: Color(0xFF765900),
      relativeOffset: Offset(0.80, 0.65),
      description:
          'Uncover the history of computing, ancient civilizations, and societal evolution.',
      highlights: ['Ancient History', 'History of Computing', 'Civic Design'],
      localAssetPath: 'assets/images/island_history.png',
      fallbackAssetUrl: 'game-assets/buildings/history_hall_2x.png',
    ),
    // 4. Biology & Life (bottom centre)
    SubjectIslandData(
      id: 'biology',
      name: 'Biology & Life',
      academyTitle: 'Bio Conservatory',
      subject: 'Biology',
      icon: Icons.eco_rounded,
      themeColor: Color(0xFF94E2D5),
      textColor: Color(0xFF00515A),
      relativeOffset: Offset(0.50, 0.80),
      description:
          'Discover cellular genetics, ecosystem balance, and organic biological structures.',
      highlights: ['Cellular Biology', 'Genetics', 'Ecology'],
      localAssetPath: 'assets/images/island_biology.png',
      fallbackAssetUrl: 'game-assets/buildings/library_2x.png',
    ),
    // 5. Chemistry (lower left)
    SubjectIslandData(
      id: 'chemistry',
      name: 'Chemistry',
      academyTitle: 'Potion & Alchemy Lab',
      subject: 'Chemistry',
      icon: Icons.science_rounded,
      themeColor: Color(0xFFA6E3A1),
      textColor: Color(0xFF1B6D22),
      relativeOffset: Offset(0.20, 0.65),
      description:
          'Conduct chemical reaction simulations, potion brewing, and periodic table experiments.',
      highlights: ['Potion Brewing', 'Organic Reactions', 'Atomic Structure'],
      localAssetPath: 'assets/images/island_chemistry.png',
      fallbackAssetUrl: 'game-assets/buildings/alchemy_lab_2x.png',
    ),
    // 6. Computer Science (upper left)
    SubjectIslandData(
      id: 'cs',
      name: 'Computer Science',
      academyTitle: 'Coding Tower Academy',
      subject: 'Programming',
      icon: Icons.computer_rounded,
      themeColor: Color(0xFF89B4FA),
      textColor: Color(0xFF181825),
      relativeOffset: Offset(0.20, 0.32),
      description:
          'Master programming logic, Dart syntax, algorithms, and software architecture.',
      highlights: ['Dart & Flutter', 'Algorithms', 'Data Structures'],
      localAssetPath: 'assets/images/island_cs.png',
      fallbackAssetUrl: 'game-assets/buildings/coding_tower_2x.png',
    ),
    // 7. PvP Duel Arena (central hub)
    SubjectIslandData(
      id: 'arena',
      name: 'PvP Duel Arena',
      academyTitle: 'Challengers Arena',
      subject: 'PvP Battles',
      icon: Icons.sports_mma_rounded,
      themeColor: Color(0xFFFAB387),
      textColor: Color(0xFF765900),
      relativeOffset: Offset(0.50, 0.48),
      description:
          'Test your coding speed and problem-solving skills in real-time timed duels.',
      highlights: ['Timed Quizzes', 'Live Duels', 'Global Leaderboard'],
      localAssetPath: 'assets/images/island_pvp.png',
      fallbackAssetUrl: 'game-assets/buildings/duel_arena_2x.png',
    ),
  ];

  @override
  State<WorldArchipelagoScreen> createState() => _WorldArchipelagoScreenState();
}

class _WorldArchipelagoScreenState extends State<WorldArchipelagoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Set<String> _unlockedSubjects = {
    'Mathematics',
  };

  @override
  void initState() {
    super.initState();
    ThemeMusicService.instance.stop();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _syncProfile();
  }

  void _syncProfile() async {
    final p = widget.profile ?? PlayerProfile.current ?? await PlayerProfile.load();
    if (p != null) {
      PlayerProfile.current = p;
      if (p.subjects.isNotEmpty && mounted) {
        setState(() {
          for (final s in p.subjects) {
            _unlockedSubjects.add(s);
          }
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/map_bg.png'), context).catchError((_) {});
  }

  @override
  void dispose() {
    _animController.dispose();
    if (ThemeMusicService.musicEnabled) {
      ThemeMusicService.instance.start();
    }
    super.dispose();
  }

  void _onIslandTap(SubjectIslandData island) {
    if (island.id == 'arena') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PvP Arena matchmaking is opening soon! Complete lessons to train.',
            style: GoogleFonts.jetBrainsMono(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6B13AF),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final isUnlocked = _unlockedSubjects.contains(island.name) ||
        _unlockedSubjects.contains(island.subject);

    if (!isUnlocked) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SubjectLoadingScreen(island: island),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600 || size.height < 700;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF111125),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Rich Gothic Night Background Wallpaper (with fail-safe gradient)
            Positioned.fill(
              child: Image.asset(
                'assets/images/map_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/loading_bg.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.2,
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF111125),
                              Color(0xFF0C0C1F),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 2. Subtle Dark Shading Overlay
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.20)),
            ),

            // 3. Connection Lines & Interactive Islands Layout (Shifted UP by 21px)
            Positioned.fill(
              child: Transform.translate(
                offset: const Offset(0, -21),
                child: Stack(
                  children: [
                    // Connection Lines (Radial dashed bridges radiating from Hub to islands)
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: _ConnectionLinesPainter(
                            islands: WorldArchipelagoScreen.islands,
                            pulse: _animController.value,
                          ),
                        );
                      },
                    ),

                    // Interactive Islands Layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final mapWidth = constraints.maxWidth;
                        final mapHeight = constraints.maxHeight;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: WorldArchipelagoScreen.islands.map((island) {
                            final isHub = island.id == 'arena';
                            final isUnlocked =
                                _unlockedSubjects.contains(island.name) ||
                                    _unlockedSubjects.contains(island.subject);

                            final dx = island.relativeOffset.dx * mapWidth;
                            final dy = island.relativeOffset.dy * mapHeight;

                            final nodeWidth = isMobile
                                ? (isHub ? 110.0 : 88.0)
                                : (isHub ? 150.0 : 120.0);

                            return Positioned(
                              left: dx - (nodeWidth / 2),
                              top: dy - (nodeWidth / 2),
                              child: _IslandNodeWidget(
                                island: island,
                                isHub: isHub,
                                isUnlocked: isUnlocked,
                                width: nodeWidth,
                                pulse: _animController,
                                onTap: () => _onIslandTap(island),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 5. Ornate Frame with Corner Gems
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  margin: EdgeInsets.all(isMobile ? 8 : 16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF2CA50),
                      width: isMobile ? 3 : 4,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          top: isMobile ? -4 : -6,
                          left: isMobile ? -4 : -6,
                          child: _CornerGem(isMobile: isMobile)),
                      Positioned(
                          top: isMobile ? -4 : -6,
                          right: isMobile ? -4 : -6,
                          child: _CornerGem(isMobile: isMobile)),
                      Positioned(
                          bottom: isMobile ? -4 : -6,
                          left: isMobile ? -4 : -6,
                          child: _CornerGem(isMobile: isMobile)),
                      Positioned(
                          bottom: isMobile ? -4 : -6,
                          right: isMobile ? -4 : -6,
                          child: _CornerGem(isMobile: isMobile)),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Top App Bar
            Positioned(
              top: isMobile ? 14 : 28,
              left: isMobile ? 14 : 28,
              right: isMobile ? 14 : 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title Header Block
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 18,
                          vertical: isMobile ? 6 : 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF333348),
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFF4D4635), width: 4),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore,
                              color: const Color(0xFFF2CA50),
                              size: isMobile ? 18 : 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isMobile
                                  ? 'ARCHIPELAGO'
                                  : 'KNOWLEDGEVERSE ARCHIPELAGO',
                              style: GoogleFonts.spaceMono(
                                fontSize: isMobile ? 12 : 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF2CA50),
                                letterSpacing: 1.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Unlocked Stats Block
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 16,
                        vertical: isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28283D),
                      border: Border.all(
                          color: const Color(0xFFF2CA50),
                          width: isMobile ? 1.5 : 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star,
                            color: const Color(0xFFF2CA50),
                            size: isMobile ? 14 : 18),
                        const SizedBox(width: 6),
                        Text(
                          '${_unlockedSubjects.length} / 8 Islands Unlocked',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: isMobile ? 11 : 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF2CA50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}

/// Renders an individual island node with fallback chain
class _IslandNodeWidget extends StatefulWidget {
  final SubjectIslandData island;
  final bool isHub;
  final bool isUnlocked;
  final double width;
  final AnimationController pulse;
  final VoidCallback onTap;

  const _IslandNodeWidget({
    required this.island,
    required this.isHub,
    required this.isUnlocked,
    required this.width,
    required this.pulse,
    required this.onTap,
  });

  @override
  State<_IslandNodeWidget> createState() => _IslandNodeWidgetState();
}

class _IslandNodeWidgetState extends State<_IslandNodeWidget> {
  bool _isHovered = false;

  Widget _buildRawImage() {
    return Image.asset(
      widget.island.localAssetPath,
      width: widget.width,
      height: widget.width,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          widget.island.fallbackAssetUrl,
          width: widget.width,
          height: widget.width,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            widget.island.icon,
            size: widget.width * 0.5,
            color: widget.island.themeColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageContent = _buildRawImage();

    // Desaturate locked islands with ColorFilter.matrix (reliable desaturation)
    if (!widget.isUnlocked && !widget.isHub) {
      imageContent = ColorFiltered(
        colorFilter: _grayscaleMatrix,
        child: Opacity(
          opacity: 0.75,
          child: imageContent,
        ),
      );
    }

    // Central hub glow & pulse animation
    if (widget.isHub) {
      imageContent = AnimatedBuilder(
        animation: widget.pulse,
        builder: (context, child) {
          final scale = 1.0 + 0.04 * math.sin(widget.pulse.value * math.pi * 2);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF2CA50).withValues(alpha: 0.40),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
          child: imageContent,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(
              0, _isHovered ? -8.0 : 0.0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                clipBehavior: Clip.none,
                children: [
                  imageContent,
                  if (!widget.isUnlocked && !widget.isHub)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111125),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Color(0xFFF2CA50),
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Pixel Label Banner matching Stitch island-label-banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111125),
                  border: Border.all(
                    color: widget.isHub
                        ? const Color(0xFFF97316)
                        : (widget.isUnlocked
                            ? const Color(0xFFF2CA50)
                            : const Color(0xFF4D4635)),
                    width: widget.isHub ? 3.0 : 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.island.name,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: widget.width < 100 ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: widget.isHub
                            ? Colors.white
                            : (widget.isUnlocked
                                ? const Color(0xFFF2CA50)
                                : const Color(0xFFD0C5AF)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isHub
                            ? const Color(0xFFEA580C).withValues(alpha: 0.3)
                            : (widget.isUnlocked
                                ? const Color(0xFFF2CA50).withValues(alpha: 0.2)
                                : const Color(0xFF333348)),
                        border: widget.isHub
                            ? Border.all(
                                color: const Color(0xFFF97316).withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        widget.isHub
                            ? 'PVP BATTLES'
                            : (widget.isUnlocked ? 'ACADEMY' : 'LOCKED'),
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: widget.isHub
                              ? const Color(0xFFFED7AA)
                              : (widget.isUnlocked
                                  ? const Color(0xFFF2CA50)
                                  : const Color(0xFF99907C)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for dashed radial connection lines from Central Hub to all islands
class _ConnectionLinesPainter extends CustomPainter {
  final List<SubjectIslandData> islands;
  final double pulse;

  _ConnectionLinesPainter({required this.islands, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final hub = islands.firstWhere((i) => i.id == 'arena',
        orElse: () => islands.first);
    final hubPos = Offset(
      size.width * hub.relativeOffset.dx,
      size.height * hub.relativeOffset.dy,
    );

    final paint = Paint()
      ..color = const Color(0xFFF2CA50)
          .withValues(alpha: 0.35 + 0.15 * math.sin(pulse * math.pi * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    const dashWidth = 8.0;
    const dashSpace = 8.0;

    for (final island in islands) {
      if (island.id == 'arena') continue;
      final targetPos = Offset(
        size.width * island.relativeOffset.dx,
        size.height * island.relativeOffset.dy,
      );

      _drawDashedLine(canvas, hubPos, targetPos, paint, dashWidth, dashSpace);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint,
      double dashWidth, double dashSpace) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist == 0) return;
    final unitX = dx / dist;
    final unitY = dy / dist;

    double currentDist = 0.0;
    while (currentDist < dist) {
      final start = Offset(
          p1.dx + unitX * currentDist, p1.dy + unitY * currentDist);
      final endDist = math.min(currentDist + dashWidth, dist);
      final end =
          Offset(p1.dx + unitX * endDist, p1.dy + unitY * endDist);
      canvas.drawLine(start, end, paint);
      currentDist += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinesPainter old) =>
      old.pulse != pulse;
}

class _CornerGem extends StatelessWidget {
  final bool isMobile;
  const _CornerGem({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 8.0 : 12.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF6B13AF),
        border: Border.all(color: Colors.black, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(-2, -2),
          ),
        ],
      ),
    );
  }
}
