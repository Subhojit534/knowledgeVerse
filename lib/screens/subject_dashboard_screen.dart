import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Mathematics Academy - Mobile Landscape" screen from Stitch.
/// Serves as the District Dashboard view with ornate 16-bit RPG styling,
/// double-gold pixel borders, jeweled corner accents, scanlines effect,
/// 16-bit pixel art activity illustrations, and banner-labeled cards
/// (Lessons, Quests, Puzzles, Flashcards, Mock Tests, Boss Challenges, Progress).
class SubjectDashboardScreen extends StatelessWidget {
  final String subjectName;
  final Color themeColor;

  const SubjectDashboardScreen({
    super.key,
    required this.subjectName,
    required this.themeColor,
  });

  static const List<Map<String, dynamic>> _activities = [
    {
      'title': 'Lessons',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF7ACB74),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpOBXVSng3g3XPqB3i178JbmwwHeT4gE_KgkpX-kmm93vQN6FE6THpC8Woy7j9aF_UCmCCPj8pqQDRoV8tPR2Vs0IxDklCo2uwSldNP9gJYAnPQjqMOFLl1E8DHnYTAoDbiCXvhApPrKwb1iuzpAXLoxX1uGMsQsc54z8FmfR8vcjdAv1tl2oRb9M82sr9o6FjrvJpR06jHKMdjok9VTIa9QA_9a24ehIGmQkFlc0_R6Fzx5OsU_9jm_oYHyRjLRI6WIzV5e6rt80',
    },
    {
      'title': 'Quests',
      'icon': Icons.explore_rounded,
      'color': Color(0xFFF2CA50),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBOJM6AWyUlYPOJRorfaSSYokhg7YUfd8ztnJzwanpVriIY_jCkMUVogPOxtLdUR-YgFOMdPtIP12RIHFvvOk4cJgqZPjA0KEyI8esWfTCyw1b0YpuT-dkyBtGSryPu_Mx2vHij4vUT5flDNtqTmbK9Yk91bg69p8-SKC3n4jk8urCHr3SQpy7H1q6TpkudGZ3HvpPadgJqRcwBV41K1Xl81-aF3-tYs4J23FrTkzXh5cwUjBsIHmhxIFzsSZkq8ECBPdWnVM85fVE',
    },
    {
      'title': 'Puzzles',
      'icon': Icons.extension_rounded,
      'color': Color(0xFF60A5FA),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvZkPkvv5_HNZKcdes7uxB2uZp7O3fR_awP-tTI_IiAbv_1EMHzWN09Qh7QI2IrOIxi8iZQiunvTIkQYlL0vsq7qfubJGVgrajyqDnViwDtoVnqctL5jXj_WY6NDOeLB4xSO3UnA7eoAbzINgGZhhbT7wxNZ6mMcAbUe1OByQOH6kBSB-fOAzMr_u4Z5QbqzdiVSia43fctr9BuJXASATfgFg_ryqAYce-oyT0Zpvn-xKhdImzopU8TB27DVM-9CEB1qz6H4VQLz0',
    },
    {
      'title': 'Flashcards',
      'icon': Icons.style_rounded,
      'color': Color(0xFFDEB7FF),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBRVcxSQsWggVMO5QuLp9NTaMQJAzKClGjF_kOKB3jb5HfRzl5pZFMafY0R1AwThUaUf00-Tznch3Gj9y9OWvCTxuLzdf6k83rqsNSefnwVwtb265w9WcsrVdb71e0pYr5pzv_j6bq4w_Vn5vngod-4kwHL8BQP6X0hPIcwPeyl9DqMyNv8e5XJ74AZUHjJ8vBOMNm-SvmGqXt5HFaxkHstOEWMaVkZViPaobyTpqR1rU2kkn9SNWEGd6MKoO6jD74nNR2HeNHJHxo',
    },
    {
      'title': 'Mock Tests',
      'icon': Icons.quiz_rounded,
      'color': Color(0xFF9DDCBB),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBZoRwIf7_Wa14ugxVIE7itmwidPzKARcIQFOB9gZbRNnVRQpLskyCaeNfQjzV0brb4Z_c0IBVySdxpqw_rjou-8mxkvm5FNzGG0peqUAcVGScdmveM_XhmoCbCQY-mXhM8w2ULDyXvEZc8Z6CBFmgbPQjOoeYgaMNLj6Tuhqas8-fV9iTZxfXgjjpkUaxW3l4nnSvnVwGsA8rBgONWFfohNcthsgvEIEpyIzIIF8JfIErrPVm_1qrtJX0Okdw2JL1RSoheEZ8-2Sw',
    },
    {
      'title': 'Boss Challenges',
      'icon': Icons.sports_martial_arts_rounded,
      'color': Color(0xFFFFB4AB),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD_jwGIQFX-809NFTIzpyodpg-7koVnkBFhHoOPlOVREC91EjJl1Bar6PIe_8O7EJaVa3Uw5eCR3ZVzYNF2-qgyD__gBULHG3GFgwVHt1MFycqxBUy75T7Xnw5Q1wv5Rr_WwPkIFaiLTZ1BaG5Sp9kOZfv0Zhsr2ioiLOfKsDcPDSGwoepOIbhmLM26dTVIrl0Clg1dwtMmqvtH50kRQGlGSLf7NRr54O2uP20vOgjCeRpG98M2bl-rKh8bgtm5COga931-bmtG67k',
    },
    {
      'title': 'Progress',
      'icon': Icons.bar_chart_rounded,
      'color': Color(0xFFFFD167),
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBfvxBuHc2fbf6cpmL9r5SABFkCJ__Vmfyu8gSxem1lO2_uXiC0zkoeBvRMXJ2LxYCT82fCuuhWBA4lKak8XFW356_nKW1wqPx-Lk1WcMt4QtD_zck8h9GqpTo-726CxkLFAJRB_fyUTSBb-6hXMAJLRhRPHVG3Ijmfd7yoGTNcgLfohTO9TsX0yWZyYapTOcLZxMCFISrd0IjzLll9ePZ42PXiYVncH_L2JMTpywTT-EOqJ3ZatGVbrYtTB2Bn5K3AE7Lq11jP4wc',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF111125),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Night Forest / Castle Background Layer
          Opacity(
            opacity: 0.4,
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

          // Main Screen Content
          SafeArea(
            child: Column(
              children: [
                // Header Bar (Back button + Ornate Subject Title)
                _buildHeader(context),

                // Main Activity Grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 2 : 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: _activities.length,
                          itemBuilder: (context, index) {
                            final act = _activities[index];
                            return _JeweledActivityCard(
                              title: act['title'] as String,
                              icon: act['icon'] as IconData,
                              accentColor: act['color'] as Color,
                              imageUrl: act['imageUrl'] as String?,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${act['title']} selected in $subjectName!'),
                                    backgroundColor: const Color(0xFF6B13AF),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
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

  // ── HEADER BUILDER ─────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Return Arrow Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF28283D),
                border: Border.all(
                  color: const Color(0xFFF2CA50),
                  width: 2.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFF2CA50),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title Container with Decorative Gold Lines & Gems
          Expanded(
            child: Row(
              children: [
                // Left Gold Line
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2CA50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF735C00),
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center Title Capsule
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Top Gem Accent
                      Positioned(
                        top: -6,
                        child: Transform.rotate(
                          angle: 0.785, // 45 deg
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEB7FF),
                              border: Border.all(
                                color: const Color(0xFFF2CA50),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Title Text
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          subjectName.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: const Color(0xFFF2CA50),
                            letterSpacing: 3.0,
                            shadows: const [
                              Shadow(
                                color: Color(0xFF3C2F00),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Gem Accent
                      Positioned(
                        bottom: -6,
                        child: Transform.rotate(
                          angle: 0.785,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEB7FF),
                              border: Border.all(
                                color: const Color(0xFFF2CA50),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Gold Line
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2CA50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF735C00),
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right End Ornament
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFDEB7FF),
                border: Border.all(
                  color: const Color(0xFFF2CA50),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── JEWELED ACTIVITY CARD ───────────────────────────────────────────────────
class _JeweledActivityCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final String? imageUrl;
  final VoidCallback onTap;

  const _JeweledActivityCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    this.imageUrl,
    required this.onTap,
  });

  @override
  State<_JeweledActivityCard> createState() => _JeweledActivityCardState();
}

class _JeweledActivityCardState extends State<_JeweledActivityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isBossCard = widget.title == 'Boss Challenges';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform:
              Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Card Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32).withValues(alpha: 0.9),
                  border: Border.all(
                    color: isBossCard
                        ? const Color(0xFFFFB4AB)
                        : const Color(0xFFF2CA50),
                    width: 3,
                  ),
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
                child: Column(
                  children: [
                    // Illustration / Image Body Area
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: widget.imageUrl != null
                              ? Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                                )
                              : _buildFallbackIcon(),
                        ),
                      ),
                    ),

                    // Banner Label Container at Bottom
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0C1F),
                        border: Border.all(
                          color: isBossCard
                              ? const Color(0xFFFFB4AB)
                              : const Color(0xFFF2CA50),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Small Corner Square Accents for Banner
                          Positioned(
                            top: -4,
                            left: -4,
                            child: Container(
                              width: 5,
                              height: 5,
                              color: isBossCard
                                  ? const Color(0xFFFFB4AB)
                                  : const Color(0xFFF2CA50),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 5,
                              height: 5,
                              color: isBossCard
                                  ? const Color(0xFFFFB4AB)
                                  : const Color(0xFFF2CA50),
                            ),
                          ),
                          Center(
                            child: Text(
                              widget.title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceMono(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isBossCard
                                    ? const Color(0xFFFFB4AB)
                                    : const Color(0xFFF2CA50),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4 Purple Jeweled Corner Accents
              const _CornerGem(top: -6, left: -6),
              const _CornerGem(top: -6, right: -6),
              const _CornerGem(bottom: -6, left: -6),
              const _CornerGem(bottom: -6, right: -6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Icon(
        widget.icon,
        size: 34,
        color: widget.accentColor,
      ),
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
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFF6B13AF),
          border: Border.all(
            color: const Color(0xFFF2CA50),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
