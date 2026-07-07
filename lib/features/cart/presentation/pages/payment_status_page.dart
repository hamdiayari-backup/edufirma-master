import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';
import 'package:provider/provider.dart';

class PaymentStatusPage extends StatefulWidget {
  final String status;

  const PaymentStatusPage({
    super.key,
    required this.status,
  });

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool get isSuccess => widget.status == 'success';
  bool get isPending => widget.status == 'pending';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    // Gradient colors based on status
    final gradientColors = isSuccess
        ? [const Color(0xFF7BFFAA), AppColors.primary]
        : isPending
            ? [const Color(0xFFFFD166), const Color(0xFFFF9F1C)]
            : [const Color(0xFFFC8A8A), const Color(0xFFFF4949)];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: PaymentBackgroundPainter(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Status Icon
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSuccess
                                ? Iconsax.tick_circle5
                                : isPending
                                    ? Iconsax.clock5
                                    : Iconsax.close_circle5,
                            size: 80,
                            color: isSuccess
                                ? AppColors.primary
                                : isPending
                                    ? const Color(0xFFFF9F1C)
                                    : const Color(0xFFFF4949),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Status Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          isSuccess
                              ? 'Paiement réussi!'
                              : isPending
                                  ? 'Paiement en cours'
                                  : 'Échec du paiement',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            isSuccess
                                ? 'Votre paiement a été traité avec succès. Vous pouvez maintenant accéder à vos cours.'
                                : isPending
                                    ? 'Votre paiement est en cours de traitement. Vous serez notifié une fois terminé.'
                                    : 'Une erreur s\'est produite lors du paiement. Veuillez réessayer ou contacter le support.',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Primary Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isSuccess) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.main,
                                  (route) => false,
                                );
                              } else if (isPending) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.main,
                                  (route) => false,
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            icon: Icon(
                              isSuccess
                                  ? Iconsax.home
                                  : isPending
                                      ? Iconsax.home
                                      : Iconsax.refresh,
                            ),
                            label: Text(
                              isSuccess
                                  ? 'Accueil'
                                  : isPending
                                      ? 'Accueil'
                                      : 'Réessayer',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: isSuccess
                                  ? AppColors.primary
                                  : isPending
                                      ? const Color(0xFFFF9F1C)
                                      : const Color(0xFFFF4949),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 16),

                        // Secondary Button (for success)
                        if (isSuccess) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.main,
                                  (route) => false,
                                  arguments: {'tab': 2}, // Go to profile -> purchases
                                );
                              },
                              icon: const Icon(Iconsax.book_1),
                              label: Text(
                                'Mes cours',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, end: 0),
                        ],

                        // Support Link (for failed)
                        if (!isSuccess && !isPending) ...[
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to support or contact
                            },
                            icon: const Icon(
                              Iconsax.message_question,
                              color: Colors.white70,
                            ),
                            label: Text(
                              'Contacter le support',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ).animate().fadeIn(delay: 900.ms),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for decorative background
class PaymentBackgroundPainter extends CustomPainter {
  final Color color;

  PaymentBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      80,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.1),
      60,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8),
      100,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      70,
      paint,
    );

    // Draw bottom wave
    final path = Path()
      ..moveTo(0, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.9,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.95,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}






