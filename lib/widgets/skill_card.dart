import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class SkillCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final Color accentColor;

  const SkillCard({
    super.key,
    required this.name,
    required this.icon,
    required this.accentColor,
  });

  @override
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0.0, _isHovered ? -8.0 : 0.0, 0.0),
        child: GlassContainer(
          borderColor: _isHovered ? widget.accentColor.withValues(alpha: 0.8) : AppTheme.glassBorder,
          boxShadow: _isHovered 
              ? AppTheme.neonShadow(color: widget.accentColor, blur: 14.0)
              : AppTheme.glassShadow(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 24,
                  color: widget.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
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
