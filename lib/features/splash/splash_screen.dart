import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _circleController;
  late AnimationController _exitController;

  // --- Logo animations ---
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoY;

  // --- Tagline ---
  late Animation<double> _taglineOpacity;
  late Animation<double> _taglineY;

  // --- Background decorative circles ---
  late Animation<double> _circleScale;
  late Animation<double> _circleOpacity;

  // --- Exit (curtain slide + fade) ---
  late Animation<Offset> _exitSlide;
  late Animation<double> _exitOpacity;

  // Letter stagger list for NONGKI
  final List<String> _letters = ['N', 'O', 'N', 'G', 'K', 'I'];
  late List<AnimationController> _letterControllers;
  late List<Animation<double>> _letterOpacities;
  late List<Animation<double>> _letterOffsets;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runSequence();
  }

  void _setupAnimations() {
    // Background ambient circles
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeOut),
    );
    _circleOpacity = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeIn),
    );

    // Logo: elastic bounce in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _logoY = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Individual letter controllers for staggered reveal
    _letterControllers = List.generate(
      _letters.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _letterOpacities = _letterControllers
        .map((c) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();
    _letterOffsets = _letterControllers
        .map((c) => Tween<double>(begin: 20.0, end: 0.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    // Tagline: slide up + fade in
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // Bg controller (for overall bg fade)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Exit: slide up curtain + fade out
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _runSequence() async {
    // Phase 1 (0ms): circles expand
    _circleController.forward();
    _bgController.forward();

    // Phase 2 (200ms): logo bounce in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();

    // Phase 3 (800ms): letters stagger in
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    for (int i = 0; i < _letterControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) _letterControllers[i].forward();
      });
    }

    // Phase 4 (1400ms): tagline slides up
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _taglineController.forward();

    // Phase 5 (2200ms): hold, then exit
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _exitController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final onboardingDone =
        prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    if (!onboardingDone) {
      context.go('/welcome');
    } else {
      // Check if user is "logged in" via shared prefs mock
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      if (isLoggedIn) {
        context.go('/');
      } else {
        context.go('/welcome');
      }
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _taglineController.dispose();
    _circleController.dispose();
    _exitController.dispose();
    for (final c in _letterControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _circleController,
        _logoController,
        _taglineController,
        _exitController,
        ..._letterControllers,
      ]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _exitOpacity,
          child: SlideTransition(
            position: _exitSlide,
            child: Scaffold(
            backgroundColor: AppColors.primary,
            body: Stack(
              children: [
                // --- Background gradient ---
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7A3F2B),
                        Color(0xFF5B3023),
                        Color(0xFF3D1F17),
                      ],
                    ),
                  ),
                ),

                // --- Ambient decorative circles (top right) ---
                Positioned(
                  top: -size.width * 0.3,
                  right: -size.width * 0.3,
                  child: Transform.scale(
                    scale: _circleScale.value,
                    child: Opacity(
                      opacity: _circleOpacity.value,
                      child: Container(
                        width: size.width * 0.9,
                        height: size.width * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Ambient circles (bottom left) ---
                Positioned(
                  bottom: -size.width * 0.4,
                  left: -size.width * 0.35,
                  child: Transform.scale(
                    scale: _circleScale.value,
                    child: Opacity(
                      opacity: _circleOpacity.value * 0.8,
                      child: Container(
                        width: size.width * 1.0,
                        height: size.width * 1.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Rotating dot ring (coffee steam vibe) ---
                Positioned(
                  top: size.height * 0.28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: (_circleOpacity.value * 1.0).clamp(0, 0.2),
                      child: _RotatingDots(
                        radius: size.width * 0.28,
                        dotCount: 12,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),

                // --- Main content ---
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with elastic bounce
                      Transform.translate(
                        offset: Offset(0, _logoY.value),
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/logo/logo_icon.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, e, s) => _FallbackLogo(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Staggered letter reveal for NONGKI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_letters.length, (i) {
                          return Transform.translate(
                            offset: Offset(0, _letterOffsets[i].value),
                            child: Opacity(
                              opacity: _letterOpacities[i].value,
                              child: Text(
                                _letters[i],
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 6,
                                  height: 1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 12),

                      // Tagline slide up
                      Transform.translate(
                        offset: Offset(0, _taglineY.value),
                        child: Opacity(
                          opacity: _taglineOpacity.value,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Temukan tempat nongki asik\nsesuai budgetmu',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFE8C9A8),
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Animated loading dots
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: _PulsingDots(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),

                // --- Version tag at bottom ---
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _taglineOpacity.value * 0.5,
                    child: const Text(
                      'v1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE8C9A8),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}

// ─── Rotating dots ring (ambient decoration) ─────────────────────────────────
class _RotatingDots extends StatefulWidget {
  final double radius;
  final int dotCount;
  final Color color;
  const _RotatingDots(
      {required this.radius, required this.dotCount, required this.color});

  @override
  State<_RotatingDots> createState() => _RotatingDotsState();
}

class _RotatingDotsState extends State<_RotatingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return SizedBox(
          width: widget.radius * 2,
          height: widget.radius * 2,
          child: CustomPaint(
            painter: _DotRingPainter(
              angle: _ctrl.value * 2 * math.pi,
              dotCount: widget.dotCount,
              radius: widget.radius,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class _DotRingPainter extends CustomPainter {
  final double angle;
  final int dotCount;
  final double radius;
  final Color color;

  const _DotRingPainter({
    required this.angle,
    required this.dotCount,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < dotCount; i++) {
      final fraction = i / dotCount;
      final theta = fraction * 2 * math.pi + angle;
      final x = center.dx + radius * math.cos(theta);
      final y = center.dy + radius * math.sin(theta);
      final opacity = (math.sin(fraction * 2 * math.pi + angle * 3) * 0.5 + 0.5) * 0.6;
      paint.color = color.withValues(alpha: opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(_DotRingPainter old) => old.angle != angle;
}

// ─── Pulsing loading dots ─────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  final Color color;
  const _PulsingDots({required this.color});

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final phase = (_ctrl.value - delay).clamp(0.0, 1.0);
            final scale = math.sin(phase * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Opacity(
                  opacity: 0.4 + scale * 0.6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Fallback logo widget ─────────────────────────────────────────────────────
class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8C9A8),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5B3023),
          ),
        ),
      ),
    );
  }
}
