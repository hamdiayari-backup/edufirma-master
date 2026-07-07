import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../providers/app_language_provider.dart';
import '../../../../core/localization/app_translations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppLanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'about'.tr(locale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Iconsax.book,
                size: 60,
                color: AppColors.primary,
              ),
            ).animate().scale(duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'EduFirma',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            
            const SizedBox(height: 8),
            
            // Version
            Text(
              locale == 'ar' ? 'الإصدار 1.0.0' : 'Version 1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ar' ? 'عن التطبيق' : 'À propos de l\'application',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    locale == 'ar'
                        ? 'EduFirma هي منصة تعليمية شاملة توفر دورات عالية الجودة في مختلف المجالات. نحن ملتزمون بتقديم تجربة تعليمية ممتازة لجميع المتعلمين.'
                        : 'EduFirma est une plateforme d\'apprentissage complète offrant des cours de haute qualité dans divers domaines. Nous nous engageons à fournir une excellente expérience d\'apprentissage à tous les apprenants.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            
            const SizedBox(height: 20),
            
            // Features
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ar' ? 'الميزات' : 'Fonctionnalités',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    Iconsax.book,
                    locale == 'ar' ? 'دورات متنوعة' : 'Cours variés',
                    locale == 'ar'
                        ? 'الوصول إلى مجموعة واسعة من الدورات'
                        : 'Accès à une large gamme de cours',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Iconsax.teacher,
                    locale == 'ar' ? 'مدربون خبراء' : 'Formateurs experts',
                    locale == 'ar'
                        ? 'تعلم من أفضل المدربين'
                        : 'Apprenez des meilleurs formateurs',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Iconsax.medal_star,
                    locale == 'ar' ? 'شهادات' : 'Certificats',
                    locale == 'ar'
                        ? 'احصل على شهادات معتمدة'
                        : 'Obtenez des certificats reconnus',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Iconsax.shopping_cart,
                    locale == 'ar' ? 'متجر' : 'Boutique',
                    locale == 'ar'
                        ? 'تسوق المنتجات التعليمية'
                        : 'Achetez des produits éducatifs',
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
            
            const SizedBox(height: 20),
            
            // Contact Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale == 'ar' ? 'اتصل بنا' : 'Contactez-nous',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    Iconsax.sms,
                    'Email',
                    'contact@edufirma.com',
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    Iconsax.call,
                    locale == 'ar' ? 'الهاتف' : 'Téléphone',
                    '+216 28 218 356',
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    Iconsax.global,
                    'Website',
                    'www.edufirma.com',
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            
            const SizedBox(height: 32),
            
            // Copyright
            Text(
              '© 2024 EduFirma. ${locale == 'ar' ? 'جميع الحقوق محفوظة' : 'Tous droits réservés'}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
