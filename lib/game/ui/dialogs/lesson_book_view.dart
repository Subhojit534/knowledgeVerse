import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../models/learning_models.dart';
import '../../../models/player_profile.dart';
import '../../../services/learning_service.dart';
import '../../../services/mobile_tts_service.dart';
import '../../buildings/building_data.dart';
import '../../managers/building_manager.dart';

/// Authentic Animated 3D Lesson Book View
///
/// Features realistic book physics from closed front cover to multi-page open spreads:
/// 1. 3D perspective opening from cover to 2-page spread.
/// 2. Authentic 3D page flip animation with dynamic curvature lighting and shadows.
/// 3. Drag / swipe left and right to turn pages across the chapter.
/// 4. Individual Listen Audio button on EVERY page.
/// 5. Fully static, non-scrollable parchment pages fitting all content cleanly (no scrollbars).
/// 6. Crisp, uncropped framed island illustration plate & subject artifacts.
/// 7. Chapter 1 completion seal & rewards (+50 Focus XP, +25 Coins).
/// 8. Sleek top-right close ribbon & backdrop tap (no bottom buttons).
class LessonBookView extends StatefulWidget {
  final BuildingData building;
  final VoidCallback? onClose;
  final VoidCallback? onGoToQuiz;

  const LessonBookView({
    super.key,
    required this.building,
    this.onClose,
    this.onGoToQuiz,
  });

  @override
  State<LessonBookView> createState() => _LessonBookViewState();
}

