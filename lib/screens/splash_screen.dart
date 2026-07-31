import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, anim, __) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _LogoPainter(progress: _controller.value),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'Dogon'),
                    TextSpan(
                        text: 'Note',
                        style: TextStyle(color: AppColors.violet)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
              ),
              child: const Text(
                'AI DESTEKLİ NOTLARINIZ',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uygulama ikonundaki "D" hız çizgilerini andıran, sırayla çizilen
/// üç yay şeklinde açılış animasyonu.
class _LogoPainter extends CustomPainter {
  final double progress;
  _LogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glowPaint = Paint()
      ..color = AppColors.violetGlow.withOpacity(0.5 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, size.width * 0.35, glowPaint);

    final arcs = [
      (radius: size.width * 0.32, start: 0.0, end: 0.7, opacity: 1.0),
      (radius: size.width * 0.24, start: 0.15, end: 0.6, opacity: 0.75),
      (radius: size.width * 0.16, start: 0.3, end: 0.5, opacity: 0.5),
    ];

    for (final arc in arcs) {
      final localT =
          ((progress - arc.start) / (arc.end - arc.start)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final paint = Paint()
        ..color = AppColors.violet.withOpacity(arc.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(center: center, radius: arc.radius);
      const startAngle = -2.3;
      const sweepTotal = 4.2;
      canvas.drawArc(rect, startAngle, sweepTotal * localT, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
