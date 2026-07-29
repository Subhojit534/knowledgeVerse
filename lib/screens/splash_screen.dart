import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'onboarding_screen.dart';
import 'world_archipelago_screen.dart';

/// "High Fidelity Splash / Welcome Screen"
///
/// Features:
/// - Responsive layout guaranteed ZERO pixel overflow on all screen sizes & orientations
/// - Medieval Hogwarts & 16-Bit Obsidian styling
/// - Glassmorphism, animated background glow, jeweled corners
/// - Primary CTA "Begin Adventure" (starts onboarding)
/// - Secondary CTA "I Already Have a World" (skips to Archipelago)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  void _beginAdventure() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _continueExisting() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WorldArchipelagoScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600 || size.height < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C1F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic Atmospheric Background
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bgAnimController.value * 0.05),
                child: child,
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/splash_background.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Color(0xFF111125),
                          Color(0xFF1E1E32),
                          Color(0xFF0C0C1F),
                        ],
                      ),
                    ),
                  ),
                ),
                // Dark Vignette
                Container(color: Colors.black.withValues(alpha: 0.5)),
              ],
            ),
          ),

          // Responsive Layout without overlap or scroll overflow
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 24,
                        vertical: isMobile ? 8 : 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top HUD Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Logo Badge
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: isMobile ? 32 : 44,
                                    height: isMobile ? 32 : 44,
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFF2CA50)
                                            .withValues(alpha: 0.7),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Image.asset(
                                      'game-assets/ui/icons/golden_star_badge_icon_2x.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.school,
                                          color: Color(0xFFF2CA50),
                                          size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'KNOWLEDGEVERSE',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: isMobile ? 11 : 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF2CA50),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),

                              // Title Ribbon & Level
                              if (!isMobile)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.85),
                                    border: Border.all(
                                        color: const Color(0xFFD4AF37),
                                        width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black54, blurRadius: 4)
                                    ],
                                  ),
                                  child: Text(
                                    'THE JOURNEY BEGINS',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF2CA50),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 10 : 16,
                                  vertical: isMobile ? 4 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.85),
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37),
                                    width: isMobile ? 1.5 : 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('★',
                                        style: TextStyle(
                                            color: Color(0xFFFDE047),
                                            fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Level 1',
                                      style: GoogleFonts.spaceMono(
                                        fontSize: isMobile ? 10 : 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFF2CA50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Center Modal Dialog (Glassmorphic Golden Box)
                          Center(
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 12.0, sigmaY: 12.0),
                                child: Container(
                                  width: double.infinity,
                                  constraints:
                                      const BoxConstraints(maxWidth: 540),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 24),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 20 : 36,
                                    vertical: isMobile ? 20 : 36,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.85),
                                    border: Border.all(
                                      color: const Color(0xFFD4AF37),
                                      width: isMobile ? 3 : 4,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0xFF4A3728),
                                          spreadRadius: 3),
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 20),
                                    ],
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Jeweled Corners
                                      Positioned(
                                          top: isMobile ? -28 : -44,
                                          left: isMobile ? -28 : -44,
                                          child: _JewelCornerBadge(
                                              isMobile: isMobile)),
                                      Positioned(
                                          top: isMobile ? -28 : -44,
                                          right: isMobile ? -28 : -44,
                                          child: _JewelCornerBadge(
                                              isMobile: isMobile)),
                                      Positioned(
                                          bottom: isMobile ? -28 : -44,
                                          left: isMobile ? -28 : -44,
                                          child: _JewelCornerBadge(
                                              isMobile: isMobile)),
                                      Positioned(
                                          bottom: isMobile ? -28 : -44,
                                          right: isMobile ? -28 : -44,
                                          child: _JewelCornerBadge(
                                              isMobile: isMobile)),

                                      // Modal Content
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'WELCOME TO',
                                            style: GoogleFonts.cinzel(
                                              fontSize: isMobile ? 14 : 22,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFF2CA50)
                                                  .withValues(alpha: 0.95),
                                              letterSpacing: isMobile ? 3 : 6,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'KnowledgeVerse',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.pressStart2p(
                                                fontSize: isMobile ? 18 : 28,
                                                color: const Color(0xFF4ADE80),
                                                shadows: const [
                                                  Shadow(
                                                    color: Color(0xFF14532D),
                                                    offset: Offset(2, 2),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 14 : 24),

                                          // Ornate Separator
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 2,
                                                  decoration:
                                                      const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        Color(0xFF9333EA)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 10,
                                                height: 10,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFA855F7),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFF2CA50)),
                                                ),
                                                transform:
                                                    Matrix4.rotationZ(0.785398),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 2,
                                                  decoration:
                                                      const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF9333EA),
                                                        Colors.transparent
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: isMobile ? 12 : 20),

                                          // Subtitle
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              'Every lesson you master shapes the architecture of your own civilization.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.medievalSharp(
                                                fontSize: isMobile ? 13 : 17,
                                                height: 1.4,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: isMobile ? 18 : 28),

                                          // Action Buttons
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              _PixelButton(
                                                label: 'Begin Adventure',
                                                bgColor:
                                                    const Color(0xFF064E3B),
                                                hoverColor:
                                                    const Color(0xFF065F46),
                                                icon: Icons.play_arrow_rounded,
                                                isMobile: isMobile,
                                                onTap: _beginAdventure,
                                              ),
                                              SizedBox(
                                                  height: isMobile ? 10 : 16),
                                              _PixelButton(
                                                label:
                                                    'I Already Have a World',
                                                bgColor:
                                                    const Color(0xFF0F172A),
                                                hoverColor:
                                                    const Color(0xFF1E293B),
                                                textColor:
                                                    const Color(0xFFCBD5E1),
                                                isMobile: isMobile,
                                                onTap: _continueExisting,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 500.ms).scale(
                                begin: const Offset(0.96, 0.96),
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 16),

                          // Bottom HUD Bar
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 28,
                              vertical: isMobile ? 6 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.85),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: isMobile ? 1.5 : 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🌍',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  '1.2M Civilizations',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: isMobile ? 9 : 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  height: 14,
                                  width: 1,
                                  color: const Color(0xFFF2CA50)
                                      .withValues(alpha: 0.3),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 24),
                                ),
                                const Text('🛡️',
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  'Education First',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: isMobile ? 9 : 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PixelButton extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color hoverColor;
  final Color textColor;
  final IconData? icon;
  final bool isMobile;
  final VoidCallback onTap;

  const _PixelButton({
    required this.label,
    required this.bgColor,
    required this.hoverColor,
    this.textColor = Colors.white,
    this.icon,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<_PixelButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
              _isPressed ? 2.0 : 0.0, _isPressed ? 2.0 : 0.0, 0.0),
          padding: EdgeInsets.symmetric(
            vertical: widget.isMobile ? 10 : 16,
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.bgColor,
            border: Border.all(
              color: const Color(0xFFF2CA50),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: _isPressed ? const Offset(1, 1) : const Offset(3, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    color: const Color(0xFFF2CA50),
                    size: widget.isMobile ? 16 : 20),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceMono(
                    fontSize: widget.isMobile ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JewelCornerBadge extends StatelessWidget {
  final bool isMobile;
  const _JewelCornerBadge({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 12.0 : 16.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [Color(0xFFC084FC), Color(0xFF7E22CE)],
        ),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1.5),
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 3)],
      ),
    );
  }
}
