import 'dart:math';

import 'package:data4impact/features/login/page/login_page.dart';
import 'package:data4impact/features/navigation/page/navigation_page.dart';
import 'package:data4impact/features/splash/cubit/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller (runs once)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Continuous animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Configure main animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF0A6DDE),
      end: const Color(0xFF0047AB),
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Configure continuous animations
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _breathingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );

    // Start main animation sequence
    _mainController.forward();

    // Check authentication after a delay
    Future.delayed(
      const Duration(seconds: 5),
          () {
        context.read<SplashCubit>().checkAuthentication();
      },
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.authenticated) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const NavigationPage(),
              transitionDuration: const Duration(milliseconds: 800),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
            ),
          );
        } else if (state.status == SplashStatus.unauthenticated) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const LoginPage(),
              transitionDuration: const Duration(milliseconds: 800),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0047AB),
        body: Stack(
          children: [
            // Animated background with continuous rotation
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SplashBackgroundPainter(_rotationAnimation.value),
                  size: MediaQuery.of(context).size,
                );
              },
            ),

            // Subtle floating elements with continuous motion
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SubtleFloatingPainter(_floatingAnimation.value),
                  size: MediaQuery.of(context).size,
                );
              },
            ),

            // Main content with continuous animations
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon with continuous pulse and subtle rotation
                  AnimatedBuilder(
                    animation: Listenable.merge([_mainController, _pulseController, _rotationController]),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value / 20, // Very subtle rotation
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.95),
                                      const Color(0xFFC2E2FF).withOpacity(0.9),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4 * _mainController.value),
                                      blurRadius: 25,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF0062E0).withOpacity(0.25),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF0062E0),
                                      Color(0xFF0047AB),
                                    ],
                                  ).createShader(bounds),
                                  child: const Icon(
                                    Icons.analytics_outlined,
                                    size: 62,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // App name with continuous breathing effect
                  AnimatedBuilder(
                    animation: Listenable.merge([_mainController, _breathingController]),
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, 4 * sin(_breathingAnimation.value * 2 * pi)),
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Color(0xFFC2E2FF),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Data4Impact',
                                style: TextStyle(
                                  fontSize: 38 + 2 * sin(_breathingAnimation.value * 2 * pi), // Subtle size pulse
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Tagline with continuous floating effect
                  AnimatedBuilder(
                    animation: Listenable.merge([_mainController, _floatingController]),
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, 3 * sin(_floatingAnimation.value * 0.5)),
                            child: Text(
                              'Empowering decisions through data',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.85 + 0.1 * sin(_floatingAnimation.value)),
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.8,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loading indicator with continuous pulse
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([_mainController, _pulseController]),
                builder: (context, child) {
                  return Column(
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(0.7, 1.0, curve: Curves.easeOutSine),
                          ),
                        ),
                        child: ScaleTransition(
                          scale: _pulseAnimation,
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _mainController,
                                curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
                              ),
                            ),
                            child: SpinKitFadingCircle(
                              color: Colors.white.withOpacity(0.9 + 0.1 * sin(_pulseAnimation.value * 2 * pi)),
                              size: 32.0,
                              controller: _pulseController,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 0.7).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                          ),
                        ),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7 + 0.1 * sin(_floatingAnimation.value)),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Continuous background painter
class _SplashBackgroundPainter extends CustomPainter {
  final double rotationValue;

  _SplashBackgroundPainter(this.rotationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

    // Draw concentric circles with gentle pulse
    for (int i = 0; i < 3; i++) {
      final pulse = 0.5 + 0.1 * sin(currentTime * 2 + i);
      final radius = maxRadius * (0.3 + 0.2 * i) * pulse;
      final opacity = 0.12 - (0.04 * i);

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      canvas.drawCircle(center, radius, paint);
    }

    // Draw rotating data points
    final pointPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    for (int i = 0; i < 12; i++) {
      final angle = 2 * pi * i / 12 + rotationValue;
      final distance = maxRadius * 0.4;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);
      final sizeFactor = 2.0 + 0.8 * sin(currentTime * 3 + i * 0.5);

      canvas.drawCircle(Offset(x, y), sizeFactor, pointPaint);
    }

    // Draw rotating connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    for (int i = 0; i < 6; i++) {
      final angle = 2 * pi * i / 6 + rotationValue * 0.5;
      final distance = maxRadius * 0.4;
      final x = center.dx + distance * cos(angle);
      final y = center.dy + distance * sin(angle);

      canvas.drawLine(center, Offset(x, y), linePaint);
    }

    // Draw orbiting elements
    for (int i = 0; i < 4; i++) {
      final orbitAngle = rotationValue * 0.7 + i * pi / 2;
      final orbitRadius = maxRadius * (0.5 + 0.1 * i);
      final orbitX = center.dx + orbitRadius * cos(orbitAngle);
      final orbitY = center.dy + orbitRadius * sin(orbitAngle);

      final orbitPaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.drawCircle(Offset(orbitX, orbitY), 4.0, orbitPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Continuous floating elements painter
class _SubtleFloatingPainter extends CustomPainter {
  final double floatValue;

  _SubtleFloatingPainter(this.floatValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    final center = Offset(size.width / 2, size.height / 2);
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

    // Draw very subtle background elements
    final subtlePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    // Subtle concentric circles with gentle pulse
    for (int i = 0; i < 2; i++) {
      final pulse = 0.95 + 0.05 * sin(currentTime + i);
      final radius = size.width * (0.25 + 0.08 * i) * pulse;
      canvas.drawCircle(center, radius, subtlePaint);
    }

    // Very subtle floating particles with continuous motion
    for (int i = 0; i < 12; i++) {
      final x = size.width * rand.nextDouble();
      final y = size.height * (0.2 + 0.6 * rand.nextDouble());
      final offsetY = 3 * sin(floatValue * 0.5 + i * 0.5);
      final offsetX = 2 * cos(floatValue * 0.3 + i * 0.7);
      final sizeFactor = 0.6 + rand.nextDouble() * 1.0;
      final opacity = (0.02 + 0.02 * sin(currentTime + i * 0.7)).clamp(0.01, 0.06);

      final particlePaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

      canvas.drawCircle(Offset(x + offsetX, y + offsetY), sizeFactor, particlePaint);
    }

    // Draw floating data streams
    for (int i = 0; i < 5; i++) {
      final streamY = size.height * (0.1 + 0.8 * rand.nextDouble());
      final streamOffset = floatValue * 20;

      final streamPaint = Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      final path = Path()
        ..moveTo(-50 + streamOffset, streamY)
        ..quadraticBezierTo(
            size.width * 0.3,
            streamY + 30 * sin(currentTime + i),
            size.width + 50 - streamOffset,
            streamY
        );

      canvas.drawPath(path, streamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}