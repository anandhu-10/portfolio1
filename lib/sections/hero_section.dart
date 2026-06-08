import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_state_model.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
import '../utils/scroll_controller_provider.dart';
import '../widgets/admin/edit_dialogs.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  Future<void> _downloadResume(String resumeUrl) async {
    if (resumeUrl.isEmpty) return;
    final Uri uri = Uri.parse(resumeUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not download resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final profile = stateProvider.state.profile;
    final scrollProvider = Provider.of<ScrollControllerProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    // Padding settings depending on viewport size
    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 120.0 : (isTablet ? 90.0 : 60.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: ResponsiveLayout(
        desktop: Row(
          children: [
            Expanded(
              flex: 6,
              child: _buildTextContent(context, stateProvider, profile, scrollProvider, CrossAxisAlignment.start),
            ),
            const SizedBox(width: 48),
            Expanded(
              flex: 4,
              child: _buildProfileVisual(context, profile),
            ),
          ],
        ),
        tablet: Column(
          children: [
            _buildProfileVisual(context, profile),
            const SizedBox(height: 48),
            _buildTextContent(context, stateProvider, profile, scrollProvider, CrossAxisAlignment.center),
          ],
        ),
        mobile: Column(
          children: [
            _buildProfileVisual(context, profile),
            const SizedBox(height: 36),
            _buildTextContent(context, stateProvider, profile, scrollProvider, CrossAxisAlignment.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(
    BuildContext context, 
    PortfolioStateProvider provider,
    ProfileModel profile,
    ScrollControllerProvider scrollProvider,
    CrossAxisAlignment alignment,
  ) {
    final isCentered = alignment == CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Glowing Hello Tag
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
              ),
              child: const Text(
                'Open to internships, freelance work, and collaboration',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms),
            if (provider.editMode)
              EditSectionButton(
                onTap: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false, // Prevent accidental dismiss and data loss
                  builder: (context) => EditProfileDialog(
                    initialProfile: profile,
                    onSave: (p) => provider.updateProfile(p),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Large Name Title
        RichText(
          textAlign: isCentered ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            text: "Hi, I'm ",
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
            children: [
              TextSpan(
                text: profile.name,
                style: const TextStyle(
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
        const SizedBox(height: 12),
        
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
            Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height),
          ),
          child: Text(
            profile.role,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: ResponsiveLayout.isMobile(context) ? 22 : 26,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
        const SizedBox(height: 20),
        
        // Short Bio description
        SizedBox(
          width: 550,
          child: Text(
            profile.tagline,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: ResponsiveLayout.isMobile(context) ? 15 : 16,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ).animate().fadeIn(delay: 450.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
        const SizedBox(height: 36),
        
        // Buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
          children: [
            // Contact button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppTheme.primaryGradient,
                boxShadow: AppTheme.neonShadow(color: AppTheme.primary),
              ),
              child: ElevatedButton(
                onPressed: () => scrollProvider.scrollToSection(6),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Contact Me'),
                    SizedBox(width: 8),
                    Icon(Icons.send_rounded, size: 16),
                  ],
                ),
              ),
            ),
            
            // Download Resume
            OutlinedButton(
              onPressed: () => _downloadResume(profile.resumeUrl),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Resume'),
                  SizedBox(width: 8),
                  Icon(Icons.download_rounded, size: 14),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms),
      ],
    );
  }

  Widget _buildProfileVisual(BuildContext context, ProfileModel profile) {
    final size = ResponsiveLayout.isMobile(context) ? 220.0 : 320.0;
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer neon glow rings
          Container(
            width: size + 30,
            height: size + 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.15),
                  AppTheme.secondary.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
          
          // Floating spinning border
          Container(
            width: size + 10,
            height: size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .rotate(duration: 12.seconds),
           
          Container(
            width: size - 10,
            height: size - 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .rotate(duration: 8.seconds, begin: 1.0, end: 0.0),

          // Inner profile container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E293B),
                  AppTheme.cardBg.withValues(alpha: 0.8),
                  const Color(0xFF0F172A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative background shapes
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: size * 0.4,
                      height: size * 0.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: size * 0.5,
                      height: size * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondary.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  
                  if (profile.profilePhotoBase64.isNotEmpty)
                    Image.memory(
                      base64Decode(profile.profilePhotoBase64.split(',').last),
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    )
                  else
                    // Central Developer Avatar Placeholder Icon
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.code_rounded,
                          size: size * 0.28,
                          color: AppTheme.primary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile.initials,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: size * 0.12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1), curve: Curves.easeOutBack),
    );
  }
}
