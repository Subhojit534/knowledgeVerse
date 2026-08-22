import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import 'splash_screen.dart';
import 'world_archipelago_screen.dart';

/// "Knowledgeverse Loading Page" screen from Stitch.
/// Features the exact local night forest castle background (loading_bg.png) with a transparent golden frame.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _progressController.forward().then((_) async {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Auto-login: check if user has a saved session
      final savedProfile = await PlayerProfile.load();
      final hasSession = savedProfile != null &&
          savedProfile.name.trim().isNotEmpty;

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => hasSession
              ? WorldArchipelagoScreen(profile: savedProfile)
              : const SplashScreen(),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _floatController.dispose();
    super.dispose();
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
            // PRIMARY LOCAL ASSET: pixel art castle background, shifted 50px down.
            OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: SizedBox(
                height: size.height + 100,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/loading_bg_new.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/loading_bg.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/splash_background.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'game-assets/reference/backgrounds/sky_cloud_background.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.4,
                                colors: [
                                  Color(0xFF1E1E32),
                                  Color(0xFF111125),
                                  Color(0xFF0C0C1F),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Subtle vignette to enhance text readability while keeping the background bright & clear
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),

            // Scanline effect simulation
            CustomPaint(
              painter: _ScanlinePainter(),
            ),

            // Main Golden Rectangle Frame (100% Transparent interior so background image is fully visible!)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent, // Completely transparent so wallpaper shines through!
                border: Border.all(
                  color: const Color(0xFFF2CA50),
                  width: isMobile ? 4 : 8,
                ),
              ),
              child: Stack(
                children: [
                  // Inner black border highlight right inside the golden border
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  ),

                  // Jewel Corners exactly in the screen corners
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _JewelCorner(isMobile: isMobile),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _JewelCorner(isMobile: isMobile),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _JewelCorner(isMobile: isMobile),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _JewelCorner(isMobile: isMobile),
                  ),

                  // Centered & Compact Content
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 20 : 48,
                                vertical: isMobile ? 12 : 32,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(height: isMobile ? 12 : 24),

                          // Floating Emblem
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              final offset = math.sin(
                                      _floatController.value * math.pi * 2) *
                                  (isMobile ? 6 : 10);
                              return Transform.translate(
                                offset: Offset(0, offset),
                                child: child,
                              );
                            },
                            child: Container(
                              width: isMobile ? 150 : 210,
                              height: isMobile ? 150 : 210,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9333EA)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/loading_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'game-assets/ui/icons/magic_compass_icon_2x.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.shield_rounded,
                                    size: isMobile ? 110 : 160,
                                    color: const Color(0xFFF2CA50),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isMobile ? 20 : 36),

                          // Title
                          Text(
                            'KNOWLEDGEVERSE',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceMono(
                              fontSize: isMobile ? 30 : 46,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF2CA50),
                              letterSpacing: isMobile ? 4 : 8,
                              shadows: [
                                const Shadow(
                                  color: Color(0xFF3C2F00),
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Subtitle Badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('💎',
                                  style:
                                      TextStyle(fontSize: isMobile ? 16 : 20)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'A SCHOOL OF WITCHCRAFT AND LEARNING',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: isMobile ? 15 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD4A5FF),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('💎',
                                  style:
                                      TextStyle(fontSize: isMobile ? 16 : 20)),
                            ],
                          ),

                          SizedBox(height: isMobile ? 16 : 28),

                          // Progress Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Percent label — centered above the bar
                              Center(
                                child: SizedBox(
                                  width: isMobile ? 300 : 400,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: AnimatedBuilder(
                                      animation: _progressController,
                                      builder: (context, _) {
                                        final pct = (_progressController.value * 100).toInt();
                                        return Text(
                                          '$pct%',
                                          style: GoogleFonts.spaceMono(
                                            fontSize: isMobile ? 18 : 22,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFF2CA50),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // 16-Bit Progress Bar Container (narrowed width)
                              Center(
                                child: SizedBox(
                                  width: isMobile ? 300 : 400,
                                  child: Container(
                                    height: isMobile ? 18 : 22,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A2E),
                                      border: Border.all(
                                        color: const Color(0xFF4D4635),
                                        width: isMobile ? 1.5 : 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final maxWidth = constraints.maxWidth;
                                        return Align(
                                          alignment: Alignment.centerLeft,
                                          child: AnimatedBuilder(
                                            animation: _progressController,
                                            builder: (context, child) {
                                              return Container(
                                                width: maxWidth *
                                                    _progressController.value,
                                                height: double.infinity,
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF6B13AF),
                                                      Color(0xFFD4A5FF),
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white24,
                                                      offset: Offset(0, -1),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isMobile ? 24 : 36),

                          // Bottom Icon Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFooterIcon(Icons.auto_awesome, isMobile),
                              const SizedBox(width: 24),
                              _buildFooterIcon(
                                  Icons.menu_book_rounded, isMobile),
                              const SizedBox(width: 24),
                              _buildFooterIcon(Icons.science_rounded, isMobile),
                              const SizedBox(width: 24),
                              _buildFooterIcon(Icons.castle_rounded, isMobile),
                            ],
                          ),

                          const SizedBox(height: 10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
        border: Border.all(color: const Color(0xFF4D4635), width: 1.5),
      ),
      child: Icon(
        icon,
        size: isMobile ? 18 : 22,
        color: const Color(0xFFF2CA50).withValues(alpha: 0.8),
      ),
    );
  }
}

class _JewelCorner extends StatelessWidget {
  final bool isMobile;
  const _JewelCorner({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 16.0 : 24.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF6B13AF),
        border: Border.all(
          color: const Color(0xFFF2CA50),
          width: isMobile ? 2 : 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
