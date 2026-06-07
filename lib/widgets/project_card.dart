import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_state_model.dart';

import '../theme/app_theme.dart';
import 'glass_container.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;

  const ProjectCard({
    super.key,
    required this.project,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -10.0 : 0.0, 0.0),
        child: GlassContainer(
          borderColor: _isHovered ? AppTheme.primary.withValues(alpha: 0.6) : AppTheme.glassBorder,
          boxShadow: _isHovered 
              ? AppTheme.neonShadow(color: AppTheme.primary, blur: 20.0)
              : AppTheme.glassShadow(),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image Placeholder (with overlay icon/gradients)
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: _isHovered
                          ? [AppTheme.primary.withValues(alpha: 0.4), AppTheme.secondary.withValues(alpha: 0.4)]
                          : [const Color(0xFF1E293B), const Color(0xFF0B0F19)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget.project.imageBase64.isNotEmpty)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.memory(
                              base64Decode(widget.project.imageBase64.split(',').last),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        // Coding Icon or image placeholder
                        AnimatedScale(
                          scale: _isHovered ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          child: Icon(
                            widget.project.category == 'Flutter'
                                ? Icons.smartphone
                                : Icons.laptop,
                            size: 55,
                            color: _isHovered ? Colors.white : AppTheme.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      // Top indicator badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            widget.project.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Project Text Content
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.project.subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          widget.project.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Technology Tags
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.project.technologies.map((tech) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppTheme.border, width: 0.8),
                            ),
                            child: Text(
                              tech,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          if (widget.project.githubUrl.isNotEmpty) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _launchUrl(widget.project.githubUrl),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.code, size: 15),
                                    SizedBox(width: 6),
                                    Text('GitHub', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (widget.project.liveUrl.isNotEmpty) ...[
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: AppTheme.primaryGradient,
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _launchUrl(widget.project.liveUrl),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.open_in_new, size: 13),
                                      SizedBox(width: 6),
                                      Text('Live Demo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
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
