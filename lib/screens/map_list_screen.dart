import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_music_service.dart';
import 'subject_dashboard_screen.dart';
import 'world_archipelago_screen.dart';

/// "High Fidelity - World Map List" screen from Stitch.
/// Serves as the list-based navigation view for the Knowledgeverse Archipelago,
/// featuring ornate 16-bit RPG styling, double-gold pixel borders, jeweled corner accents,
/// 16-bit island thumbnails (with grayscale filters for locked islands), filter tabs,
/// and emerald action buttons.
class MapListScreen extends StatefulWidget {
  const MapListScreen({super.key});

  @override
  State<MapListScreen> createState() => _MapListScreenState();
}

class _MapListScreenState extends State<MapListScreen> {
  Set<String> _unlockedSubjects = {'Mathematics'};
  String _selectedFilter = 'ALL'; // ALL, UNLOCKED, LOCKED

  @override
  void initState() {
    super.initState();
    if (ThemeMusicService.musicEnabled) {
      ThemeMusicService.instance.start();
    }
    _loadUnlockedSubjects();
  }

  Future<void> _loadUnlockedSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selectedSubjects') ?? ['Mathematics'];
    setState(() {
      _unlockedSubjects = saved.toSet();
    });
  }

  Future<void> _unlockSubject(SubjectIslandData island) async {
    setState(() {
      _unlockedSubjects.add(island.subject);
      _unlockedSubjects.add(island.name);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedSubjects', _unlockedSubjects.toList());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${island.name} has been unlocked!',
          style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleIslandTap(SubjectIslandData island, bool isUnlocked) {
    if (island.id == 'arena') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PvP Arena duels opening soon! Train in your academies.',
            style: GoogleFonts.jetBrainsMono(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6B13AF),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isUnlocked) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectDashboardScreen(
            subjectName: island.name,
            themeColor: island.themeColor,
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => _buildUnlockDialog(island),
      );
    }
  }

  Widget _buildUnlockDialog(SubjectIslandData island) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E32),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFF2CA50), width: 3),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_open_rounded,
                color: Color(0xFFF2CA50), size: 40),
            const SizedBox(height: 12),
            Text(
              'UNLOCK ${island.name.toUpperCase()}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFFF2CA50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              island.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: const Color(0xFFD0C5AF),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28283D),
                      border: Border.all(
                          color: const Color(0xFF4D4635), width: 1.5),
                    ),
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _unlockSubject(island);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF065F46),
                      border: Border.all(
                          color: const Color(0xFFF2CA50), width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Text(
                      'UNLOCK 🚀',
                      style: GoogleFonts.pressStart2p(
                          fontSize: 9, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final islands = WorldArchipelagoScreen.islands;

    final filteredIslands = islands.where((island) {
      final isUnlocked = _unlockedSubjects.contains(island.name) ||
          _unlockedSubjects.contains(island.subject);
      if (_selectedFilter == 'UNLOCKED') return isUnlocked;
      if (_selectedFilter == 'LOCKED') return !isUnlocked;
      return true;
    }).toList();

    final unlockedCount = islands.where((i) {
      return _unlockedSubjects.contains(i.name) ||
          _unlockedSubjects.contains(i.subject);
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFF111125),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gothic Wallpaper Layer
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

          // Scanlines Shader Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x1F000000)],
                    stops: [0.5, 0.5],
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                _buildHeader(context, unlockedCount, islands.length),

                // Filter Tabs Bar
                _buildFilterBar(),

                // Scrollable Island List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: filteredIslands.length,
                    itemBuilder: (context, index) {
                      final island = filteredIslands[index];
                      final isUnlocked =
                          _unlockedSubjects.contains(island.name) ||
                              _unlockedSubjects.contains(island.subject);

                      return _IslandListItemCard(
                        island: island,
                        isUnlocked: isUnlocked,
                        onTap: () => _handleIslandTap(island, isUnlocked),
                      );
                    },
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
  Widget _buildHeader(
      BuildContext context, int unlockedCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _OrnatePixelBox(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFF2CA50),
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Header Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WORLD MAP LIST',
                  style: GoogleFonts.spaceMono(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFFF2CA50),
                    letterSpacing: 2.0,
                    shadows: const [
                      Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
                    ],
                  ),
                ),
                Text(
                  'KNOWLEDGEVERSE ARCHIPELAGO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: const Color(0xFFD0C5AF),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // Unlocked Counter Pill
          _OrnatePixelBox(
            backgroundColor: const Color(0xFF28283D),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFF2CA50), size: 14),
                const SizedBox(width: 4),
                Text(
                  '$unlockedCount / $totalCount UNLOCKED',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTER BAR BUILDER ─────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    final filters = ['ALL', 'UNLOCKED', 'LOCKED'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF1E1E32),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF4D4635),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x664ADE80),
                            blurRadius: 6,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  f,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: isSelected
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFD0C5AF),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── ISLAND LIST ITEM CARD ────────────────────────────────────────────────────
class _IslandListItemCard extends StatelessWidget {
  final SubjectIslandData island;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _IslandListItemCard({
    required this.island,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHub = island.id == 'arena';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32).withValues(alpha: 0.9),
                border: Border.all(
                  color: isHub
                      ? const Color(0xFFFAB387)
                      : isUnlocked
                          ? const Color(0xFFF2CA50)
                          : const Color(0xFF4D4635),
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Island 16-bit Thumbnail Container
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111125),
                      border: Border.all(
                        color: isUnlocked
                            ? island.themeColor
                            : const Color(0xFF4D4635),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Island Graphic Asset
                        ColorFiltered(
                          colorFilter: isUnlocked
                              ? const ColorFilter.mode(
                                  Colors.transparent, BlendMode.dst)
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0, 0, 0, 0.5, 0,
                                ]),
                          child: Image.asset(
                            island.localAssetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                island.icon,
                                size: 36,
                                color: isUnlocked
                                    ? island.themeColor
                                    : const Color(0xFF4D4635),
                              ),
                            ),
                          ),
                        ),

                        // Lock Overlay Icon if Locked
                        if (!isUnlocked)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Color(0xFFF2CA50),
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Middle Content Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          island.academyTitle.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isUnlocked
                                ? const Color(0xFFF2CA50)
                                : const Color(0xFFD0C5AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              island.subject.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                color: island.themeColor,
                              ),
                            ),
                            if (isHub) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                color: const Color(0xFF6B13AF),
                                child: Text(
                                  'PVP BATTLES',
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 6,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          island.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: const Color(0xFFD0C5AF).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Action Button / Status Badge
                  if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        border: Border.all(
                            color: const Color(0xFFF2CA50), width: 2),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black, offset: Offset(2, 2)),
                        ],
                      ),
                      child: Text(
                        'ENTER →',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28283D),
                        border: Border.all(
                            color: const Color(0xFF4D4635), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              color: Color(0xFFD0C5AF), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'LOCKED',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 8,
                              color: const Color(0xFFD0C5AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 4 Corner Purple Jeweled Accents
            const _CornerGem(top: -4, left: -4),
            const _CornerGem(top: -4, right: -4),
            const _CornerGem(bottom: -4, left: -4),
            const _CornerGem(bottom: -4, right: -4),
          ],
        ),
      ),
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

// ── CORNER GEM WIDGET ────────────────────────────────────────────────────────
class _CornerGem extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _CornerGem({
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF6B13AF),
          border: Border.all(
            color: const Color(0xFFF2CA50),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
