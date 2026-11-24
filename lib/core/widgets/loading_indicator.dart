import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ─── BrandedLoadingWidget (drop-in replacement for CircularProgressIndicator) ─
class BrandedLoadingWidget extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;

  const BrandedLoadingWidget({
    super.key,
    this.size = 48,
    this.color,
    this.message,
  });

  @override
  State<BrandedLoadingWidget> createState() => _BrandedLoadingWidgetState();
}

class _BrandedLoadingWidgetState extends State<BrandedLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (ctx, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.28;
                final t = (_ctrl.value - delay).clamp(0.0, 1.0);
                final scale = math.sin(t * math.pi);
                final dotSize = (widget.size / 5).clamp(6.0, 14.0);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: dotSize * 0.3),
                  child: Transform.translate(
                    offset: Offset(0, -scale * dotSize * 0.6),
                    child: Opacity(
                      opacity: 0.35 + scale * 0.65,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dotColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 13,
              color: dotColor.withValues(alpha: 0.75),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Full-screen loading overlay ──────────────────────────────────────────────
class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: BrandedLoadingWidget(
          size: 56,
          message: message ?? 'Memuat...',
        ),
      ),
    );
  }
}

// ─── Inline loading placeholder (for lists/cards) ────────────────────────────
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (ctx, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: [
                (_shimmer.value - 1).clamp(0.0, 1.0),
                _shimmer.value.clamp(0.0, 1.0),
                (_shimmer.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Coffee cup loading (untuk halaman detail/loading besar) ─────────────────
class CoffeeCupLoading extends StatefulWidget {
  final double size;
  const CoffeeCupLoading({super.key, this.size = 80});

  @override
  State<CoffeeCupLoading> createState() => _CoffeeCupLoadingState();
}

class _CoffeeCupLoadingState extends State<CoffeeCupLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CoffeeCupPainter(_ctrl.value),
        );
      },
    );
  }
}

class _CoffeeCupPainter extends CustomPainter {
  final double t;
  _CoffeeCupPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Cup body (trapezoid)
    final cupPath = Path()
      ..moveTo(w * 0.2, h * 0.35)
      ..lineTo(w * 0.25, h * 0.78)
      ..lineTo(w * 0.75, h * 0.78)
      ..lineTo(w * 0.8, h * 0.35)
      ..close();
    canvas.drawPath(cupPath, paint);

    // Cup rim
    canvas.drawLine(
        Offset(w * 0.15, h * 0.35), Offset(w * 0.85, h * 0.35), paint);

    // Handle
    final handlePath = Path()
      ..moveTo(w * 0.78, h * 0.45)
      ..cubicTo(
          w * 1.05, h * 0.45, w * 1.05, h * 0.68, w * 0.78, h * 0.68);
    canvas.drawPath(handlePath, paint);

    // Saucer
    canvas.drawLine(
        Offset(w * 0.1, h * 0.82), Offset(w * 0.9, h * 0.82), paint);

    // Steam waves (animated)
    final steamPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final phase = (t - i * 0.25).clamp(0.0, 1.0);
      final steamOpacity = math.sin(phase * math.pi);
      final steamY = h * (0.28 - phase * 0.18);
      final steamX = w * (0.35 + i * 0.15);
      steamPaint.color =
          AppColors.primary.withValues(alpha: (steamOpacity * 0.7).clamp(0, 1));

      final path = Path()
        ..moveTo(steamX, steamY + h * 0.06)
        ..cubicTo(
          steamX - w * 0.05,
          steamY + h * 0.04,
          steamX + w * 0.05,
          steamY + h * 0.02,
          steamX,
          steamY,
        );
      canvas.drawPath(path, steamPaint);
    }
  }

  @override
  bool shouldRepaint(_CoffeeCupPainter old) => old.t != t;
}

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BrandedLoadingWidget(
      size: size,
      color: color,
      message: message,
    );
  }
}

