import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/portfolio_state_model.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
import '../widgets/admin/edit_dialogs.dart';
import '../widgets/glass_container.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final about = stateProvider.state.about;
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    final isMobile = size.width < 640;
    final cardPadding = isMobile ? 18.0 : 24.0;
    final bioCardPadding = isMobile ? 20.0 : 32.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          _buildHeader(context, stateProvider, about),
          const SizedBox(height: 48),
          
          // Responsive Content layout
          ResponsiveLayout(
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _buildBioCard(context, about, bioCardPadding),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      _buildEducationCard(context, about, cardPadding),
                      const SizedBox(height: 24),
                      _buildGoalsCard(context, about, cardPadding),
                    ],
                  ),
                ),
              ],
            ),
            tablet: Column(
              children: [
                _buildBioCard(context, about, bioCardPadding),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEducationCard(context, about, cardPadding)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildGoalsCard(context, about, cardPadding)),
                  ],
                ),
              ],
            ),
            mobile: Column(
              children: [
                _buildBioCard(context, about, bioCardPadding),
                const SizedBox(height: 24),
                _buildEducationCard(context, about, cardPadding),
                const SizedBox(height: 24),
                _buildGoalsCard(context, about, cardPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PortfolioStateProvider provider, AboutModel about) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_circle_outlined, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'ABOUT ME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: 2,
              ),
            ),
            if (provider.editMode)
              EditSectionButton(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => EditAboutDialog(
                    initialAbout: about,
                    onSave: (a) => provider.updateAbout(a),
                  ),
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

  Widget _buildBioCard(BuildContext context, AboutModel about, double padding) {
    return GlassContainer(
      padding: EdgeInsets.all(padding),
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
          Text(
            about.aboutOne,
            style: const TextStyle(
              fontSize: 15.5,
              color: AppTheme.textSecondary,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            about.aboutTwo,
            style: const TextStyle(
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
              for (final fact in about.statistics)
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

  Widget _buildEducationCard(BuildContext context, AboutModel about, double padding) {
    return GlassContainer(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
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
          const SizedBox(height: 16),
          Text(
            about.educationDegree,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            about.educationOrg,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            about.educationDuration,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, duration: 500.ms);
  }

  Widget _buildGoalsCard(BuildContext context, AboutModel about, double padding) {
    return GlassContainer(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
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
          const SizedBox(height: 16),
          Text(
            about.careerGoals,
            style: const TextStyle(
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
