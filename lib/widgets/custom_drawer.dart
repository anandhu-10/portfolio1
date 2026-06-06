import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../utils/scroll_controller_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollControllerProvider>(context);
    final activeSection = scrollProvider.activeSection;

    return Drawer(
      backgroundColor: AppTheme.background,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header logo + close
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
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
                          text: 'Anandhu',
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            const Divider(color: AppTheme.border, height: 1),
            
            // Section menu list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: scrollProvider.sectionNames.length,
                itemBuilder: (context, index) {
                  final name = scrollProvider.sectionNames[index];
                  final isActive = activeSection == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: isActive ? AppTheme.primary.withValues(alpha: 0.08) : Colors.transparent,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop(); // Close drawer
                            scrollProvider.scrollToSection(index); // Scroll to targets
                          },
                          title: Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 16,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ),
                          trailing: isActive
                              ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.primary)
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Signature footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '© 2026 Anandhu Anil',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
