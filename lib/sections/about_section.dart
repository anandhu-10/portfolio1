import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
import '../widgets/glass_container.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          _buildHeader(),
          const SizedBox(height: 48),
          
          // Responsive Content layout
          ResponsiveLayout(
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _buildBioCard(context),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _buildEducationCard(context),
                      const SizedBox(height: 24),
                      _buildGoalsCard(context),
                    ],
                  ),
                ),
              ],
            ),
            tablet: Column(
              children: [
                _buildBioCard(context),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEducationCard(context)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildGoalsCard(context)),
                  ],
                ),
              ],
            ),
            mobile: Column(
              children: [
                _buildBioCard(context),
                const SizedBox(height: 24),
                _buildEducationCard(context),
                const SizedBox(height: 24),
                _buildGoalsCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_circle_outlined, color: AppTheme.primary, size: 20),
            SizedBox(width: 10),
            Text(
              'ABOUT ME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0, duration: 400.ms);
  }

  Widget _buildBioCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who I Am',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            PortfolioData.aboutOne,
            style: TextStyle(
              fontSize: 15.5,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            PortfolioData.aboutTwo,
            style: TextStyle(
              fontSize: 15.5,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 28),
          
          // Core Statistics / Highlights Row
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              for (final fact in PortfolioData.quickFacts)
                _buildStatItem(fact['value']!, fact['label']!),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildStatItem(String val, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCard(BuildContext context) {
    return const GlassContainer(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: AppTheme.secondary, size: 20),
              SizedBox(width: 12),
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Diploma / Degree in Computer Engineering',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Board of Technical Examinations / University',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${PortfolioData.location} | Ongoing',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildGoalsCard(BuildContext context) {
    return const GlassContainer(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gps_fixed, color: AppTheme.primary, size: 20),
              SizedBox(width: 12),
              Text(
                'Career Goals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'To excel as a cross-platform Flutter and web engineer, developing highly interactive applications that make a tangible positive impact on society. I aim to contribute to global open-source ecosystems and research software design solutions.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms);
  }
}
