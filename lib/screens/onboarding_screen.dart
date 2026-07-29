import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import 'world_generation_screen.dart';

const int _kStepCount = 4;

/// "High Fidelity Onboarding Flow" matching exact Stitch screens:
/// 1. "High Fidelity - Name Entry"
/// 2. "High Fidelity - Class Selection"
/// 3. "High Fidelity - District Selection"
/// 4. "High Fidelity - Difficulty Selection"
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();
  final Set<int> _selectedDistrictIndices = {0};
  String _grade = 'Class 10';
  String _curriculum = 'CBSE';
  String _difficulty = 'Balanced';

  static const List<String> _grades = [
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
  ];

  static const List<String> _curriculums = [
    'CBSE',
    'ICSE',
    'IB',
    'Cambridge',
    'State Board',
  ];

  static const List<Map<String, String>> _difficulties = [
    {
      'label': 'Gentle',
      'desc': 'Steady pace, extra guidance for the wary scholar.',
      'icon': '🌿',
    },
    {
      'label': 'Balanced',
      'desc': 'A fair climb with real challenge for ambitious minds.',
      'icon': '⚖️',
    },
    {
      'label': 'Challenging',
      'desc': 'Steep and fast, reserved for the truly legendary.',
      'icon': '⚔️',
    },
  ];

  static const List<_AcademyDistrict> _districts = [
    _AcademyDistrict(
      title: 'Math House',
      subject: 'MATHEMATICS',
      icon: Icons.calculate_rounded,
      color: Color(0xFF7ACB74),
      desc: 'Algebra, Geometry & Calculus.',
    ),
    _AcademyDistrict(
      title: 'Royal Archives',
      subject: 'HISTORY',
      icon: Icons.castle_rounded,
      color: Color(0xFFFFD167),
      desc: 'Ancient History & World Lore.',
    ),
    _AcademyDistrict(
      title: 'Science Lab',
      subject: 'PHYSICS',
      icon: Icons.science_rounded,
      color: Color(0xFF44C9DA),
      desc: 'Motion, Energy & Universe.',
    ),
    _AcademyDistrict(
      title: 'Library Tower',
      subject: 'LITERATURE',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF28B82),
      desc: 'Mastery of Prose & Epics.',
    ),
  ];

  PlayerProfile _buildProfile() {
    final name = _nameController.text.trim();
    return PlayerProfile(
      name: name.isEmpty ? 'Explorer' : name,
      grade: _grade,
      curriculum: _curriculum,
      subjects: _selectedDistrictIndices
          .map((i) => _districts[i].subject)
          .toList(),
      difficulty: _difficulty,
      worldTheme: 'Green Highlands',
      learningGoal: 'Master all academic domains',
      avatarIndex: 0,
    );
  }

  Future<void> _nextStep() async {
    if (_currentStep < _kStepCount - 1) {
      FocusScope.of(context).unfocus();
      setState(() => _currentStep++);
      return;
    }

    final profile = _buildProfile();
    await profile.save();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WorldGenerationScreen(profile: profile),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF050510),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image Layer
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
                    colors: [Color(0xFF1E1E32), Color(0xFF050510)],
                  ),
                ),
              ),
            ),
          ),

          // Scanlines Effect Overlay
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

          // Inner Screen Frame Border Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFF2CA50).withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Main Layout Area
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: SizedBox(
                      height: 400,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Column: Character HUD Panel (flex 35) - 400px EXACT HEIGHT!
                          Expanded(
                            flex: 35,
                            child: _buildCharacterHudPanel(),
                          ),
                          const SizedBox(width: 16),

                          // Right Column: Hero Form Panel (flex 65) - 400px EXACT HEIGHT!
                          Expanded(
                            flex: 65,
                            child: _buildHeroModalFormPanel(),
                          ),
                        ],
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

  // ── LEFT SIDEBAR: CHARACTER HUD PANEL ──────────────────────────────────────
  Widget _buildCharacterHudPanel() {
    final nameText = _nameController.text.trim();
    final displayName = nameText.isEmpty ? 'UNKNOWN TRAVELER' : nameText;

    return _OrnateJeweledBox(
      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.92),
      borderColor: const Color(0xFFD4AF37),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              border: Border.all(
                color: const Color(0xFFF2CA50).withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('★',
                    style: TextStyle(color: Color(0xFFFDE047), fontSize: 12)),
                const SizedBox(width: 6),
                Text(
                  'EXPLORER HUD',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Character Avatar with Pulsing Gold Border
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF2CA50), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFF2CA50),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAuhfOB_Q4eTYAsRfzItcrBsL_J_1-f37AAIuQTWlE0s36L3gtEY8UyJnHrwqaTxbztUilJWQxtnA_qP_GxLbek2DRr8SZZXIz8pH4KBPYVs9_KGHLWWJEed9-LGoYcRp-ZXme2Zkwc4J48YNKxr1TrE2VjIGvutIZrG75o9bagvHadwGSmSr6jAfqvWktwBlwTB4fikah8YEDgYs-usCQ5SSkd_9srBEibaCtmxeWwyeoUvPVipjBjUuby4QzDU58T_saUQta36Cs',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Explorer Name & Level Subtitle
          Text(
            displayName.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFFF2CA50),
              letterSpacing: 1.2,
              shadows: const [
                Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level 1 Civilization Architect',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w400,
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 16),

          // Live Selection Summary Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E32),
              border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  '$_grade • $_curriculum',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Difficulty: $_difficulty',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: const Color(0xFF9DDCBB),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Journey Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(
                color: const Color(0xFFF2CA50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your journey begins here.',
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
    );
  }

  // ── RIGHT MAIN CONTENT: HERO MODAL FORM PANEL ─────────────────────────────
  Widget _buildHeroModalFormPanel() {
    return _OrnateJeweledBox(
      backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
      borderColor: const Color(0xFFD4AF37),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step Progress Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '❖ STEP ${_currentStep + 1} OF $_kStepCount ❖',
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: const Color(0xFFF2CA50),
                  letterSpacing: 1.5,
                ),
              ),

              // 4 Rotatable Diamond Progress Pips
              Row(
                children: List.generate(_kStepCount, (index) {
                  final isActive = index <= _currentStep;
                  return Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: index == _currentStep ? 12 : 8,
                    height: index == _currentStep ? 12 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF1E1E32),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFF2CA50)
                            : const Color(0xFF4D4635),
                      ),
                      boxShadow: isActive
                          ? const [
                              BoxShadow(
                                color: Color(0xFF4ADE80),
                                blurRadius: 6,
                              )
                            ]
                          : null,
                    ),
                    transform: Matrix4.rotationZ(0.785398), // Diamond shape
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Active Step Dynamic Content View (Fills 400px Details Filling Box)
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: _buildCurrentStepView(),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Bottom Action Navigation Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _currentStep--);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E32),
                      border: Border.all(
                          color: const Color(0xFFF2CA50), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_rounded,
                            color: Color(0xFFD0C5AF), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'BACK',
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: const Color(0xFFD0C5AF),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),

              // Glowing Emerald Continue Button
              GestureDetector(
                onTap: _nextStep,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46),
                    border:
                        Border.all(color: const Color(0xFFF2CA50), width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentStep == _kStepCount - 1
                            ? 'GENERATE MY WORLD 🚀'
                            : 'CONTINUE',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFF2CA50),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── SWITCHER FOR THE 4 STITCH HIGH FIDELITY SCREENS ───────────────────────
  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1NameEntry();
      case 1:
        return _buildStep2ClassSelection();
      case 2:
        return _buildStep3DistrictSelection();
      case 3:
        return _buildStep4DifficultySelection();
      default:
        return _buildStep1NameEntry();
    }
  }

  // ── SCREEN 1: "High Fidelity - Name Entry" ──────────────────────────────────
  Widget _buildStep1NameEntry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'WHAT IS YOUR EXPLORER NAME?',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFFF2CA50),
            letterSpacing: 1.5,
            shadows: const [
              Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the moniker by which your civilization shall record your deeds.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: const Color(0xFFD0C5AF),
          ),
        ),
        const SizedBox(height: 20),

        // Ornate Parchment/Stone Input Box (stone-input)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E0FC),
            border: Border.all(color: const Color(0xFF99907C), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF4D4635),
                offset: Offset(3, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
            decoration: InputDecoration(
              icon: const Icon(Icons.edit_rounded,
                  color: Color(0xFF3C2F00), size: 22),
              hintText: 'Type your name...',
              hintStyle: GoogleFonts.spaceMono(
                fontSize: 14,
                color: const Color(0xFF6B5A3E),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ── SCREEN 2: "High Fidelity - Class Selection" ────────────────────────────
  Widget _buildStep2ClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR CLASS / GRADE',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: const Color(0xFFF2CA50),
            letterSpacing: 1.2,
            shadows: const [
              Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose your academic grade to tailor your learning journey.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: const Color(0xFFD0C5AF),
          ),
        ),
        const SizedBox(height: 14),

        // Grade Selector Grid
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: _grades.map((g) {
            final isSelected = _grade == g;
            return GestureDetector(
              onTap: () => setState(() => _grade = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF065F46)
                      : const Color(0xFF1E1E32),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF2CA50)
                        : const Color(0xFF4D4635),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(color: Color(0xFF4ADE80), blurRadius: 6)
                        ]
                      : null,
                ),
                child: Text(
                  g,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9.5,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFD0C5AF),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 18),

        Text(
          'CURRICULUM / BOARD',
          style: GoogleFonts.pressStart2p(
            fontSize: 9.5,
            color: const Color(0xFFF2CA50),
          ),
        ),
        const SizedBox(height: 10),

        // Curriculum Selector
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: _curriculums.map((c) {
            final isSelected = _curriculum == c;
            return GestureDetector(
              onTap: () => setState(() => _curriculum = c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6B13AF)
                      : const Color(0xFF111125),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFDEB7FF)
                        : const Color(0xFF4D4635),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  c,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFD0C5AF),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── SCREEN 3: "High Fidelity - District Selection" ─────────────────────────
  Widget _buildStep3DistrictSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHOOSE YOUR ACADEMY DISTRICT',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: const Color(0xFFF2CA50),
            letterSpacing: 1.2,
            shadows: const [
              Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select which knowledge domains you wish to master.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: const Color(0xFFD0C5AF),
          ),
        ),
        const SizedBox(height: 12),

        // District Cards Grid - Prominent & Luxurious Sizing for 400px Box
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 500;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isCompact ? 1 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: isCompact ? 64 : 76,
              ),
              itemCount: _districts.length,
              itemBuilder: (context, index) {
                final d = _districts[index];
                final isSelected = _selectedDistrictIndices.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected && _selectedDistrictIndices.length > 1) {
                        _selectedDistrictIndices.remove(index);
                      } else {
                        _selectedDistrictIndices.add(index);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E1E32)
                          : const Color(0xFF111125),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF2CA50)
                            : const Color(0xFF4D4635),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(color: Color(0xFFF2CA50), blurRadius: 6)
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: d.color.withValues(alpha: 0.2),
                            border: Border.all(color: d.color, width: 1.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(d.icon, color: d.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                d.title,
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 9.5,
                                  color: const Color(0xFFF2CA50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d.desc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: const Color(0xFFD0C5AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF4ADE80), size: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ── SCREEN 4: "High Fidelity - Difficulty Selection" ───────────────────────
  Widget _buildStep4DifficultySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT CHALLENGE DIFFICULTY',
          style: GoogleFonts.spaceMono(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: const Color(0xFFF2CA50),
            letterSpacing: 1.2,
            shadows: const [
              Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Configure the pace and intensity of your learning quests.',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: const Color(0xFFD0C5AF),
          ),
        ),
        const SizedBox(height: 12),

        // Difficulty Cards List - Prominent Sizing for 400px Box
        Column(
          children: _difficulties.map((diff) {
            final label = diff['label']!;
            final desc = diff['desc']!;
            final icon = diff['icon']!;
            final isSelected = _difficulty == label;

            return GestureDetector(
              onTap: () => setState(() => _difficulty = label),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E1E32)
                      : const Color(0xFF111125),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF2CA50)
                        : const Color(0xFF4D4635),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(color: Color(0xFFF2CA50), blurRadius: 6)
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: GoogleFonts.pressStart2p(
                              fontSize: 9.5,
                              color: isSelected
                                  ? const Color(0xFFF2CA50)
                                  : const Color(0xFFD0C5AF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              color: const Color(0xFFD0C5AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF4ADE80), size: 22),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── ORNATE JEWELED CONTAINER FRAME ──────────────────────────────────────────
class _OrnateJeweledBox extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  const _OrnateJeweledBox({
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF4A3728),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        ),

        // 4 Purple Jeweled Corner Accents
        const _CornerJewelAccent(top: -6, left: -6),
        const _CornerJewelAccent(top: -6, right: -6),
        const _CornerJewelAccent(bottom: -6, left: -6),
        const _CornerJewelAccent(bottom: -6, right: -6),
      ],
    );
  }
}

// ── CORNER JEWEL ACCENT WIDGET ───────────────────────────────────────────────
class _CornerJewelAccent extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _CornerJewelAccent({
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
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          gradient: const RadialGradient(
            colors: [Color(0xFFC084FC), Color(0xFF7E22CE)],
          ),
          border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademyDistrict {
  final String title;
  final String subject;
  final IconData icon;
  final Color color;
  final String desc;

  const _AcademyDistrict({
    required this.title,
    required this.subject,
    required this.icon,
    required this.color,
    required this.desc,
  });
}
