import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class CertificationCard extends StatefulWidget {
  final Certification certification;

  const CertificationCard({
    super.key,
    required this.certification,
  });

  @override
  State<CertificationCard> createState() => _CertificationCardState();
}

class _CertificationCardState extends State<CertificationCard> {
  bool _isHovered = false;

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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        child: GlassContainer(
          borderColor: _isHovered ? AppTheme.secondary.withValues(alpha: 0.6) : AppTheme.glassBorder,
          boxShadow: _isHovered 
              ? AppTheme.neonShadow(color: AppTheme.secondary, blur: 16.0)
              : AppTheme.glassShadow(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 22,
                      color: AppTheme.secondary,
                    ),
                  ),
                  Icon(
                    Icons.emoji_events,
                    size: 18,
                    color: _isHovered ? AppTheme.primary : AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Certification Title
              Expanded(
                child: Text(
                  widget.certification.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Organization
              Text(
                widget.certification.issuingOrganization,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // View Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _launchUrl(widget.certification.credentialUrl),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isHovered ? AppTheme.secondary : AppTheme.border,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Credential',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isHovered ? AppTheme.textPrimary : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.open_in_new,
                        size: 11,
                        color: _isHovered ? AppTheme.secondary : AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