class _LessonBookViewState extends State<LessonBookView>
    with TickerProviderStateMixin {
  late AnimationController _coverController;
  late Animation<double> _coverAnimation;
  bool _isOpen = false;
  bool _isClosing = false;

  bool get _shouldShowBookControls =>
      _isOpen &&
      !_isClosing &&
      _coverAnimation.value > 0.95 &&
      !_coverController.isAnimating &&
      !_pageTurnController.isAnimating;

  late AnimationController _pageTurnController;
  late Animation<double> _pageTurnAnimation;
  int _currentSpread = 0; // 0: Pages 1-2, 1: Pages 3-4, 2: Pages 5-6 (Mastery)
  bool _isTurningForward = true;
  double _dragDistance = 0.0;

  int get _maxSpread => 2; // Spread 0: Pages 1 & 2, Spread 1: Pages 3 & 4, Spread 2: Pages 5 & 6

  bool _isLoading = true;
  LearningContentResponse? _content;
  String? _errorMessage;

  // Audio Playback
  bool _isPlayingAudio = false;
  int? _currentPlayingPage;

  // Chapter Completion State
  bool _chapterClaimed = false;

  // Book Dimensions: Large, grand open manuscript (860 x 580)
  static const double pageWidth = 430.0;
  static const double pageHeight = 580.0;
  static const double containerWidth = 860.0;
  static const double containerHeight = 580.0;

  @override
  void initState() {
    super.initState();
    _coverController = AnimationController(
      duration: const Duration(milliseconds: 900),
      reverseDuration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _coverAnimation = CurvedAnimation(
      parent: _coverController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );

    _pageTurnController = AnimationController(
      duration: const Duration(milliseconds: 460),
      vsync: this,
    );
    _pageTurnAnimation = CurvedAnimation(
      parent: _pageTurnController,
      curve: Curves.easeInOutSine,
    );

    MobileTtsService.instance.addListener(_onTtsStateChanged);

    // Automatically trigger book opening
    _coverController.forward().then((_) {
      if (mounted) setState(() => _isOpen = true);
    });

    _fetchLessonContent();
  }

  @override
  void dispose() {
    MobileTtsService.instance.removeListener(_onTtsStateChanged);
    MobileTtsService.instance.stop();
    _coverController.dispose();
    _pageTurnController.dispose();
    super.dispose();
  }

  void _onTtsStateChanged(bool isSpeaking) {
    if (mounted) {
      setState(() {
        _isPlayingAudio = isSpeaking;
        if (!isSpeaking) _currentPlayingPage = null;
      });
    }
  }

  Future<void> _fetchLessonContent() async {
    try {
      final profile = PlayerProfile.current ?? const PlayerProfile();
      final req = LearningRequest(
        buildingId: widget.building.id,
        buildingName: widget.building.name,
        subject: widget.building.subject,
        difficulty: 'Intermediate',
        studentLevel: widget.building.level,
        grade: profile.grade.isNotEmpty ? profile.grade : 'Class 10',
        curriculum: profile.curriculum.isNotEmpty ? profile.curriculum : 'CBSE',
        topic: widget.building.name,
      );

      final response = await LearningService.fetchLearningContent(req);

      if (mounted) {
        setState(() {
          _content = response;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to transcribe lesson from the Ancient Library.";
          _isLoading = false;
        });
      }
    }
  }

  void _turnPageForward() {
    if (_currentSpread < _maxSpread && !_pageTurnController.isAnimating) {
      setState(() => _isTurningForward = true);
      _pageTurnController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _currentSpread++;
            _pageTurnController.reset();
          });
        }
      });
    }
  }

  void _turnPageBackward() {
    if (_currentSpread > 0 && !_pageTurnController.isAnimating) {
      setState(() => _isTurningForward = false);
      _pageTurnController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _currentSpread--;
            _pageTurnController.reset();
          });
        }
      });
    }
  }

  void _toggleBook() {
    if (_coverController.isAnimating || _pageTurnController.isAnimating) return;
    setState(() {
      if (_isOpen) {
        _isOpen = false;
        _isClosing = true;
        _coverController.reverse();
      } else {
        _isOpen = true;
        _isClosing = false;
        _coverController.forward();
      }
    });
  }

  void _handleClose() {
    if (_isClosing) return;
    MobileTtsService.instance.stop();
    setState(() {
      _isOpen = false;
      _isClosing = true;
    });
    _coverController.reverse().then((_) {
      if (mounted) {
        widget.onClose?.call();
        BuildingManager().closeLessonBook();
      }
    });
  }

  Future<void> _toggleAudioForPage(int pageNumber, String pageText) async {
    if (_isPlayingAudio && _currentPlayingPage == pageNumber) {
      await MobileTtsService.instance.stop();
      setState(() {
        _isPlayingAudio = false;
        _currentPlayingPage = null;
      });
    } else {
      setState(() {
        _isPlayingAudio = true;
        _currentPlayingPage = pageNumber;
      });
      await MobileTtsService.instance.speak(pageText);
    }
  }

  Future<void> _claimChapterRewards() async {
    if (_chapterClaimed) return;
    setState(() => _chapterClaimed = true);

    // Award building XP and player focus XP + coins
    BuildingManager().addXp(widget.building.id, 50);

    final currentProfile = PlayerProfile.current ?? await PlayerProfile.load();
    if (currentProfile != null) {
      final updatedXp = currentProfile.xp + 50;
      final updated = currentProfile.copyWith(
        coins: currentProfile.coins + 25,
        xp: updatedXp,
        focusXp: currentProfile.focusXp + 50,
        level: PlayerProfile.computeLevel(updatedXp),
      );
      await updated.save();
    }
  }

  String _getSubjectIllustration() {
    final s = '${widget.building.subject} ${widget.building.name}'.toLowerCase();
    if (s.contains('phys') || s.contains('sci') || s.contains('astro') || s.contains('motion') || s.contains('force')) {
      return 'assets/images/island_physics.png';
    }
    if (s.contains('chem') || s.contains('potion') || s.contains('alchem') || s.contains('matter') || s.contains('atom')) {
      return 'assets/images/island_chemistry.png';
    }
    if (s.contains('bio') || s.contains('life') || s.contains('cell') || s.contains('organ') || s.contains('nature')) {
      return 'assets/images/island_biology.png';
    }
    if (s.contains('code') || s.contains('cs') || s.contains('comput') || s.contains('prog') || s.contains('algo')) {
      return 'assets/images/island_cs.png';
    }
    if (s.contains('hist') || s.contains('civic') || s.contains('social') || s.contains('world') || s.contains('ancient')) {
      return 'assets/images/island_history.png';
    }
    return 'assets/images/island_math.png';
  }

  String _getSubjectArtifact() {
    final s = '${widget.building.subject} ${widget.building.name}'.toLowerCase();
    if (s.contains('chem') || s.contains('potion') || s.contains('alchem')) {
      return 'assets/images/pixel_potion.jpg';
    }
    if (s.contains('phys') || s.contains('sci') || s.contains('astro') || s.contains('magic')) {
      return 'assets/images/pixel_wand.jpg';
    }
    if (s.contains('arena') || s.contains('hist') || s.contains('shield') || s.contains('war')) {
      return 'assets/images/pixel_shield.jpg';
    }
    if (s.contains('gem') || s.contains('cryst') || s.contains('opt')) {
      return 'assets/images/pixel_gem.jpg';
    }
    return 'assets/images/pixel_scroll.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleClose,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        alignment: Alignment.center,
        child: Stack(
          children: [
            // Centered Large 3D Book Container
            Center(
              child: GestureDetector(
                onTap: () {}, // Prevent taps inside book from closing backdrop
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: containerWidth + 40,
                    height: containerHeight + 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // --- Centered Animated 3D Book ---
                        Positioned(
                          left: 20,
                          top: 10,
                          child: GestureDetector(
                            onTap: _isOpen ? null : _toggleBook,
                            child: AnimatedBuilder(
                              animation: _coverAnimation,
                              builder: (context, child) {
                                final double shiftX = (1.0 - _coverAnimation.value) * (-pageWidth / 2);
                                return Transform.translate(
                                  offset: Offset(shiftX, 0),
                                  child: child,
                                );
                              },
                              child: SizedBox(
                                width: 2 * pageWidth,
                                height: pageHeight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // 1. Dynamic Drop Shadow beneath open book
                                    AnimatedBuilder(
                                      animation: _coverAnimation,
                                      builder: (context, _) {
                                        final double curVal = _coverAnimation.value;
                                        final double shadowW = pageWidth + curVal * pageWidth;
                                        final double shadowX = pageWidth - curVal * (pageWidth / 2);
                                        return Positioned(
                                          left: shadowX - (pageWidth / 2) + 12,
                                          top: 14,
                                          width: shadowW - 24,
                                          height: pageHeight - 16,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.55),
                                                  blurRadius: 32,
                                                  spreadRadius: 4,
                                                  offset: const Offset(4, 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    // 2. Base Right Page Spread (at left: pageWidth)
                                    Positioned(
                                      left: pageWidth,
                                      top: 0,
                                      width: pageWidth,
                                      height: pageHeight,
                                      child: AnimatedBuilder(
                                        animation: _pageTurnAnimation,
                                        builder: (context, _) {
                                          final Widget rightContent = (_pageTurnController.isAnimating && _isTurningForward)
                                              ? _buildPageByNumber(2 * (_currentSpread + 1) + 2)
                                              : _buildCurrentRightPage();
                                          return rightContent;
                                        },
                                      ),
                                    ),

                                    // 3. Dynamic spine shadow cast onto right page while opening
                                    AnimatedBuilder(
                                      animation: _coverAnimation,
                                      builder: (context, child) {
                                        final shadowOpacity = (math.sin(_coverAnimation.value * math.pi) * 0.35);
                                        return Positioned(
                                          left: pageWidth,
                                          top: 0,
                                          bottom: 0,
                                          width: 38,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
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

                                    // 4. Front Cover & Left Page Spread (hinged at x = pageWidth, swinging left)
                                    Positioned(
                                      left: pageWidth,
                                      top: 0,
                                      width: pageWidth,
                                      height: pageHeight,
                                      child: AnimatedBuilder(
                                        animation: Listenable.merge([_coverAnimation, _pageTurnAnimation]),
                                        builder: (context, child) {
                                          final angle = _coverAnimation.value * math.pi;
                                          final isBackFacing = _coverAnimation.value >= 0.5;

                                          final Widget leftContent = (_pageTurnController.isAnimating && !_isTurningForward)
                                              ? _buildPageByNumber(2 * (_currentSpread - 1) + 1)
                                              : _buildCurrentLeftPage();

                                          return Transform(
                                            alignment: Alignment.centerLeft,
                                            transform: Matrix4.identity()
                                              ..setEntry(3, 2, 0.0012)
                                              ..rotateY(angle),
                                            child: isBackFacing
                                                ? Transform(
                                                    alignment: Alignment.center,
                                                    transform: Matrix4.identity()..rotateY(math.pi),
                                                    child: leftContent,
                                                  )
                                                : _buildFrontCover(),
                                          );
                                        },
                                      ),
                                    ),

                                    // 5. Authentic 3D Page Turn Animation Leaf (sweeping over spine)
                                    if (_isOpen && _coverAnimation.value > 0.95 && _pageTurnController.isAnimating)
                                      Positioned(
                                        left: pageWidth,
                                        top: 0,
                                        width: pageWidth,
                                        height: pageHeight,
                                        child: AnimatedBuilder(
                                          animation: _pageTurnAnimation,
                                          builder: (context, _) {
                                            final t = _pageTurnAnimation.value;
                                            final double angle = _isTurningForward
                                                ? t * math.pi
                                                : (1.0 - t) * math.pi;
                                            final bool isBackFacing = angle >= math.pi / 2;
                                            final double curlFactor = math.sin(angle);
                                            // Soft horizontal curl compression simulating flexible parchment
                                            final double curlScaleX = 1.0 - (0.05 * curlFactor);

                                            final int frontPageNum = _isTurningForward
                                                ? 2 * _currentSpread + 2
                                                : 2 * (_currentSpread - 1) + 2;
                                            final int backPageNum = _isTurningForward
                                                ? 2 * (_currentSpread + 1) + 1
                                                : 2 * _currentSpread + 1;

                                            return Transform(
                                              alignment: Alignment.centerLeft,
                                              transform: Matrix4.identity()
                                                ..setEntry(3, 2, 0.0008)
                                                ..rotateY(angle)
                                                ..scale(curlScaleX, 1.0, 1.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.22 * curlFactor),
                                                      blurRadius: 16 * curlFactor + 3,
                                                      spreadRadius: 1,
                                                      offset: Offset(isBackFacing ? -8 * curlFactor : 8 * curlFactor, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Stack(
                                                  children: [
                                                    // Page Face Content
                                                    isBackFacing
                                                        ? Transform(
                                                            alignment: Alignment.center,
                                                            transform: Matrix4.identity()..rotateY(math.pi),
                                                            child: _buildPageByNumber(backPageNum),
                                                          )
                                                        : _buildPageByNumber(frontPageNum),

                                                    // Smooth continuous paper curvature lighting (no harsh color inversion at 90 deg)
                                                    Positioned.fill(
                                                      child: IgnorePointer(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: isBackFacing ? const Radius.circular(10) : Radius.zero,
                                                              bottomLeft: isBackFacing ? const Radius.circular(10) : Radius.zero,
                                                              topRight: !isBackFacing ? const Radius.circular(10) : Radius.zero,
                                                              bottomRight: !isBackFacing ? const Radius.circular(10) : Radius.zero,
                                                            ),
                                                            gradient: LinearGradient(
                                                              begin: Alignment.centerLeft,
                                                              end: Alignment.centerRight,
                                                              colors: [
                                                                Colors.black.withValues(alpha: 0.12 * curlFactor),
                                                                Colors.transparent,
                                                                Colors.white.withValues(alpha: 0.08 * curlFactor),
                                                              ],
                                                              stops: const [0.0, 0.45, 1.0],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Corner Close Cross Button (Clean circular golden seal right at the corner of the book!)
                        if (_shouldShowBookControls)
                          Positioned(
                            top: 2,
                            right: 12,
                            child: GestureDetector(
                              key: const Key('close_book_btn'),
                              onTap: _handleClose,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C221E),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFFD4AF37),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SPREAD ROUTERS ──────────────────────────────────────────────────────────
  Widget _buildCurrentLeftPage() => _buildPageByNumber(2 * _currentSpread + 1);
  Widget _buildCurrentRightPage() => _buildPageByNumber(2 * _currentSpread + 2);

  Widget _buildPageByNumber(int pageNumber) {
    return RepaintBoundary(
      key: ValueKey('page_boundary_$pageNumber'),
      child: _buildPageContent(pageNumber),
    );
  }

  Widget _buildPageContent(int pageNumber) {
    switch (pageNumber) {
      case 1:
        return _buildPage1Left();
      case 2:
        return _buildPage2Right();
      case 3:
        return _buildPage3Left();
      case 4:
        return _buildPage4Right();
      case 5:
        return _buildPage5Left();
      case 6:
      default:
        return _buildPage6Right();
    }
  }

  // ── 0. FRONT COVER (Grand Crimson & Gold Leather Tome) ──────────────────────
  Widget _buildFrontCover() {
    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF7A1C2E), // Deep Imperial Scholar Crimson
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(6, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine crease indentation
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 22,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Antique Leather Sheen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                gradient: RadialGradient(
                  center: const Alignment(-0.2, -0.3),
                  radius: 1.2,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Ornate Golden Foil Inscription Plaque
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2.2),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Codex Emblem
                    Icon(widget.building.icon, color: const Color(0xFFD4AF37), size: 48),
                    const SizedBox(height: 16),

                    // Building Name / Book Title
                    Text(
                      widget.building.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Color(0xFFD4AF37),
                        fontSize: 24.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subject and Level
                    Text(
                      '${widget.building.subject.toUpperCase()} • LEVEL ${widget.building.level}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Color(0xFFE2C974),
                        fontSize: 16.0,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Decorative Divider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 44, height: 1.5, color: const Color(0xFFD4AF37)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.star, size: 12, color: Color(0xFFD4AF37)),
                        ),
                        Container(width: 44, height: 1.5, color: const Color(0xFFD4AF37)),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'KNOWLEDGEVERSE CODEX',
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: Color(0xFFC5A059),
                        fontSize: 13.5,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tap to Open Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1),
                      ),
                      child: const Text(
                        'TAP TO READ CODEX',
                        style: TextStyle(
                          color: Color(0xFFE2C974),
                          fontSize: 13.0,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 1 (Left): CHAPTER INTRODUCTION & ILLUSTRATED REALM PLATE ──────────
  Widget _buildPage1Left() {
    final topic = _content?.topic ?? widget.building.name;
    final explanation = _content?.explanation ??
        'Mathematics provides the universal language of patterns, geometry, and cosmic symmetry across Hexafalls.';
    final page1Text = 'Chapter 1: $topic. $explanation';

    return _buildParchmentPage(
      isLeft: true,
      pageNumber: 1,
      pageText: page1Text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Rule with Page 1 Audio Button
          _buildPageHeader(
            isLeft: true,
            pageNumber: 1,
            title: 'BOOK ${widget.building.level}',
            subtitle: widget.building.subject.toUpperCase(),
            pageText: page1Text,
          ),
          const SizedBox(height: 8),

          // Chapter & Topic
          const Text(
            'CHAPTER 1',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFF7A1C2E),
            ),
          ),
          const SizedBox(height: 2),

          Text(
            topic,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 22.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF2C2422),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          const Center(
            child: Text(
              '❖   ✦   ❖',
              style: TextStyle(color: Color(0xFFC5A059), fontSize: 14.5, letterSpacing: 4),
            ),
          ),

          const SizedBox(height: 6),

          // Drop Cap Paragraph
          _buildDropCapParagraph(explanation),

          const SizedBox(height: 10),

          // Framed Realm Illustration Plate (Pristine, Uncropped & Illuminated!)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EADC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC5A059), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(1, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 0.95,
                      colors: [
                        Color(0xFFFFFDF8),
                        Color(0xFFECE4D0),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                            width: 1.0,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            _getSubjectIllustration(),
                            height: 120,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(widget.building.icon, size: 48, color: const Color(0xFF7A1C2E)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fig 1.1: Sacred Academy & Realm of ${widget.building.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5A4B48),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 2 (Right): THEORY, ESSENTIAL PRINCIPLES & FORMULAS ────────────────
  Widget _buildPage2Right() {
    final topic = _content?.topic ?? widget.building.name;
    final page2Text =
        'Section 2: Essential Laws of $topic. Understand foundational theorems and core principles governing this domain.';

    return _buildParchmentPage(
      isLeft: false,
      pageNumber: 2,
      pageText: page2Text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Rule with Page 2 Audio Button
          _buildPageHeader(
            isLeft: false,
            pageNumber: 2,
            title: topic.toUpperCase(),
            subtitle: 'SECTION II',
            pageText: page2Text,
          ),
          const SizedBox(height: 6),

          const Text(
            'THEORY & ESSENTIAL PRINCIPLES',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Color(0xFF4A3E3D),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'Mastering $topic requires grasping the fundamental laws that bridge abstract concepts with tangible problem solving in the real world.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              height: 1.35,
              color: Color(0xFF2C2422),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Illuminated Formula / Theorem Scroll Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1E3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 15, color: Color(0xFF7A1C2E)),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'CORE AXIOM • $topic'.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.9,
                          color: Color(0xFF7A1C2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Variables balance through equality; structural logic dictates physical and mathematical integrity across all dimensions.',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15.5,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                    color: Color(0xFF3D2F2D),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'KEY INSIGHTS',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Color(0xFF4A3E3D),
            ),
          ),
          const SizedBox(height: 4),

          _buildKeyPoint('Deconstruct complex problems into smaller, verifiable components.'),
          _buildKeyPoint('Verify boundary conditions and preserve balance across equations.'),
          _buildKeyPoint('Harness this codex wisdom to unlock advanced building tiers in Hexafalls.'),

          const SizedBox(height: 6),

          // Page Turn Drag Hint
          Center(
            child: GestureDetector(
              key: const Key('turn_page_hint'),
              onTap: _turnPageForward,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1C2E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF7A1C2E).withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DRAG PAGE TO TURN ➔',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.6,
                        color: const Color(0xFF7A1C2E).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 3 (Left): WORKED EXAMPLES & ARTIFACT SCHEMATIC ─────────────────────
  Widget _buildPage3Left() {
    final topic = _content?.topic ?? widget.building.name;
    final page3Text =
        'Section 3: Applied Knowledge for $topic. Step-by-step resolution of real problems and structural equations.';

    return _buildParchmentPage(
      isLeft: true,
      pageNumber: 3,
      pageText: page3Text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            isLeft: true,
            pageNumber: 3,
            title: 'APPLIED KNOWLEDGE',
            subtitle: 'WORKED BREAKDOWN',
            pageText: page3Text,
          ),
          const SizedBox(height: 10),

          const Text(
            'STEP-BY-STEP RESOLUTION',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Color(0xFF7A1C2E),
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'When ancient architects constructed the towers of Hexafalls, they relied on $topic to compute stresses and harmonic balances.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              height: 1.45,
              color: Color(0xFF2C2422),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          _buildStepCard('Step 1: Identify Key Quantities', 'Isolate known constants and identify primary dependent variables.'),
          _buildStepCard('Step 2: Apply Governing Law', 'Set up the fundamental relationship ensuring both sides remain balanced.'),
          _buildStepCard('Step 3: Conclude & Verify', 'Check constraints against physical realities and confirm the solution.'),

          const SizedBox(height: 10),

          // Artifact Schematic Plate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EADC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFC5A059), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                    color: const Color(0xFFFFFDF8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    _getSubjectArtifact(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.auto_stories, size: 36, color: Color(0xFF7A1C2E)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fig 1.2: Codex Relic • ${widget.building.name}',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3E3D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Ancient schematic parchment detailing core proofs and architectural balance.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                          color: Color(0xFF6B5B58),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  // ── PAGE 4 (Right): REALM QUESTS & APPLICATION LAB ──────────────────────────
  Widget _buildPage4Right() {
    final topic = _content?.topic ?? widget.building.name;
    final page4Text =
        'Section 4: Realm Applications. How knowledge of $topic fuels discovery and unlocks mastery across the islands.';

    return _buildParchmentPage(
      isLeft: false,
      pageNumber: 4,
      pageText: page4Text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            isLeft: false,
            pageNumber: 4,
            title: topic.toUpperCase(),
            subtitle: 'APPLICATIONS',
            pageText: page4Text,
          ),
          const SizedBox(height: 10),

          const Text(
            'REALM QUESTS & PRACTICE',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Color(0xFF4A3E3D),
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Every concept in $topic is a tool. From navigating sea archipelagos to charting astrological alignments, scholars leverage these tenets daily.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              height: 1.45,
              color: Color(0xFF2C2422),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          _buildKeyPoint('Celestial Navigation: Calculate optimal courses between archipelago islands.'),
          _buildKeyPoint('Chamber Architecture: Upgrade building capacities and unlock radiant visual auras.'),
          _buildKeyPoint('Guild Challenges: Solve collaborative quests with academy companions.'),

          const SizedBox(height: 10),

          // Ancient Scholar Quote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1E3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.0),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote_rounded, size: 22, color: Color(0xFFC5A059)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '“The universe is written in mathematical symbols; to understand its mysteries is to understand nature itself.”',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15.0,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF4A3E3D),
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: GestureDetector(
              key: const Key('finish_chapter_hint'),
              onTap: _turnPageForward,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1C2E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF7A1C2E).withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  'DRAG PAGE TO FINISH CHAPTER ➔',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                    color: const Color(0xFF7A1C2E).withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PAGE 5 (Left): CHAPTER I REVIEW & SUMMARY ARCHIVE ──────────────────────
  Widget _buildPage5Left() {
    final topic = _content?.topic ?? widget.building.name;
    final page5Text =
        'Section 5: Chapter 1 Summary for $topic. Comprehensive review of all core axioms, formulas, and realm applications.';

    return _buildParchmentPage(
      isLeft: true,
      pageNumber: 5,
      pageText: page5Text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(
            isLeft: true,
            pageNumber: 5,
            title: 'CHAPTER 1 COMPENDIUM',
            subtitle: 'MASTERY ARCHIVE',
            pageText: page5Text,
          ),
          const SizedBox(height: 10),

          const Text(
            'CHAPTER I SUMMARY',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 18.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
              color: Color(0xFF7A1C2E),
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'You have journeyed through the primary codex of $topic. Here are the core truths etched into your memory:',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              height: 1.45,
              color: Color(0xFF2C2422),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          _buildCheckItem('Fundamental Definitions & Symbolic Notation Mastered'),
          _buildCheckItem('Governing Principles & Algebraic/Physical Laws Applied'),
          _buildCheckItem('Worked Demonstrations & Real-World Quests Completed'),
          _buildCheckItem('Scholarly Foundations Established for Next Chapter Tier'),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EEE1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/paper_ui/stamp_mark.png',
                  width: 28,
                  height: 28,
                  errorBuilder: (_, __, ___) => const Icon(Icons.workspace_premium, size: 28, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Scholar Accreditation: Validated by the High Council of Hexafalls Academies.',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3E3D),
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

  // ── PAGE 6 (Right): CHAPTER 1 MASTERY SEAL & REWARD CLAIM ──────────────────
  Widget _buildPage6Right() {
    final topic = _content?.topic ?? widget.building.name;
    final page6Text =
        'Section 6: Chapter 1 Mastery for $topic. Claim your rewards: +50 Focus XP and +25 Gold Coins.';

    return _buildParchmentPage(
      isLeft: false,
      pageNumber: 6,
      pageText: page6Text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPageHeader(
            isLeft: false,
            pageNumber: 6,
            title: topic.toUpperCase(),
            subtitle: 'CHAPTER MASTERY',
            pageText: page6Text,
          ),
          const SizedBox(height: 16),

          // Golden Wax Seal
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7A1C2E),
              border: Border.all(color: const Color(0xFFD4AF37), width: 3.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.military_tech_rounded, size: 44, color: Color(0xFFD4AF37)),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'CHAPTER 1 MASTERED',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 19.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
              color: Color(0xFF7A1C2E),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'You have conquered $topic!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              color: Color(0xFF4A3E3D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 14),

          // Rewards Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1E3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: _buildRewardPill('⚡ +50 FOCUS XP', const Color(0xFF89B4FA)),
                  ),
                ),
                Container(width: 1, height: 22, color: const Color(0xFFD4AF37)),
                Expanded(
                  child: Center(
                    child: _buildRewardPill('🪙 +25 COINS', const Color(0xFFE2C974)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Go to Quiz Button (Completes lesson, closes book, and launches Quiz in dedicated arena!)
          ElevatedButton.icon(
            key: const Key('go_to_quiz_btn'),
            onPressed: () {
              MobileTtsService.instance.stop();
              setState(() {
                _isOpen = false;
                _isClosing = true;
              });
              _coverController.reverse().then((_) {
                if (mounted) {
                  widget.onClose?.call();
                  BuildingManager().closeLessonBook();
                  BuildingManager().openQuiz(widget.building);
                  widget.onGoToQuiz?.call();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A1C2E),
              foregroundColor: const Color(0xFFD4AF37),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.quiz_rounded, size: 20),
            label: const Text(
              'Go to Quiz ➔',
              style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE PARCHMENT PAGE CONTAINER ───────────────────────────────────────
  Widget _buildParchmentPage({
    required bool isLeft,
    required int pageNumber,
    required String pageText,
    required Widget child,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _dragDistance = 0.0,
      onHorizontalDragUpdate: (details) => _dragDistance += details.primaryDelta ?? 0.0,
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0.0;
        if (v < -50 || _dragDistance < -25) {
          _turnPageForward();
        } else if (v > 50 || _dragDistance > 25) {
          _turnPageBackward();
        }
      },
      child: Container(
        width: pageWidth,
        height: pageHeight,
        decoration: BoxDecoration(
          color: isLeft ? const Color(0xFFFBF8F1) : const Color(0xFFFCF9F3),
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(10) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(10) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(10) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(10) : Radius.zero,
          ),
          border: Border.all(color: const Color(0xFFE0D8C8)),
          boxShadow: [
            if (!isLeft)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(4, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Spine shadow on inner fold
            Positioned(
              left: isLeft ? null : 0,
              right: isLeft ? 0 : null,
              top: 0,
              bottom: 0,
              width: 24,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                    end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: isLeft ? 0.18 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Fixed non-scrolling page content! (NO SingleChildScrollView, NO scrollbars!)
            Padding(
              padding: EdgeInsets.fromLTRB(
                isLeft ? 26 : 28,
                18,
                isLeft ? 28 : 26,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: child,
                  ),
                  const SizedBox(height: 6),
                  // Page Number Centered at Bottom
                  Text(
                    '— $pageNumber —',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF8A7A78),
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

  // ── REUSABLE PAGE HEADER WITH PER-PAGE AUDIO BUTTON ─────────────────────────
  Widget _buildPageHeader({
    required bool isLeft,
    required int pageNumber,
    required String title,
    required String subtitle,
    required String pageText,
  }) {
    final bool isThisPagePlaying = _isPlayingAudio && _currentPlayingPage == pageNumber;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                  color: Color(0xFF7A6B68),
                ),
              ),
            ),

            // Per-Page Audio Listen Button!
            GestureDetector(
              onTap: () => _toggleAudioForPage(pageNumber, pageText),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isThisPagePlaying
                      ? const Color(0xFF89B4FA)
                      : const Color(0xFFF0E8D8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isThisPagePlaying
                        ? const Color(0xFF1E1E2E)
                        : const Color(0xFFC5A059),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isThisPagePlaying ? Icons.pause_circle_filled : Icons.volume_up_rounded,
                      size: 14,
                      color: isThisPagePlaying ? const Color(0xFF181825) : const Color(0xFF7A1C2E),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isThisPagePlaying ? 'Pause Audio' : 'Listen Page $pageNumber',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isThisPagePlaying ? const Color(0xFF181825) : const Color(0xFF4A3E3D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Divider(color: Color(0xFFE0D8C8), height: 1),
      ],
    );
  }

  // ── TYPOGRAPHY HELPERS ──────────────────────────────────────────────────────
  Widget _buildDropCapParagraph(String text) {
    if (text.isEmpty) {
      return const Text(
        'The ancient codex awaits transcription.',
        style: TextStyle(fontFamily: 'serif', fontSize: 16.5, color: Color(0xFF2C2422)),
      );
    }

    final firstChar = text.substring(0, 1).toUpperCase();
    final remainingText = text.substring(1);

    return RichText(
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7A1C2E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                firstChar,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 27.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  height: 1.0,
                ),
              ),
            ),
          ),
          TextSpan(
            text: remainingText,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 16.5,
              height: 1.45,
              letterSpacing: 0.15,
              color: Color(0xFF2C2422),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✦  ', style: TextStyle(color: Color(0xFFC5A059), fontSize: 13.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 16.0,
                height: 1.35,
                color: Color(0xFF4A3E3D),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String stepTitle, String stepDesc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right_rounded, size: 18, color: Color(0xFF7A1C2E)),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$stepTitle: ',
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A1C2E),
                    ),
                  ),
                  TextSpan(
                    text: stepDesc,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15.5,
                      height: 1.35,
                      color: Color(0xFF3D2F2D),
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

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 17, color: Color(0xFF40A02B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D2F2D),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPill(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 15.5,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }
}
