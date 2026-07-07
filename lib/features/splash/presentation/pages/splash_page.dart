import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _logoRotateController;

  final List<FloatingOrb> _orbs = [];

  @override
  void initState() {
    super.initState();

    // Background wave animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Pulse animation for glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Rotation animation for rings
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Rotation animation for logo
    _logoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Generate floating orbs
    _generateOrbs();

    _navigateToNext();
  }

  void _generateOrbs() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _orbs.add(FloatingOrb(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 60 + 20,
        speed: random.nextDouble() * 0.5 + 0.2,
        opacity: random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _logoRotateController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3500));

    if (!mounted) return;

    // Restore session from storage so AuthProvider.isLoggedIn stays correct after app restart
    await context.read<AuthProvider>().checkLoginStatus();
    if (!mounted) return;

    final storage = LocalStorage();
    final isFirstLaunch = await storage.isFirstLaunch();
    final token = await storage.getAccessToken();

    if (!mounted) return;

    String nextRoute;
    if (isFirstLaunch) {
      nextRoute = AppRoutes.onboarding;
    } else if (token != null && token.isNotEmpty) {
      nextRoute = AppRoutes.main;
    } else {
      nextRoute = AppRoutes.login;
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_backgroundController.value * 2 * math.pi) * 0.5,
                      math.sin(_backgroundController.value * 2 * math.pi) * 0.5,
                    ),
                    end: Alignment(
                      -math.cos(_backgroundController.value * 2 * math.pi) *
                          0.5,
                      -math.sin(_backgroundController.value * 2 * math.pi) *
                          0.5,
                    ),
                    colors: const [
                      Color(0xFF0D3C45), // Deep teal
                      Color(0xFF1A5C4C), // Dark green
                      Color(0xFF2E7D32), // Forest green
                      Color(0xFF7CB342), // Light green
                    ],
                    stops: const [0.0, 0.35, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating orbs background
          ...List.generate(_orbs.length, (index) {
            final orb = _orbs[index];
            return AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                final yOffset = math.sin(
                      (_backgroundController.value + orb.speed) * 2 * math.pi,
                    ) *
                    50;
                final xOffset = math.cos(
                      (_backgroundController.value + orb.speed * 0.5) *
                          2 *
                          math.pi,
                    ) *
                    30;

                return Positioned(
                  left: orb.x * size.width + xOffset,
                  top: orb.y * size.height + yOffset,
                  child: Container(
                    width: orb.size,
                    height: orb.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(orb.opacity),
                          AppColors.primary.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Rotating rings
          Center(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_rotateController.value * 2 * math.pi * 0.7,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo with glow effect
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 180 + (_pulseController.value * 40),
                            height: 180 + (_pulseController.value * 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(
                                      0.3 - _pulseController.value * 0.2),
                                  AppColors.primary.withOpacity(0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Middle glow ring
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 160 + (_pulseController.value * 20),
                            height: 160 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white.withOpacity(
                                    0.2 - _pulseController.value * 0.1),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),

                      // Logo with rotation animation (no frame)
                      AnimatedBuilder(
                        animation: _logoRotateController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _logoRotateController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: 130,
                          height: 130,
                          child: Image.asset(
                            'assets/images/edufirmalogo3.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                          )
                          .then()
                          .shimmer(
                            duration: 1500.ms,
                            color: AppColors.white.withOpacity(0.3),
                          ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // App name with letter animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 'EduFirma'.split('').asMap().entries.map((entry) {
                    return Text(
                      entry.value,
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: AppColors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: 600 + entry.key * 80),
                          duration: 400.ms,
                        )
                        .slideY(
                          begin: -0.5,
                          end: 0,
                          delay: Duration(milliseconds: 600 + entry.key * 80),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Tagline with typewriter effect
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.white,
                      AppColors.white.withOpacity(0.7),
                      AppColors.primary.withOpacity(0.9),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    '✨ Apprenez. Évoluez. Réussissez. ✨',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1400.ms, duration: 600.ms)
                    .slideY(
                        begin: 0.3, end: 0, delay: 1400.ms, duration: 600.ms)
                    .then(delay: 200.ms)
                    .shimmer(
                        duration: 2000.ms,
                        color: AppColors.white.withOpacity(0.5)),

                const Spacer(flex: 2),

                // Modern loading indicator
                _buildLoadingIndicator(),

                const Spacer(),

                // Version text
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ).animate().fadeIn(delay: 2000.ms, duration: 400.ms),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating arc
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundController.value * 4 * math.pi,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: ArcPainter(
                    color: AppColors.white.withOpacity(0.8),
                    strokeWidth: 3,
                    sweepAngle: math.pi * 0.7,
                  ),
                ),
              );
            },
          ),

          // Inner rotating arc (opposite direction)
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_backgroundController.value * 3 * math.pi,
                child: CustomPaint(
                  size: const Size(40, 40),
                  painter: ArcPainter(
                    color: AppColors.primary.withOpacity(0.9),
                    strokeWidth: 3,
                    sweepAngle: math.pi * 0.5,
                  ),
                ),
              );
            },
          ),

          // Center dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1800.ms, duration: 400.ms);
  }
}

// Floating orb data class
class FloatingOrb {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  FloatingOrb({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Custom arc painter for loading indicator
class ArcPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double sweepAngle;

  ArcPainter({
    required this.color,
    required this.strokeWidth,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
