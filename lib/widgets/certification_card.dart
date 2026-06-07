import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_state_model.dart';
import '../theme/app_theme.dart';
import '../utils/pdf_download_helper.dart';
import 'glass_container.dart';

class CertificationCard extends StatefulWidget {
  final CertificationModel certification;

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

  void _showCertificateLightbox(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 600, maxWidth: 800),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.memory(
                          base64Decode(widget.certification.imageBase64.split(',').last),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              if (widget.certification.pdfBase64.isNotEmpty)
                Positioned(
                  bottom: 24,
                  child: ElevatedButton.icon(
                    onPressed: () => downloadPdfFile(widget.certification),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text(
                      'Download PDF',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: AppTheme.primary,
                      elevation: 8,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
              if (widget.certification.imageBase64.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(widget.certification.imageBase64.split(',').last),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (widget.certification.imageBase64.isNotEmpty) {
                          _showCertificateLightbox(context);
                        } else if (widget.certification.pdfBase64.isNotEmpty) {
                          _launchUrl(widget.certification.pdfBase64);
                        } else {
                          _launchUrl(widget.certification.credentialUrl);
                        }
                      },
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
                            (widget.certification.imageBase64.isNotEmpty || widget.certification.pdfBase64.isNotEmpty) 
                                ? 'View Certificate' 
                                : 'Credential',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isHovered ? AppTheme.textPrimary : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}
