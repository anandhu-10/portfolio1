import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../utils/scroll_controller_provider.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollControllerProvider>(context, listen: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF070A13),
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Signature Left
              RichText(
                text: const TextSpan(
                  text: '< ',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primary,
                  ),
                  children: [
                    TextSpan(
                      text: PortfolioData.shortName,
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: ' /',
                      style: TextStyle(color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: ' >',
                      style: TextStyle(color: AppTheme.primary),
                    ),
                  ],
                ),
              ),
              
              // Back to Top Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => scrollProvider.scrollToSection(0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border, width: 1),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 24),
          
          // Copyright & social icons row
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;
              final contents = [
                Text(
                  'Copyright 2026 ${PortfolioData.name}. All rights reserved.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                if (isCompact) const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFooterSocial(Icons.link, PortfolioData.linkedinUrl),
                    const SizedBox(width: 16),
                    _buildFooterSocial(Icons.code, PortfolioData.githubUrl),
                    const SizedBox(width: 16),
                    _buildFooterSocial(Icons.camera_alt, PortfolioData.instagramUrl),
                  ],
                ),
              ];
              
              if (isCompact) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: contents,
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: contents,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSocial(IconData icon, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
