import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoY;
  late Animation<double> _taglineOpacity;
  late Animation<double> _taglineY;
  late Animation<double> _btnOpacity;
  late Animation<double> _btnY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _logoY = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );
    _taglineY = Tween<double>(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)),
    );

    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _btnY = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onMulai() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (!mounted) return;
    context.go('/register');
  }

  void _onMasuk() {
    context.go('/login');
  }

  void _onMasukTamu() {
    ref.read(authProvider.notifier).loginAsGuest();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Background: clean cafe photo ─────────────────────────────
              Image.asset(
                'assets/images/welcome_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2C1810),
                        Color(0xFF5B3023),
                        Color(0xFF1A0F0A),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Dark gradient overlay matching reference photo ───────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x66000000), // 40% black
                      Color(0x99000000), // 60% black
                      Color(0xDE000000), // 87% black
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // ── Content ──────────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Center content: Logo + Tagline
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // NÖNGKI brand logo matching reference
                          Transform.translate(
                            offset: Offset(0, _logoY.value),
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: const _CoffeeCupLogo(),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Tagline matching reference photo
                          Transform.translate(
                            offset: Offset(0, _taglineY.value),
                            child: Opacity(
                              opacity: _taglineOpacity.value,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Temukan tempat, pesan lebih mudah,\nkelola usaha lebih pintar.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom buttons: Mulai (white pill) & Masuk
                    Transform.translate(
                      offset: Offset(0, _btnY.value),
                      child: Opacity(
                        opacity: _btnOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                          child: Column(
                            children: [
                              // "Mulai" white pill button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _onMulai,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2C1810),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Mulai',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // "Masuk" text button
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: TextButton(
                                  onPressed: _onMasuk,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    overlayColor:
                                        Colors.white.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // "Masuk sebagai Tamu" option
                              TextButton.icon(
                                onPressed: _onMasukTamu,
                                icon: const Icon(Icons.explore_outlined, size: 16, color: Colors.white70),
                                label: const Text(
                                  'Masuk sebagai Tamu (Mode Terbatas)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white38,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Logo NÖNGKI with coffee cup 'O' matching reference photo ────────────────
class _CoffeeCupLogo extends StatelessWidget {
  const _CoffeeCupLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'N',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 4),
        CustomPaint(
          size: const Size(42, 38),
          painter: _CupLogoPainter(),
        ),
        const SizedBox(width: 4),
        const Text(
          'NGKI',
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _CupLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final steamPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Steam marks on top
    canvas.drawLine(const Offset(11, 4), const Offset(11, 8), steamPaint);
    canvas.drawLine(const Offset(21, 4), const Offset(21, 8), steamPaint);

    // Cup body: rounded bottom
    final cupRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(3, 14, 26, 21),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
      topLeft: const Radius.circular(3),
      topRight: const Radius.circular(3),
    );
    canvas.drawRRect(cupRect, strokePaint);

    // Handle on the right
    final handlePath = Path()
      ..moveTo(29, 18)
      ..cubicTo(39, 18, 39, 30, 29, 30);
    canvas.drawPath(handlePath, strokePaint);
  }

  @override
  bool shouldRepaint(_CupLogoPainter old) => false;
}
