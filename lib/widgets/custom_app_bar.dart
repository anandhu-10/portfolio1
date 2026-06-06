import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/portfolio_data.dart';
import '../theme/app_theme.dart';
import '../utils/scroll_controller_provider.dart';
import '../utils/responsive_layout.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollControllerProvider>(context);
    final activeSection = scrollProvider.activeSection;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.background.withValues(alpha: 0.65),
            border: const Border(
              bottom: BorderSide(color: AppTheme.border, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              GestureDetector(
                onTap: () => scrollProvider.scrollToSection(0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: RichText(
                    text: const TextSpan(
                      text: '< ',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppTheme.primary,
                      ),
                      children: [
                        TextSpan(
                          text: PortfolioData.shortName,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' /',
                          style: TextStyle(
                            color: AppTheme.secondary,
                          ),
                        ),
                        TextSpan(
                          text: ' >',
                          style: TextStyle(
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Navigation Items (Desktop & Tablet)
              if (ResponsiveLayout.isDesktop(context) || ResponsiveLayout.isTablet(context))
                Row(
                  children: List.generate(scrollProvider.sectionNames.length, (index) {
                    final name = scrollProvider.sectionNames[index];
                    final isActive = activeSection == index;
                    return _NavBarItem(
                      name: name,
                      isActive: isActive,
                      onTap: () => scrollProvider.scrollToSection(index),
                    );
                  }),
                )
              else
                // Mobile Drawer Trigger
                IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 28, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final String name;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.name,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isActive 
        ? AppTheme.primary 
        : (_isHovered ? Colors.white : AppTheme.textSecondary);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.name,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: widget.isActive ? 22 : (_isHovered ? 14 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
